require 'rails_helper'

describe Users::CreditsExpirationJob do
  describe '#perform' do
    subject { described_class.perform_now }

    let!(:user_1) do
      create(:user,
             credits: 1,
             free_session_state: 0,
             free_session_expiration_date: Time.zone.today - 4.days)
    end
    let!(:user_2) do
      create(:user,
             credits: 1,
             free_session_state: 0,
             free_session_expiration_date: Time.zone.today + 30.days)
    end
    let!(:user_3) do
      create(:user,
             credits: 1,
             free_session_state: 0,
             drop_in_expiration_date: Time.zone.today - 4.days)
    end

    before do
      ActiveCampaignMocker.new.mock
      ActiveCampaignMocker.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).mock
    end

    it do
      subject
      expect(user_1.reload.credits).to eq(0)
    end

    it do
      subject
      expect(user_1.reload.free_session_state).to eq('expired')
    end

    it do
      subject
      expect(user_2.reload.credits).to eq(1)
    end

    it do
      subject
      expect(user_2.reload.free_session_state).to eq('not_claimed')
    end

    # drop in expiration
    it do
      subject
      expect(user_3.reload.credits).to eq(0)
    end

    context 'when the user has never had a subscription' do
      it 'calls the service' do
        expect_any_instance_of(
          ActiveCampaignService
        ).to receive(:create_deal)
         .with(::ActiveCampaign::Deal::Event::NON_MEMBER_FIRST_DAY_PASS_EXPIRED, user_3)
          .once

        subject
      end
    end
  end
end
