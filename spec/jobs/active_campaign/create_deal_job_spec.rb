require 'rails_helper'

describe ::ActiveCampaign::CreateDealJob do
  describe '#perform' do
    let(:user) { create(:user) }
    let(:pipeline_name) { ::ActiveCampaign::Deal::Pipeline::EMAILS }
    let(:event) do
      ::ActiveCampaign::Deal::Event.const_get(::ActiveCampaign::Deal::Event.constants.sample)
    end

    before { ActiveCampaignMocker.new(pipeline_name: pipeline_name).mock }

    context 'when args and pipeline_name are not passed' do
      subject { described_class.perform_now(event, user.id) }

      it 'calls the service' do
        expect_any_instance_of(
          ActiveCampaignService
        ).to receive(:create_deal).with(event, user, {})

        subject
      end

      it 'initialize the service with the correct pipeline' do
        expect(
          ActiveCampaignService
        ).to receive(:new)
          .with(pipeline_name: ::ActiveCampaign::Deal::Pipeline::EMAILS).and_call_original

        subject
      end
    end

    context 'when args are passed' do
      let(:args) { { arg1: 'sample1', arg2: 'sample2' } }

      subject { described_class.perform_now(event, user.id, args) }

      it 'calls the service' do
        expect_any_instance_of(
          ActiveCampaignService
        ).to receive(:create_deal).with(event, user, args)

        subject
      end

      it 'initialize the service with the correct pipeline' do
        expect(
          ActiveCampaignService
        ).to receive(:new)
          .with(pipeline_name: ::ActiveCampaign::Deal::Pipeline::EMAILS).and_call_original

        subject
      end
    end

    context 'when pipeline_name is passed' do
      let(:args) { {} }
      let(:pipeline_name) { ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL }

      subject { described_class.perform_now(event, user.id, args, pipeline_name) }

      it 'calls the service' do
        expect_any_instance_of(
          ActiveCampaignService
        ).to receive(:create_deal).with(event, user, args)

        subject
      end

      it 'initialize the service with the correct pipeline' do
        expect(
          ActiveCampaignService
        ).to receive(:new).with(pipeline_name: pipeline_name).and_call_original

        subject
      end
    end
  end
end
