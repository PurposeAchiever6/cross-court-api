# == Schema Information
#
# Table name: sessions
#
#  id                       :integer          not null, primary key
#  start_time               :date             not null
#  recurring                :text
#  time                     :time             not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  location_id              :integer          not null
#  end_time                 :date
#  skill_level_id           :integer
#  is_private               :boolean          default(FALSE)
#  coming_soon              :boolean          default(FALSE)
#  is_open_club             :boolean          default(FALSE)
#  duration_minutes         :integer          default(60)
#  deleted_at               :datetime
#  max_first_timers         :integer
#  women_only               :boolean          default(FALSE)
#  all_skill_levels_allowed :boolean          default(TRUE)
#  max_capacity             :integer          default(15)
#  skill_session            :boolean          default(FALSE)
#  cc_cash_earned           :decimal(, )      default(0.0)
#
# Indexes
#
#  index_sessions_on_deleted_at      (deleted_at)
#  index_sessions_on_location_id     (location_id)
#  index_sessions_on_skill_level_id  (skill_level_id)
#

require 'rails_helper'

describe Session do
  before do
    Timecop.freeze(Time.current)
  end

  after do
    Timecop.return
  end

  let!(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end
  let!(:los_angeles_date) { los_angeles_time.to_date }

  describe 'validations' do
    subject { build :session }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:time) }
    it { is_expected.to belong_to(:location) }
  end

  describe 'callbacks' do
    let!(:session) { create(:session, :daily) }
    let!(:yesterday_sem_session) do
      create(:sem_session, session: session, date: los_angeles_date.yesterday)
    end
    let(:new_recurring_rule) { IceCube::Rule.weekly }
    let(:user) { create(:user) }
    before do
      8.times do |i|
        create(:sem_session, session: session, date: los_angeles_date + i.days)
        create(:referee_session, session: session, date: los_angeles_date + i.days)
        create(:user_session, session: session, user: user, date: los_angeles_date + i.days)
      end
    end

    context 'when updating the recurring rule' do
      it 'destroys all future sem_sessions which not occur in the new rule' do
        expect {
          session.update!(recurring: new_recurring_rule)
        }.to change(SemSession, :count).by(-6)
      end

      it 'destroys all future referee_sessions which not occur in the new rule' do
        expect {
          session.update!(recurring: new_recurring_rule)
        }.to change(RefereeSession, :count).by(-6)
      end

      it 'destroys all future user_sessions which not occur in the new rule' do
        expect {
          session.update!(recurring: new_recurring_rule)
        }.to change(UserSession, :count).by(-6)
      end

      it 'adds credits to the user corresponding to the deleted user_sessions' do
        expect {
          session.update!(recurring: new_recurring_rule)
        }.to change { user.reload.credits }.from(0).to(6)
      end
    end
  end

  describe '#reservations_count' do
    let!(:session) { create(:session) }
    let!(:user_sessions) do
      create_list(
        :user_session,
        11,
        session: session,
        date: date,
        state: %i[reserved confirmed].sample
      )
    end

    let!(:user_session_1) do
      create(
        :user_session,
        session: session,
        date: date,
        state: :canceled
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        session: session,
        date: date + 1.day,
        state: %i[reserved confirmed].sample
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        session: session,
        date: date - 1.day,
        state: %i[reserved confirmed].sample
      )
    end

    let(:date) { Date.current + 2.days }

    subject { session.reservations_count(date) }

    it { is_expected.to eq(11) }
  end

  describe '#destroy' do
    let!(:session) { create(:session, :daily) }
    let!(:yesterday_sem_session) do
      create(:sem_session, session: session, date: los_angeles_date.yesterday)
    end
    let!(:tomorrow_sem_session) do
      create(:sem_session, session: session, date: los_angeles_date.tomorrow)
    end
    let!(:yesterday_referee_session) do
      create(:referee_session, session: session, date: los_angeles_date.yesterday)
    end
    let!(:tomorrow_referee_session) do
      create(:referee_session, session: session, date: los_angeles_date.tomorrow)
    end

    subject { session.destroy }

    it { is_expected.to eq(session) }

    it 'do not delete the past sem session' do
      subject
      expect(yesterday_sem_session.reload).to eq(yesterday_sem_session)
    end

    it 'do not delete the past referee session' do
      subject
      expect(yesterday_referee_session.reload).to eq(yesterday_referee_session)
    end

    it 'deletes the future sem session' do
      subject
      expect { tomorrow_sem_session.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'deletes the future referee session' do
      subject
      expect { tomorrow_referee_session.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'when it has a future user session' do
      let(:state) { %i[reserved confirmed].sample }
      let!(:user_session) do
        create(
          :user_session,
          session: session,
          date: los_angeles_date.tomorrow,
          state: state
        )
      end

      it { is_expected.to eq(false) }

      it 'do not delete the future sem session' do
        subject
        expect(tomorrow_sem_session.reload).to eq(tomorrow_sem_session)
      end

      it 'do not delete the future referee session' do
        subject
        expect(tomorrow_referee_session.reload).to eq(tomorrow_referee_session)
      end

      it 'adds the right error message to the session' do
        subject
        expect(session.errors.full_messages.first).to eq(
          'The session has future user sessions reservations'
        )
      end

      context 'when the user session has been cancelled' do
        let(:state) { :canceled }

        it { is_expected.to eq(session) }
      end
    end

    context 'when it has a past user session' do
      let!(:user_session) do
        create(
          :user_session,
          session: session,
          date: los_angeles_date.yesterday
        )
      end

      it { is_expected.to eq(session) }
    end
  end

  describe '#full?' do
    let!(:session) do
      create(
        :session,
        max_capacity: max_capacity,
        max_first_timers: max_first_timers,
        is_open_club: open_club
      )
    end

    let!(:user_1) { create(:user, :not_first_timer) }
    let!(:user_2) { create(:user, :not_first_timer) }
    let!(:user_3) { create(:user, :not_first_timer) }
    let!(:user_4) { create(:user, :not_first_timer) }

    let!(:user_session_1) do
      create(
        :user_session,
        user: user_1,
        date: date,
        session: session,
        state: :reserved
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user: user_2,
        date: date,
        session: session,
        state: :reserved
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user: user_3,
        date: date,
        session: session,
        state: :confirmed
      )
    end
    let!(:user_session_4) do
      create(
        :user_session,
        date: date,
        session: session,
        state: :canceled
      )
    end

    let(:user) { nil }
    let(:open_club) { false }
    let(:date) { Date.current + 2.days }
    let(:max_capacity) { 3 }
    let(:max_first_timers) { nil }

    subject { session.full?(date, user) }

    it { is_expected.to eq(true) }

    context 'when there are spots available' do
      before { user_session_2.destroy! }

      it { is_expected.to eq(false) }

      context 'when user is passed as argument' do
        let!(:user) { create(:user) }

        it { is_expected.to eq(false) }

        context 'when max_first_timers is 1' do
          let(:max_first_timers) { 1 }

          it { is_expected.to eq(false) }

          context 'when there is already a first timer reservation' do
            let!(:user_1) { create(:user) }

            it { is_expected.to eq(true) }
          end
        end
      end
    end

    context 'when the session is open club' do
      let(:open_club) { true }
      let(:max_capacity) { nil }

      it { is_expected.to eq(false) }
    end
  end

  describe '#spots_left' do
    let!(:session) do
      create(
        :session,
        max_capacity: max_capacity,
        max_first_timers: max_first_timers,
        is_open_club: open_club
      )
    end

    let!(:user_1) { create(:user, :not_first_timer) }
    let!(:user_2) { create(:user, :not_first_timer) }
    let!(:user_3) { create(:user, :not_first_timer) }
    let!(:user_4) { create(:user, :not_first_timer) }

    let!(:user_session_1) do
      create(
        :user_session,
        user: user_1,
        date: date,
        session: session,
        state: :reserved
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user: user_2,
        date: date,
        session: session,
        state: :reserved
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user: user_3,
        date: date,
        session: session,
        state: :confirmed
      )
    end
    let!(:user_session_4) do
      create(
        :user_session,
        date: date,
        session: session,
        state: :canceled
      )
    end

    let(:user) { nil }
    let(:open_club) { false }
    let(:date) { Date.current + 2.days }
    let(:max_capacity) { 3 }
    let(:max_first_timers) { nil }

    subject { session.spots_left(date, user) }

    it { is_expected.to eq(0) }

    context 'when there are spots available' do
      before do
        user_session_1.destroy!
        user_session_2.destroy!
      end

      it { is_expected.to eq(2) }

      context 'when user is passed as argument' do
        let!(:user) { create(:user) }

        it { is_expected.to eq(2) }

        context 'when max_first_timers is 1' do
          let(:max_first_timers) { 1 }

          it { is_expected.to eq(1) }

          context 'when there is already a first timer reservation' do
            let!(:user_3) { create(:user) }

            it { is_expected.to eq(0) }
          end
        end
      end

      context 'when the session is open club' do
        let(:open_club) { true }
        let(:max_capacity) { nil }

        it { is_expected.to eq(0) }
      end
    end
  end
end
