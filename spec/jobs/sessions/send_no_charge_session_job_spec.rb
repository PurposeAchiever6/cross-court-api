require 'rails_helper'

describe Sessions::SendNoChargeSessionJob do
  describe '#perform' do
    let!(:user) { create(:user) }
    let!(:location) { create(:location) }
    let!(:session) do
      create(
        :session,
        :daily,
        time: session_time,
        location:,
        skill_session:,
        is_open_club: open_club,
        is_private:,
        coming_soon:,
        allow_auto_enable_guests:,
        guests_allowed:,
        guests_allowed_per_user:
      )
    end
    let!(:user_subscription) { create(:subscription, user:, product:) }
    let!(:product) { create(:product, no_booking_charge_feature: free_charge) }

    let(:current_time) do
      Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)).change(min: 0)
    end

    let(:session_time) { current_time + product.no_booking_charge_feature_hours.hours }
    let(:date) { current_time.to_date }
    let(:free_charge) { true }
    let(:skill_session) { false }
    let(:open_club) { false }
    let(:is_private) { false }
    let(:coming_soon) { false }
    let(:allow_auto_enable_guests) { false }
    let(:guests_allowed) { nil }
    let(:guests_allowed_per_user) { nil }

    subject { Sessions::SendNoChargeSessionJob.perform_now }

    it 'sends no charge session email' do
      expect { subject }.to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with(
        'SessionMailer',
        'no_charge_session',
        anything,
        {
          params: {
            session_id: session.id,
            user_id: user.id,
            date:
          },
          args: []
        }
      )
    end

    context 'when session minutes time is not the same as current time' do
      let(:session_time) do
        current_time + product.no_booking_charge_feature_hours.hours + 38.minutes
      end

      it 'sends no charge session email' do
        expect { subject }.to have_enqueued_job(
          ActionMailer::MailDeliveryJob
        ).with('SessionMailer', 'no_charge_session', anything, anything)
      end
    end

    context 'when session hours times is not in cancellation period hours' do
      let(:session_time) do
        [
          current_time + product.no_booking_charge_feature_hours.hours + 1.hour,
          current_time + product.no_booking_charge_feature_hours.hours - 1.hour
        ].sample
      end

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when the session allows auto enable guests' do
      let(:allow_auto_enable_guests) { true }

      before do
        ENV['AUTO_ENABLE_GUESTS_ALLOWED'] = '5'
        ENV['AUTO_ENABLE_GUESTS_ALLOWED_PER_USER'] = '1'
      end

      it do
        expect {
          subject
        }.to change { session.reload.guests_allowed }.from(nil).to(5)
      end

      it do
        expect {
          subject
        }.to change { session.reload.guests_allowed_per_user }.from(nil).to(1)
      end
    end

    context 'when the session is a skill session' do
      let!(:skill_session) { true }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when the session is open club' do
      let!(:open_club) { true }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when the session is private' do
      let!(:is_private) { true }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when the session is coming soon' do
      let!(:coming_soon) { true }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when there are already more than 11 reservations for that session' do
      let!(:reservations) { create_list(:user_session, 12, session:, date:) }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when user product does not allow to book with no charge' do
      let!(:free_charge) { false }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when user has already reserved the session' do
      let!(:user_session) do
        create(
          :user_session,
          user:,
          session:,
          date:,
          state:
        )
      end

      let(:state) { %i[reserved confirmed].sample }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }

      context 'when the reservation has been canceled' do
        let(:state) { :canceled }

        it 'sends no charge session email' do
          expect { subject }.to have_enqueued_job(
            ActionMailer::MailDeliveryJob
          ).with('SessionMailer', 'no_charge_session', anything, anything)
        end
      end
    end
  end
end
