require 'rails_helper'

describe SessionGuests::NoShowUpJob do
  describe '#perform' do
    before do
      ActiveCampaignMocker.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).mock
    end

    let(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:date) { la_time.yesterday }

    let(:user_session_1) { create(:user_session, :confirmed, date: la_time.yesterday) }
    let(:user_session_2) { create(:user_session, :confirmed, date: la_time.yesterday) }
    let(:user_session_3) { create(:user_session, :confirmed, date: la_time + 2.days) }

    let!(:session_guest_1) { create(:session_guest, :reserved, user_session: user_session_1) }
    let!(:session_guest_2) { create(:session_guest, :confirmed, user_session: user_session_2) }
    let!(:session_guest_3) { create(:session_guest, :reserved, user_session: user_session_3) }

    subject { described_class.perform_now }

    it { expect { subject }.to change { session_guest_1.reload.state }.to('no_show') }
    it { expect { subject }.not_to change { session_guest_2.reload.state } }
    it { expect { subject }.not_to change { session_guest_3.reload.state } }

    it 'calls AC' do
      expect_any_instance_of(ActiveCampaignService).to receive(:create_deal).once

      subject
    end

    context 'when the guest has created an user' do
      before { create(:user, phone_number: session_guest_1.phone_number) }

      it { expect { subject }.to change { session_guest_1.reload.state }.to('no_show') }

      it 'not calls AC' do
        expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal).once

        subject
      end
    end

    context 'is not guest first time' do
      before { create(:session_guest, phone_number: session_guest_1.phone_number) }

      it { expect { subject }.to change { session_guest_1.reload.state }.to('no_show') }

      it 'not calls AC' do
        expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal).once

        subject
      end
    end
  end
end
