require 'rails_helper'

describe UserSessionWaitlistConfirmed do
  let(:user)    { create(:user) }
  let(:session) { create(:session) }

  describe '.save!' do
    let!(:user_session) do
      create(:user_session, user: user, session: session, date: Date.tomorrow)
    end

    before do
      ActiveCampaignMocker.new.mock
      allow(SonarService).to receive(:send_message)
      allow_any_instance_of(SlackService).to receive(:session_waitlist_confirmed)
    end

    subject { UserSessionWaitlistConfirmed.new(user_session).save! }

    it { expect { subject }.to change { user_session.reload.state }.to('confirmed') }

    it 'calls Sonar service with the user as argument' do
      expect(SonarService).to receive(:send_message).with(user, anything).once

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
