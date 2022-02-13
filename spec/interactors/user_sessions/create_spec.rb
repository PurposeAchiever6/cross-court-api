require 'rails_helper'

describe UserSessions::Create do
  describe '.call' do
    let!(:session) { create(:session, :daily, time: session_time) }
    let!(:user) do
      create(
        :user,
        credits: credits,
        subscription_credits: subscription_credits,
        free_session_state: free_session_state
      )
    end

    let(:credits) { 1 }
    let(:subscription_credits) { 0 }
    let(:free_session_state) { :used }
    let(:time_now) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:session_time) { time_now + Session::CANCELLATION_PERIOD + 1.minute }
    let(:date) { time_now.to_date }

    let(:subject_args) { { user: user, session: session, date: date } }
    let(:created_user_session) { UserSession.last }

    before do
      allow_any_instance_of(SlackService).to receive(:session_booked)
    end

    subject do
      UserSessions::Create.call(subject_args)
    end

    it { expect { subject }.to change(UserSession, :count).by(1) }
    it { expect { subject }.to change { user.reload.credits }.by(-1) }
    it { expect { subject }.not_to change { user.reload.free_session_state } }

    it { expect(subject.user_session.id).to eq(created_user_session.id) }
    it { expect(subject.user_session.is_free_session).to eq(false) }
    it { expect(subject.user_session.state).to eq('reserved') }

    it 'calls Slack service' do
      expect_any_instance_of(SlackService).to receive(:session_booked)
      subject
    end

    it 'enques ActiveCampaign::CreateDealJob' do
      expect { subject }.to have_enqueued_job(
        ::ActiveCampaign::CreateDealJob
      ).with(
        ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
        user.id,
        user_session_id: anything
      )
    end

    it 'sends session booked email' do
      expect { subject }.to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with('SessionMailer', 'session_booked', anything, anything)
    end

    context 'when user does not have credits but has subscription_credits' do
      let(:credits) { 0 }
      let(:subscription_credits) { 1 }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.to change { user.reload.subscription_credits }.by(-1) }

      context 'when user has unlimited subscription' do
        let(:subscription_credits) { Product::UNLIMITED }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { user.reload.credits } }
        it { expect { subject }.not_to change { user.reload.subscription_credits } }
      end
    end

    context 'when there is only one spot left' do
      let!(:user_sessions) do
        create_list(
          :user_session,
          Session::MAX_CAPACITY - 1,
          session: session,
          date: date
        )
      end

      it { expect { subject }.to change(UserSession, :count).by(1) }

      context 'when session is full' do
        let!(:last_user_session) { create(:user_session, session: session, date: date) }

        it { expect { subject rescue nil }.not_to change(UserSession, :count) }
        it { expect { subject }.to raise_error(FullSessionException, 'Session is full') }
      end
    end

    context 'when invalid date' do
      let(:date) { time_now.to_date - 1.day }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }
      it { expect { subject }.to raise_error(InvalidDateException, 'Invalid date') }
    end

    context 'when there is no session for the selected date' do
      let!(:session_exception) { create(:session_exception, session: session, date: date) }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }
      it { expect { subject }.to raise_error(InvalidDateException, 'Invalid date') }
    end

    context 'when user does not have any credit' do
      let(:credits) { 0 }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }

      it 'raises NotEnoughCreditsException' do
        expect { subject }.to raise_error(
          NotEnoughCreditsException,
          'Not enough credits. Please buy more.'
        )
      end
    end

    context 'when not_charge_user_credit is true' do
      before { subject_args.merge!(not_charge_user_credit: true) }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }

      context 'when user does not have any credit' do
        let(:credits) { 0 }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { user.reload.credits } }
        it { expect { subject }.not_to change { user.reload.subscription_credits } }
      end
    end

    context 'when user free_session_state is claimed' do
      let(:free_session_state) { :claimed }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.to change { user.reload.free_session_state }.to('used') }
      it { expect(subject.user_session.is_free_session).to eq(true) }
    end

    context 'when reservation is inside window cancellation' do
      let(:session_time) { time_now + Session::CANCELLATION_PERIOD - 1.minute }

      before do
        allow(SonarService).to receive(:send_message)
        allow_any_instance_of(SlackService).to receive(:session_auto_confirmed)
      end

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect(subject.user_session.state).to eq('confirmed') }

      it 'calls Sonar service' do
        expect(SonarService).to receive(:send_message)
        subject
      end

      it 'calls Slack service' do
        expect_any_instance_of(SlackService).to receive(:session_auto_confirmed)
        subject
      end

      it 'enques ActiveCampaign::CreateDealJob' do
        expect { subject }.to have_enqueued_job(
          ::ActiveCampaign::CreateDealJob
        ).with(
          ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
          user.id,
          user_session_id: anything
        )
      end
    end

    context 'when reservation has a referral' do
      let!(:referral_user) { create(:user) }

      before { subject_args.merge!(referral_code: referral_user.referral_code) }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.to change { referral_user.reload.credits }.by(1) }

      it 'enques ActiveCampaign::CreateDealJob' do
        expect { subject }.to have_enqueued_job(
          ::ActiveCampaign::CreateDealJob
        ).with(
          ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS,
          referral_user.id,
          referred_id: user.id
        )
      end

      context 'if referral is the same user that reserves' do
        before { subject_args.merge!(referral_code: user.referral_code) }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { referral_user.reload.credits } }

        it 'should not enque ActiveCampaign::CreateDealJob' do
          expect { subject }.not_to have_enqueued_job(
            ::ActiveCampaign::CreateDealJob
          ).with(
            ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS,
            referral_user.id,
            referred_id: user.id
          )
        end
      end

      context 'when is not user first session' do
        let!(:user_session) { create(:user_session, user: user) }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { referral_user.reload.credits } }

        it 'should not enque ActiveCampaign::CreateDealJob' do
          expect { subject }.not_to have_enqueued_job(
            ::ActiveCampaign::CreateDealJob
          ).with(
            ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS,
            referral_user.id,
            referred_id: user.id
          )
        end
      end
    end
  end
end
