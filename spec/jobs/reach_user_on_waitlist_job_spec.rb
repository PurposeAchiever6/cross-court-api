require 'rails_helper'

describe ReachUserOnWaitlistJob do
  describe '#perform' do
    let!(:user_1) { create(:user, credits: user_1_credits) }
    let!(:user_2) { create(:user, credits: user_2_credits) }
    let!(:location) { create(:location) }
    let!(:session) do
      create(
        :session,
        time: session_time,
        location: location,
        max_first_timers: max_first_timers
      )
    end
    let!(:user_sessions) do
      create_list(
        :user_session,
        number_of_user_sessions,
        session: session,
        date: date,
        state: %i[reserved confirmed].sample
      )
    end
    let!(:waitlist_item_1) do
      create(:user_session_waitlist, user: user_1, session: session, date: date)
    end
    let!(:waitlist_item_2) do
      create(:user_session_waitlist, user: user_2, session: session, date: date)
    end

    let(:current_time) { Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)) }
    let(:session_time) { current_time }
    let(:user_1_credits) { 1 }
    let(:user_2_credits) { 1 }
    let(:number_of_user_sessions) { Session::MAX_CAPACITY - 1 }
    let(:date) { Time.zone.today + 2.days }
    let(:max_first_timers) { nil }
    let(:job_arg_date) { date }

    before do
      allow(SonarService).to receive(:send_message)
      allow_any_instance_of(SlackService).to receive(:session_waitlist_confirmed)
    end

    subject { ReachUserOnWaitlistJob.perform_now(session.id, job_arg_date) }

    it { is_expected.to eq(true) }
    it { expect { subject }.to change { waitlist_item_1.reload.reached }.from(false).to(true) }
    it { expect { subject }.not_to change { waitlist_item_2.reload.reached } }

    context 'when the session is full' do
      let(:number_of_user_sessions) { Session::MAX_CAPACITY }

      it { is_expected.to eq(nil) }
      it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
    end

    context 'when the are not users in the waitlist' do
      let(:job_arg_date) { date + 1.day }

      it { is_expected.to eq(nil) }
      it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
    end

    context 'when the first user on waitlist has already been reached out' do
      before { waitlist_item_1.update!(reached: true) }

      it { is_expected.to eq(true) }
      it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
      it { expect { subject }.to change { waitlist_item_2.reload.reached }.from(false).to(true) }

      context 'when all users have already been reached out' do
        before { waitlist_item_2.update!(reached: true) }

        it { is_expected.to eq(nil) }
        it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
        it { expect { subject }.not_to change { waitlist_item_2.reload.reached } }
      end
    end

    context 'when the first user on waitlist has no available credits' do
      let(:user_1_credits) { 0 }

      it { is_expected.to eq(true) }
      it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
      it { expect { subject }.to change { waitlist_item_2.reload.reached }.from(false).to(true) }

      context 'when all users has no credits' do
        let(:user_2_credits) { 0 }

        it { is_expected.to eq(nil) }
        it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
        it { expect { subject }.not_to change { waitlist_item_2.reload.reached } }
      end
    end

    context 'when there are no more first timers spots' do
      let(:max_first_timers) { number_of_user_sessions }

      it { is_expected.to eq(nil) }
      it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
      it { expect { subject }.not_to change { waitlist_item_2.reload.reached } }

      context 'when there is a no first timer in the waitlist' do
        let!(:user_2) { create(:user, :not_first_timer, credits: user_2_credits) }

        it { is_expected.to eq(true) }
        it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
        it { expect { subject }.to change { waitlist_item_2.reload.reached }.from(false).to(true) }
      end
    end

    context 'when the session starts before the waitlist tolerance' do
      let(:session_time) { current_time + UserSessionWaitlist::MINUTES_TOLERANCE + 1.minute }
      let(:date) { current_time.to_date }

      it { is_expected.to eq(true) }
      it { expect { subject }.to change { waitlist_item_1.reload.reached }.from(false).to(true) }
      it { expect { subject }.not_to change { waitlist_item_2.reload.reached } }

      context 'when the session starts after the waitlist tolerance' do
        let(:session_time) { current_time + UserSessionWaitlist::MINUTES_TOLERANCE - 1.minute }

        it { is_expected.to eq(nil) }
        it { expect { subject }.not_to change { waitlist_item_1.reload.reached } }
        it { expect { subject }.not_to change { waitlist_item_2.reload.reached } }
      end
    end
  end
end
