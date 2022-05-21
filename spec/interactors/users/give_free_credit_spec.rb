require 'rails_helper'

describe Users::GiveFreeCredit do
  describe '.call' do
    let!(:user) { create(:user, free_session_expiration_date: free_session_expiration_date) }
    let!(:location) { create(:location, dtla_coordinates) }

    let(:dtla_coordinates) { { lat: 34.0520842, lng: -118.2273522 } }
    let(:free_session_expiration_date) { nil }

    before do
      Geocoder::Lookup::Test.set_default_stub(
        [{ 'coordinates' => [location.lat, location.lng] }]
      )
    end

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

    context 'when user is not inside the radius for a free session' do
      let(:new_york_coordinates) { [40.7143528, -74.0059731] }

      before do
        Geocoder::Lookup::Test.set_default_stub(
          [{ 'coordinates' => new_york_coordinates }]
        )
      end

      it { expect { subject }.to change { user.reload.free_session_state }.to('not_apply') }

      it { expect { subject }.not_to change { user.reload.credits } }

      it 'does not enque ActiveCampaign::CreateDealJob' do
        expect { subject }.not_to have_enqueued_job(::ActiveCampaign::CreateDealJob)
      end
    end
  end
end
