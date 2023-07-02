# == Schema Information
#
# Table name: sessions
#
#  id                              :bigint           not null, primary key
#  start_time                      :date             not null
#  recurring                       :text
#  time                            :time             not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  location_id                     :bigint           not null
#  end_time                        :date
#  skill_level_id                  :bigint
#  is_private                      :boolean          default(FALSE)
#  coming_soon                     :boolean          default(FALSE)
#  is_open_club                    :boolean          default(FALSE)
#  duration_minutes                :integer          default(60)
#  deleted_at                      :datetime
#  max_first_timers                :integer
#  women_only                      :boolean          default(FALSE)
#  all_skill_levels_allowed        :boolean          default(TRUE)
#  max_capacity                    :integer          default(15)
#  skill_session                   :boolean          default(FALSE)
#  cc_cash_earned                  :decimal(, )      default(0.0)
#  default_referee_id              :integer
#  default_sem_id                  :integer
#  default_coach_id                :integer
#  guests_allowed                  :integer
#  guests_allowed_per_user         :integer
#  members_only                    :boolean          default(FALSE)
#  theme_title                     :string
#  theme_subheading                :string
#  theme_description               :text
#  cost_credits                    :integer          default(1)
#  allow_back_to_back_reservations :boolean          default(TRUE)
#
# Indexes
#
#  index_sessions_on_default_coach_id    (default_coach_id)
#  index_sessions_on_default_referee_id  (default_referee_id)
#  index_sessions_on_default_sem_id      (default_sem_id)
#  index_sessions_on_deleted_at          (deleted_at)
#  index_sessions_on_location_id         (location_id)
#  index_sessions_on_skill_level_id      (skill_level_id)
#  index_sessions_on_start_time          (start_time)
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
      create(:sem_session, session:, date: los_angeles_date.yesterday)
    end
    let(:new_recurring_rule) { IceCube::Rule.weekly }
    let(:user) { create(:user) }
    before do
      8.times do |i|
        create(:sem_session, session:, date: los_angeles_date + i.days)
        create(:referee_session, session:, date: los_angeles_date + i.days)
        create(:user_session, session:, user:, date: los_angeles_date + i.days)
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
        session:,
        date:,
        state: %i[reserved confirmed].sample
      )
    end

    let!(:user_session_1) do
      create(
        :user_session,
        session:,
        date:,
        state: :canceled
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        session:,
        date: date + 1.day,
        state: %i[reserved confirmed].sample
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        session:,
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
      create(:sem_session, session:, date: los_angeles_date.yesterday)
    end
    let!(:tomorrow_sem_session) do
      create(:sem_session, session:, date: los_angeles_date.tomorrow)
    end
    let!(:yesterday_referee_session) do
      create(:referee_session, session:, date: los_angeles_date.yesterday)
    end
    let!(:tomorrow_referee_session) do
      create(:referee_session, session:, date: los_angeles_date.tomorrow)
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
          session:,
          date: los_angeles_date.tomorrow,
          state:
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
          session:,
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
        max_capacity:,
        max_first_timers:,
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
        date:,
        session:,
        state: :reserved
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user: user_2,
        date:,
        session:,
        state: :reserved
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user: user_3,
        date:,
        session:,
        state: :confirmed
      )
    end
    let!(:user_session_4) do
      create(
        :user_session,
        date:,
        session:,
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

    context 'when the session has guests' do
      let!(:guest) { create(:session_guest, state: guest_state, user_session: user_session_1) }
      let(:guest_state) { %i[reserved confirmed].sample }

      before { user_session_2.destroy! }

      it { is_expected.to eq(true) }

      context 'when there are spots available' do
        before { user_session_3.destroy! }

        it { is_expected.to eq(false) }
      end

      context 'when session guest has been cancelled' do
        let(:guest_state) { :canceled }

        it { is_expected.to eq(false) }
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
        max_capacity:,
        is_open_club: open_club
      )
    end

    let!(:user_1) { create(:user) }
    let!(:user_2) { create(:user) }
    let!(:user_3) { create(:user) }
    let!(:user_4) { create(:user) }

    let!(:user_session_1) do
      create(
        :user_session,
        user: user_1,
        date:,
        session:,
        state: :reserved
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user: user_2,
        date:,
        session:,
        state: :reserved
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user: user_3,
        date:,
        session:,
        state: :confirmed
      )
    end
    let!(:user_session_4) do
      create(
        :user_session,
        user: user_4,
        date:,
        session:,
        state: :canceled
      )
    end

    let(:open_club) { false }
    let(:date) { Date.current + 2.days }
    let(:max_capacity) { 3 }

    subject { session.spots_left(date) }

    it { is_expected.to eq(0) }

    context 'when there are spots available' do
      before do
        user_session_1.destroy!
        user_session_2.destroy!
      end

      it { is_expected.to eq(2) }

      context 'when the session is open club' do
        let(:open_club) { true }

        it { is_expected.to be_nil }
      end
    end

    context 'when the session has guests' do
      let!(:guest) { create(:session_guest, state: guest_state, user_session: user_session_1) }
      let(:guest_state) { %i[reserved confirmed].sample }

      before do
        user_session_2.destroy!
        user_session_3.destroy!
      end

      it { is_expected.to eq(1) }

      context 'when session guest has been cancelled' do
        let(:guest_state) { :canceled }

        it { is_expected.to eq(2) }
      end
    end
  end

  describe '#user_reached_book_limit?' do
    let!(:user) { create(:user) }
    let!(:location) do
      create(
        :location,
        max_sessions_booked_per_day:,
        max_skill_sessions_booked_per_day:
      )
    end
    let!(:session) do
      create(
        :session,
        :daily,
        location:,
        is_open_club: open_club,
        skill_session:
      )
    end
    let!(:user_session) do
      create(
        :user_session,
        user:,
        session:,
        date: user_session_date,
        state:
      )
    end

    let(:max_sessions_booked_per_day) { nil }
    let(:max_skill_sessions_booked_per_day) { nil }
    let(:open_club) { false }
    let(:skill_session) { false }
    let(:date) { Time.zone.today }
    let(:user_session_date) { date }
    let(:state) { %i[reserved confirmed].sample }

    subject { session.user_reached_book_limit?(user, date) }

    it { is_expected.to eq(false) }

    context 'when max_sessions_booked_per_day is 1' do
      let(:max_sessions_booked_per_day) { 1 }

      it { is_expected.to eq(true) }

      context 'when the session is open club' do
        let(:open_club) { true }

        it { is_expected.to eq(false) }
      end

      context 'when the user_session has been canceled' do
        let(:state) { :canceled }

        it { is_expected.to eq(false) }
      end

      context 'when the user_session is for another day' do
        let(:user_session_date) { date - 1.day }

        it { is_expected.to eq(false) }
      end

      context 'when the user has reserved another session that is open club' do
        let!(:another_session) do
          create(
            :session,
            :daily,
            location:,
            is_open_club: true
          )
        end
        let!(:user_session) do
          create(
            :user_session,
            user:,
            session: another_session,
            date: user_session_date,
            state:
          )
        end

        it { is_expected.to eq(false) }
      end

      context 'when the user has reserved session that is a skill session' do
        let!(:another_session) do
          create(
            :session,
            :daily,
            location:,
            skill_session: true
          )
        end
        let!(:user_session) do
          create(
            :user_session,
            user:,
            session: another_session,
            date: user_session_date,
            state:
          )
        end

        it { is_expected.to eq(false) }
      end

      context 'when the session is a skill session' do
        let(:skill_session) { true }

        it { is_expected.to eq(false) }

        context 'when max_skill_sessions_booked_per_day is 1' do
          let(:max_skill_sessions_booked_per_day) { 1 }

          it { is_expected.to eq(true) }
        end
      end
    end

    context 'when max_sessions_booked_per_day is 0' do
      let(:max_sessions_booked_per_day) { 0 }

      before { user_session.destroy! }

      it { is_expected.to eq(true) }
    end
  end

  describe '#allowed_for_member?' do
    let!(:user) { create(:user) }
    let!(:session) { create(:session, :daily, members_only:) }
    let!(:product) { create(:product, product_type: :recurring) }
    let!(:active_subscription) { create(:subscription, user:, product:) }

    let(:members_only) { true }
    let(:active_subscription_product) { product }

    subject { session.allowed_for_member?(user) }

    it { is_expected.to eq(true) }

    context 'when the session is only allowed for certain product' do
      let!(:session_allowed_product) do
        create(:session_allowed_product, session:, product:)
      end

      it { is_expected.to eq(true) }

      context 'when user active subscription product is not allowed' do
        let!(:another_product) { create(:product, product_type: :recurring) }
        let(:active_subscription_product) { another_product }

        it { is_expected.to eq(true) }
      end
    end

    context 'when user does not have an active subscription' do
      let(:active_subscription) { nil }

      it { is_expected.to eq(false) }

      context 'when session is not only for members' do
        let(:members_only) { false }

        it { is_expected.to eq(true) }
      end
    end
  end

  describe '#back_to_back_sessions' do
    let(:current_time) { Time.zone.now.change(hour: 12) }
    let(:duration_minutes) { 55 }

    let!(:location) { create(:location) }
    let!(:session) do
      create(:session, :daily, time: current_time, location:, duration_minutes:)
    end
    let!(:before_session) do
      create(:session, :daily, time: current_time - 1.hour, location:, duration_minutes:)
    end
    let!(:after_session) do
      create(:session, :daily, time: current_time + 1.hour, location:, duration_minutes:)
    end

    subject { session.back_to_back_sessions(current_time.to_date) }

    it { is_expected.to match_array([before_session, after_session]) }

    context 'when before session time is too early' do
      before { before_session.update!(time: current_time - 1.hour - 15.minutes) }

      it { is_expected.to eq([after_session]) }
    end

    context 'when after session time is too late' do
      before { after_session.update!(time: current_time + 1.hour + 15.minutes) }

      it { is_expected.to eq([before_session]) }
    end

    context 'when before session duration is too short' do
      before { before_session.update!(duration_minutes: 45) }

      it { is_expected.to eq([after_session]) }
    end

    context 'when session does not have any back to back sessions' do
      before do
        before_session.update!(duration_minutes: 45)
        after_session.update!(time: current_time + 1.hour + 15.minutes)
      end

      it { is_expected.to eq([]) }
    end
  end

  describe '#allow_free_booking?' do
    let!(:location) { create(:location) }
    let!(:user) { create(:user) }
    let!(:session) do
      create(
        :session,
        :daily,
        time: session_time,
        location:,
        skill_session:,
        is_open_club: open_club,
        is_private:,
        coming_soon:
      )
    end
    let!(:user_subscription) { create(:subscription, user:, product:) }
    let!(:product) { create(:product, no_booking_charge_feature: free_charge) }

    let(:current_time) { Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)) }
    let(:session_time) { current_time + product.no_booking_charge_feature_hours.hours - 1.minute }
    let(:date) { current_time.to_date }
    let(:free_charge) { true }
    let(:skill_session) { false }
    let(:open_club) { false }
    let(:is_private) { false }
    let(:coming_soon) { false }

    subject { session.allow_free_booking?(date, user) }

    it { is_expected.to eq(true) }

    context 'when the session is a skill session' do
      let!(:skill_session) { true }

      it { is_expected.to be_falsey }
    end

    context 'when the session is open club' do
      let!(:open_club) { true }

      it { is_expected.to be_falsey }
    end

    context 'when the session is private' do
      let!(:is_private) { true }

      it { is_expected.to be_falsey }
    end

    context 'when the session is coming soon' do
      let!(:coming_soon) { true }

      it { is_expected.to be_falsey }
    end

    context 'when user is nil' do
      let!(:user) { nil }
      let!(:user_subscription) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when user does not have a subscription' do
      let!(:user_subscription) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when product does not allow to book with no charge' do
      let!(:free_charge) { false }

      it { is_expected.to be_falsey }
    end

    context 'when is outside window cancellation' do
      let(:session_time) { current_time + Session::CANCELLATION_PERIOD + 1.minute }

      it { is_expected.to be_falsey }
    end

    context 'when there are already more than 11 reservations for that session' do
      let!(:reservations) { create_list(:user_session, 12, session:, date:) }

      it { is_expected.to be_falsey }
    end
  end
end
