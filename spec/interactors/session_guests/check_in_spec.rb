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
  end
end
