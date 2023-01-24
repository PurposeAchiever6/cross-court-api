require 'rails_helper'

describe SessionGuests::Remove do
  describe '.call' do
    let!(:user_session) { create(:user_session) }
    let!(:session_guest) { create(:session_guest, user_session:) }

    subject do
      SessionGuests::Remove.call(user_session:, session_guest_id: session_guest.id)
    end

    it do
      expect { subject }.to change { session_guest.reload.state }.from('reserved').to('canceled')
    end

    it { expect { subject }.to have_enqueued_job(::Sonar::SendMessageJob) }
  end
end
