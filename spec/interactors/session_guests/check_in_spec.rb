require 'rails_helper'

describe SessionGuests::CheckIn do
  describe '.call' do
    let!(:session_guest) { create(:session_guest) }

    let!(:checked_in) { true }
    let!(:assigned_team) { 'dark' }

    subject do
      SessionGuests::CheckIn.call(session_guest:, checked_in:, assigned_team:)
    end

    it 'updates session guest checked_in column' do
      expect { subject }.to change { session_guest.reload.checked_in }.from(false).to(checked_in)
    end

    it 'updates session guest assigned_team column' do
      expect {
        subject
      }.to change { session_guest.reload.assigned_team }.from(nil).to(assigned_team)
    end

    context 'when is the first time invited as a session guest' do
      it 'enqueues ActiveCampaign::NoPurchasePlacedAfterGuestCheckInJob' do
        expect {
          subject
        }.to have_enqueued_job(::ActiveCampaign::NoPurchasePlacedAfterGuestCheckInJob)
          .with(session_guest.id)
          .on_queue('default')
          .at_least(:once)
      end
    end

    context 'when is not the first time invited as a session guest' do
      before { create(:session_guest, phone_number: session_guest.phone_number) }

      it 'enqueues ActiveCampaign::NoPurchasePlacedAfterGuestCheckInJob' do
        expect {
          subject
        }.not_to have_enqueued_job(::ActiveCampaign::NoPurchasePlacedAfterGuestCheckInJob)
      end
    end
  end
end
