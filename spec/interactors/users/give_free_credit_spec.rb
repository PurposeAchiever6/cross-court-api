require 'rails_helper'

describe Users::GiveFreeCredit do
  describe '.call' do
    let!(:user) do
      create(
        :user,
        free_session_state: free_session_state,
        free_session_expiration_date: free_session_expiration_date
      )
    end

    let(:free_session_state) { :not_claimed }
    let(:free_session_expiration_date) { nil }

    subject { Users::GiveFreeCredit.call(user: user) }

    it { expect { subject }.to change { user.reload.credits }.by(1) }

    it 'updates user free_session_expiration_date' do
      expect {
        subject
      }.to change { user.reload.free_session_expiration_date }.from(nil).to(anything)
    end

    it 'enques ActiveCampaign::CreateDealJob' do
      expect { subject }.to have_enqueued_job(
        ::ActiveCampaign::CreateDealJob
      ).with(::ActiveCampaign::Deal::Event::FIRST_FREE_CREDIT_ADDED, user.id)
    end

    context 'when user free_session_state is different from not_claimed' do
      let(:free_session_state) { %i[claimed used expired].sample }

      it { expect { subject }.not_to change { user.reload.credits } }

      it { expect { subject }.not_to change { user.reload.free_session_expiration_date } }

      it 'does not enque ActiveCampaign::CreateDealJob' do
        expect { subject }.not_to have_enqueued_job(::ActiveCampaign::CreateDealJob)
      end
    end

    context 'when user already has a free_session_expiration_date' do
      let(:free_session_expiration_date) { Time.zone.now }

      it { expect { subject }.not_to change { user.reload.credits } }

      it { expect { subject }.not_to change { user.reload.free_session_expiration_date } }

      it 'does not enque ActiveCampaign::CreateDealJob' do
        expect { subject }.not_to have_enqueued_job(::ActiveCampaign::CreateDealJob)
      end
    end
  end
end
