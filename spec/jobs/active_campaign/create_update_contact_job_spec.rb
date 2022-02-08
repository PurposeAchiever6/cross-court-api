require 'rails_helper'

describe ::ActiveCampaign::CreateUpdateContactJob do
  describe '#perform' do
    let(:user) { create(:user, active_campaign_id: rand(1..10)) }

    subject { described_class.perform_now(user.id) }

    before { ActiveCampaignMocker.new.mock }

    it 'calls the service' do
      expect_any_instance_of(
        ActiveCampaignService
      ).to receive(:create_update_contact).with(user)

      subject
    end
  end
end
