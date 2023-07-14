require 'rails_helper'

describe ::ActiveCampaign::CreateUpdateContactAndAddToListJob do
  describe '#perform' do
    let(:list_name) { ::ActiveCampaign::Contact::List::MASTER_LIST }
    let(:ac_id) { rand(1..5) }

    before do
      allow_any_instance_of(ActiveCampaignService).to receive(:create_update_contact).and_return(
        { contact: { id: ac_id } }.with_indifferent_access
      )
      ActiveCampaignMocker.new.mock
    end

    subject { described_class.perform_now(user_id, user_attrs) }

    context 'when a user is pased' do
      let(:user) { create(:user, active_campaign_id: ac_id) }
      let(:user_id) { user.id }
      let(:user_attrs) { nil }

      it 'creates the user in AC' do
        expect_any_instance_of(ActiveCampaignService).to receive(:create_update_contact).with(user)

        subject
      end

      it 'adds the user to a list' do
        expect_any_instance_of(
          ActiveCampaignService
        ).to receive(:add_contact_to_list).with(list_name, user.active_campaign_id)

        subject
      end
    end

    context 'when user attributes are pased' do
      let(:user_id) { nil }
      let(:user_attrs) do
        {
          first_name: 'Mike',
          last_name: 'Lopez',
          phone_number: '+11342214334',
          email: 'mike@mail.com'
        }
      end

      it 'creates the user in AC' do
        expect_any_instance_of(ActiveCampaignService).to receive(:create_update_contact)

        subject
      end

      it 'adds the user to a list' do
        expect_any_instance_of(
          ActiveCampaignService
        ).to receive(:add_contact_to_list).with(list_name, ac_id)

        subject
      end
    end
  end
end
