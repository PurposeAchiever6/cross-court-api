require 'rails_helper'

describe UserSessions::WaitlistConfirm do
  let(:user)    { create(:user) }
  let(:session) { create(:session) }
  let(:from_waitlist) { true }

  describe '.call' do
    let!(:user_session) do
      create(:user_session, user:, session:, date: Date.tomorrow)
    end

    before do
      ActiveCampaignMocker.new.mock
      allow(SonarService).to receive(:send_message)
      allow_any_instance_of(SlackService).to receive(:session_waitlist_confirmed)
    end

    subject do
      UserSessions::WaitlistConfirm.call(
        user_session:,
        from_waitlist:
      )
    end

    it { expect { subject }.to change { user_session.reload.state }.to('confirmed') }

    it 'calls Sonar service with the user as argument' do
      expect(SonarService).to receive(:send_message).with(
        user,
        /you made it off the waitlist/
      ).once

      subject
    end

    it 'enques ActiveCampaign::CreateDealJob' do
      expect { subject }.to have_enqueued_job(
        ::ActiveCampaign::CreateDealJob
      ).with(
        ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
        user.id,
        user_session_id: user_session.id
      )
    end

    it 'calls Slack service' do
      expect_any_instance_of(SlackService).to receive(:session_waitlist_confirmed).once

      subject
    end
  end
end
