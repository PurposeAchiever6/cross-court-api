require 'rails_helper'

describe ::Sonar::FirstSessionSmsJob do
  describe '#perform' do
    let(:la_time)  { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let!(:la_date) { la_time.to_date }
    let!(:session) { create(:session) }

    let!(:user_session_1) do
      create(
        :user_session,
        session:,
        checked_in: true,
        date: la_date,
        state: :confirmed,
        first_session: true
      )
    end
    let!(:user_1) { user_session_1.user }

    let!(:user_session_2) do
      create(
        :user_session,
        session:,
        checked_in: true,
        date: la_date,
        state: :confirmed,
        first_session: false
      )
    end
    let!(:user_2) { user_session_2.user }

    before do
      allow(SonarService).to receive(:send_message)
    end

    subject { described_class.perform_now([user_session_1.id, user_session_2.id]) }

    it 'calls Sonar service' do
      expect(SonarService).to receive(:send_message).once.with(
        user_1,
        "Hey #{user_1.first_name}! If you loved your experience, then stop by the front desk on " \
        "your way out to learn about a discount for your first month of membership!\n"
      )
      subject
    end
  end
end
