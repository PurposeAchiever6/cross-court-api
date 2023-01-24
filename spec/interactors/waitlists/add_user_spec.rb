require 'rails_helper'

describe Waitlists::AddUser do
  describe '.call' do
    let!(:user) { create(:user, skill_rating: user_skill_rating) }
    let!(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let!(:session) do
      create(
        :session,
        start_time: la_time.tomorrow,
        all_skill_levels_allowed:
      )
    end

    let(:date) { session.start_time }
    let(:user_skill_rating) { 1 }
    let(:all_skill_levels_allowed) { true }

    subject { Waitlists::AddUser.call(session:, user:, date:) }

    it { expect { subject }.to change(UserSessionWaitlist, :count).by(1) }

    context 'when there is no session for the date' do
      let(:date) { session.start_time + 1.day }

      it { expect { subject }.to raise_error(SessionInvalidDateException) }
    end

    context 'when date is in the past' do
      let(:date) { Time.zone.today - 2.days }

      it { expect { subject }.to raise_error(SessionInvalidDateException) }
    end

    context 'when user is already in the waitlist' do
      before { create(:user_session_waitlist, session:, user:, date:) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end

    context 'when user is already in the session' do
      let(:state) { %i[reserved confirmed].sample }

      before { create(:user_session, session:, user:, date:, state:) }

      it { expect { subject }.to raise_error(UserAlreadyInSessionException) }

      context 'when user session has been canceled' do
        let(:state) { :canceled }

        it { expect { subject }.to change(UserSessionWaitlist, :count).by(1) }
      end
    end

    context 'when the session is not for all skill levels' do
      let(:all_skill_levels_allowed) { false }

      before { session.skill_level.update!(min: 4, max: 5) }

      it { expect { subject }.to raise_error(SessionIsOutOfSkillLevelException) }

      context 'when the user is inside the session skill level' do
        let(:user_skill_rating) { 4 }

        it { expect { subject }.to change(UserSessionWaitlist, :count).by(1) }
      end
    end
  end
end
