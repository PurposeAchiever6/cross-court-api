require 'rails_helper'

describe Sessions::Vote do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let!(:session) { create(:session, start_time: la_time.tomorrow, coming_soon:) }

    let(:date) { session.start_time }
    let(:coming_soon) { true }

    subject { Sessions::Vote.call(session:, user:, date:) }

    it { expect { subject }.to change(UserSessionVote, :count).by(1) }

    context 'when there is no session for the date' do
      let(:date) { session.start_time + 1.day }

      it { expect { subject }.to raise_error(SessionInvalidDateException) }
    end

    context 'when date is in the past' do
      let(:date) { Time.zone.today - 2.days }

      it { expect { subject }.to raise_error(SessionInvalidDateException) }
    end

    context 'when user has already voted for that session and date' do
      before { create(:user_session_vote, session:, user:, date:) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end

    context 'when session is not coming soon' do
      let(:coming_soon) { false }

      it { expect { subject }.to raise_error(SessionNotComingSoonException) }
    end
  end
end
