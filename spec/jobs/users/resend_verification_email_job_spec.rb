require 'rails_helper'

describe Users::ResendVerificationEmailJob do
  describe '#perform' do
    before do
      ActiveCampaignMocker.new.mock
    end

    subject { described_class.perform_now(user.id) }

    context 'when the user is confirmed' do
      let!(:user) { create(:user, :confirmed) }

      it do
        expect_any_instance_of(User).not_to receive(:send_confirmation_instructions)
        expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)
        subject
      end
    end

    context 'when the user is not confirmed' do
      let!(:user) { create(:user, :unconfirmed) }

      it do
        expect_any_instance_of(User).to receive(:send_confirmation_instructions)
        expect_any_instance_of(ActiveCampaignService).to receive(:create_deal)
        subject
      end
    end
  end
end
