require 'rails_helper'

describe CreditsJob do
  describe '#perform' do
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
      described_class.perform_now
    end

    it { expect(user_1.reload.credits).to eq(0) }
    it { expect(user_1.reload.free_session_state).to eq('expired') }

    it { expect(user_2.reload.credits).to eq(1) }
    it { expect(user_2.reload.free_session_state).to eq('not_claimed') }

    it { expect(user_1.reload.credits).to eq(0) }
  end
end