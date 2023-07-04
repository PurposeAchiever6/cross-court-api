require 'rails_helper'

describe 'PUT api/v1/user_sessions/:user_session_id/cancel' do
  let(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end
  let(:late_cancellation_fee) { rand(1..10) }
  let(:late_cancellation_reimburse_credit) { false }
  let!(:location) { create(:location, late_cancellation_fee:, late_cancellation_reimburse_credit:) }

  before do
    allow_any_instance_of(SlackService).to receive(:session_canceled_in_time).and_return(1)
    allow_any_instance_of(SlackService).to receive(:session_canceled_out_of_time).and_return(1)
    Timecop.freeze(Time.current)
    ActiveCampaignMocker.new.mock
  end

  after do
    Timecop.return
  end

  let!(:user) { create(:user) }

  subject do
    put api_v1_user_session_cancel_path(user_session), headers: auth_headers, as: :json
    response
  end

  context 'when in valid cancellation time' do
    let(:time) { los_angeles_time + Session::CANCELLATION_PERIOD + 1.minute }
    let(:session) { create(:session, :daily, location:, time:) }
    let!(:user_session) { create(:user_session, user:, session:) }

    it { is_expected.to be_successful }

    it 'changes the user_session state to canceled' do
      expect { subject }.to change { user_session.reload.state }.from('reserved').to('canceled')
    end

    it 'reimburses the credit to the user' do
      expect { subject }.to change { user.reload.credits }.from(0).to(1)
    end

    it 'sets user_session credit_reimbursed to true' do
      expect { subject }.to change { user_session.reload.credit_reimbursed }.from(false).to(true)
    end

    it 'calls the slack service session_canceled_in_time method' do
      expect_any_instance_of(SlackService).to receive(:session_canceled_in_time).and_return(1)
      subject
    end

    it 'calls the Active Campaign service' do
      expect { subject }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default')
    end

    it 'calls waitlist job' do
      expect { subject }.to have_enqueued_job(Sessions::ReachUserOnWaitlistJob).with(
        session.id,
        user_session.date
      ).on_queue('default')
    end
  end

  context 'when not in valid cancellation time' do
    let(:time) { los_angeles_time + Session::CANCELLATION_PERIOD - 1.minute }
    let(:session) { create(:session, :daily, location:, time:) }
    let!(:user_session) { create(:user_session, user:, session:) }
    let!(:user_payment_method) { create(:payment_method, user:, default: true) }

    before { allow(StripeService).to receive(:charge).and_return(double(id: rand(1_000))) }

    it { is_expected.to be_successful }

    it 'changes the user_session state' do
      expect { subject }.to change { user_session.reload.state }.from('reserved').to('canceled')
    end

    it { expect { subject }.not_to change { user.reload.credits } }

    it 'calls Stripe service' do
      expect(StripeService).to receive(:charge).with(
        user,
        user_payment_method.stripe_id,
        late_cancellation_fee,
        'Session canceled out of time fee'
      )
      subject
    end

    it 'calls the slack service session_canceled_out_of_time method' do
      expect_any_instance_of(SlackService).to receive(:session_canceled_out_of_time).and_return(1)
      subject
    end

    it 'calls waitlist job' do
      expect { subject }.to have_enqueued_job(Sessions::ReachUserOnWaitlistJob).with(
        session.id,
        user_session.date
      ).on_queue('default')
    end

    context 'when late_cancellation_reimburse_credit is true' do
      let(:late_cancellation_reimburse_credit) { true }

      it { is_expected.to be_successful }

      it 'changes the user_session state' do
        expect { subject }.to change { user_session.reload.state }.from('reserved').to('canceled')
      end

      it { expect { subject }.to change { user.reload.credits }.by(1) }

      it 'calls Stripe service' do
        expect(StripeService).to receive(:charge).with(
          user,
          user_payment_method.stripe_id,
          late_cancellation_fee,
          'Session canceled out of time fee'
        )
        subject
      end

      it 'calls the slack service session_canceled_out_of_time method' do
        expect_any_instance_of(SlackService).to receive(:session_canceled_out_of_time).and_return(1)
        subject
      end

      it 'calls waitlist job' do
        expect { subject }.to have_enqueued_job(Sessions::ReachUserOnWaitlistJob).with(
          session.id,
          user_session.date
        ).on_queue('default')
      end
    end
  end

  context "when the user_session_id doesn't exists" do
    let(:user_session) { 'not_found' }

    it { is_expected.to have_http_status(:not_found) }
  end
end
