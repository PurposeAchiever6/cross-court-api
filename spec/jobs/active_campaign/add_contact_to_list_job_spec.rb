require 'rails_helper'

describe ::ActiveCampaign::AddContactToListJob do
  describe '#perform' do
    let(:list_name) { ::ActiveCampaign::Contact::List::MASTER_LIST }
    let(:user) { create(:user, active_campaign_id: rand(1..10)) }

    subject { described_class.perform_now(list_name, user.active_campaign_id) }

    before { ActiveCampaignMocker.new.mock }

    it 'calls the service' do
      expect_any_instance_of(
        ActiveCampaignService
      ).to receive(:add_contact_to_list).with(list_name, user.active_campaign_id)

      subject
    end
  end
end
