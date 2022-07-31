require 'rails_helper'

describe ::Sessions::CheckInUsersJob do
  describe '#perform' do
    let(:la_time)  { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let!(:la_date) { la_time.to_date }
    let!(:session) { create(:session, cc_cash_earned: cc_cash_earned) }

    let(:subscription_credits) { rand(1..5) }
    let(:active_subscription) { create(:subscription) }
    let(:first_session) { false }
    let(:cc_cash_earned) { rand(1..50) }

    let!(:user) do
      create(
        :user,
        subscription_credits: subscription_credits,
        active_subscription: active_subscription
      )
    end

    let!(:user_session) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: true,
        date: la_date,
        state: :confirmed,
        first_session: first_session
      )
    end
    let(:user_session_id) { user_session.id }

    let(:instance) { instance_double(ActiveCampaignService) }
    let(:double_class) { class_double(ActiveCampaignService).as_stubbed_const }

    before do
      allow(double_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:create_deal)
    end

    subject { described_class.perform_now(user_session_id) }

    it { expect { subject }.to change { user.reload.cc_cash }.by(cc_cash_earned) }

    context 'when session cc_cash_earned is zero' do
      let(:cc_cash_earned) { 0 }

      it { expect { subject }.not_to change { user.reload.cc_cash } }
    end

    context 'when time_to_re_up and drop_in_re_up conditions are not met' do
      context 'when is not free session' do
        it do
          expect(instance).to receive(:create_deal).once.with(
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::FIRST_SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::TIME_TO_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::DROP_IN_RE_UP,
            user
          )

          subject
        end
      end

      context 'when is first session' do
        let(:first_session) { true }

        it do
          expect(instance).to receive(:create_deal).once.with(
            ::ActiveCampaign::Deal::Event::FIRST_SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::TIME_TO_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::DROP_IN_RE_UP,
            user
          )

          subject
        end
      end
    end

    context 'when calling ActiveCampaign multiple times' do
      context 'when time_to_re_up conditions are met' do
        let(:subscription_credits) { 0 }

        it do
          expect(instance).to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN,
            user
          )
          expect(instance).to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::TIME_TO_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::FIRST_SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::DROP_IN_RE_UP,
            user
          )

          subject
        end
      end

      context 'drop_in_re_up are met' do
        let(:active_subscription) { nil }

        it do
          expect(instance).to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN,
            user
          )
          expect(instance).to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::DROP_IN_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::TIME_TO_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::FIRST_SESSION_CHECK_IN,
            user
          )

          subject
        end
      end
    end

    context 'when is the tenth session' do
      before { ENV['NUMBER_OF_SESSIONS_TO_NOTIFY'] = '20, 50' }

      let(:previous_user_session_count) { 9 }
      let!(:previous_user_sessions) do
        create_list(
          :user_session,
          previous_user_session_count,
          user: user,
          session: session,
          checked_in: true,
          date: la_date,
          state: :confirmed
        )
      end

      it 'does not send checked in session notice email' do
        expect { subject }.not_to have_enqueued_job.on_queue('mailers')

        subject
      end

      context 'when the environment include notifying at the tenth session' do
        before { ENV['NUMBER_OF_SESSIONS_TO_NOTIFY'] = '10, 20, 50' }

        it 'sends checked in session notice email' do
          expect { subject }.to have_enqueued_job.on_queue('mailers')

          subject
        end
      end

      context 'when user is not a member' do
        let(:active_subscription) { nil }

        it 'does not send the checked in session notice email' do
          expect { subject }.not_to have_enqueued_job.on_queue('mailers')

          subject
        end
      end

      context 'when is the eleventh session' do
        let(:previous_user_session_count) { 10 }

        it 'does not send the checked in session notice email' do
          expect { subject }.not_to have_enqueued_job.on_queue('mailers')

          subject
        end
      end
    end
  end
end
