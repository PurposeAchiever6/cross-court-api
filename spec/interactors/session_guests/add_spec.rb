require 'rails_helper'

describe SessionGuests::Add do
  describe '.call' do
    let(:guest_info) do
      {
        first_name: 'Mike',
        last_name: 'Lopez',
        phone_number: '+11342214334',
        email: 'mike@mail.com'
      }
    end

    let(:guests_allowed) { 1 }
    let(:guests_allowed_per_user) { 1 }

    before { ENV['MAX_REDEMPTIONS_BY_GUEST'] = '1' }

    let!(:session) { create(:session, guests_allowed:, guests_allowed_per_user:) }
    let!(:user_session) { create(:user_session, session:) }

    subject { SessionGuests::Add.call(user_session:, guest_info:) }

    it { expect { subject }.to change(SessionGuest, :count).by(1) }

    it { expect { subject }.to have_enqueued_job(::Sonar::SendMessageJob) }

    it 'has the expected data' do
      subject
      session_guest = SessionGuest.last

      expect(session_guest.first_name).to eq('Mike')
      expect(session_guest.last_name).to eq('Lopez')
      expect(session_guest.phone_number).to eq('+11342214334')
      expect(session_guest.email).to eq('mike@mail.com')
      expect(session_guest.state).to eq('reserved')
    end

    context 'when guests_allowed is not set' do
      let(:guests_allowed) { nil }

      it do
        expect {
          subject
        }.to raise_error(
          SessionGuestsException,
          I18n.t('api.errors.session_guests.guests_not_allowed')
        )
      end

      it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }
    end

    context 'when the session is already full' do
      let!(:user_sessions) { create_list(:user_session, session.max_capacity - 1, session:) }

      it { expect { subject }.to raise_error(SessionGuestsException, 'Session is full') }

      it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }
    end

    context 'when the session reaches the max guests' do
      let!(:another_user_session) { create(:user_session, session:) }
      let!(:session_guest) { create(:session_guest, user_session: another_user_session) }

      it do
        expect {
          subject
        }.to raise_error(
          SessionGuestsException,
          I18n.t('api.errors.session_guests.max_guests_reached_for_session')
        )
      end

      it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }
    end

    context 'when the user reaches the max guests' do
      let(:guests_allowed) { 2 }
      let!(:session_guest) { create(:session_guest, user_session:) }

      it do
        expect {
          subject
        }.to raise_error(
          SessionGuestsException,
          I18n.t('api.errors.session_guests.max_guests_reached_for_user')
        )
      end

      it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }
    end

    context 'when the guest has already been invited' do
      let(:guests_allowed) { 2 }
      let(:state) { %i[reserved confirmed].sample }
      let!(:session_guest) { create(:session_guest, phone_number: '+11342214334', state:) }

      it do
        expect {
          subject
        }.to raise_error(
          SessionGuestsException,
          I18n.t('api.errors.session_guests.max_redemptions_by_guest_reached')
        )
      end

      it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }

      context 'when the existing session guest has been canceled' do
        let(:state) { :canceled }

        it { expect { subject }.to change(SessionGuest, :count).by(1) }
        it { expect { subject }.to have_enqueued_job(::Sonar::SendMessageJob) }
      end
    end
  end
end
