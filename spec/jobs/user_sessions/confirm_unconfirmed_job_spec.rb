require 'rails_helper'

describe UserSessions::ConfirmUnconfirmedJob do
  describe '#perform' do
    before do
      ENV['CANCELLATION_PERIOD'] = '1'
      ActiveCampaignMocker.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).mock
      allow(SonarService).to receive(:send_message)
    end

    let(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:la_date) { la_time.to_date }

    let(:time) { la_time + 30.minutes }

    let(:session) { create(:session, time: time) }
    let!(:user) { create(:user) }

    let(:reminder_sent_at) { nil }

    let!(:user_session_1) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: true,
        date: la_date.yesterday,
        state: :confirmed
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: false,
        date: la_date,
        state: :reserved,
        reminder_sent_at: reminder_sent_at
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: false,
        date: la_date.tomorrow,
        state: :reserved
      )
    end

    subject { described_class.perform_now }

    it { expect { subject }.not_to change { user_session_1.reload.state } }
    it { expect { subject }.to change { user_session_2.reload.state }.to('confirmed') }
    it { expect { subject }.not_to change { user_session_3.reload.state } }

    it { expect { subject }.not_to change { user_session_1.reload.reminder_sent_at } }
    it { expect { subject }.to change { user_session_2.reload.reminder_sent_at } }
    it { expect { subject }.not_to change { user_session_3.reload.reminder_sent_at } }

    it 'enques ActiveCampaign CreateDealJob' do
      expect {
        subject
      }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default').once
    end

    it 'sends sonar message' do
      expect(SonarService).to receive(:send_message).with(user, anything).once
      subject
    end

    context 'when the reminder has already been sent' do
      let(:reminder_sent_at) { la_time - 10.minutes }

      it { expect { subject }.to change { user_session_2.reload.state }.to('confirmed') }
      it { expect { subject }.not_to change { user_session_2.reload.reminder_sent_at } }

      it 'enques ActiveCampaign CreateDealJob' do
        expect {
          subject
        }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default').once
      end

      it 'does not send sonar message' do
        expect(SonarService).not_to receive(:send_message)
        subject
      end
    end

    context 'when the session is open club' do
      let(:session) { create(:session, time: time, is_open_club: true) }

      let!(:user_session_1) do
        create(
          :user_session,
          user: user,
          session: session,
          checked_in: true,
          date: la_date.yesterday,
          state: :confirmed
        )
      end

      let!(:user_session_2) do
        create(
          :user_session,
          user: user,
          session: session,
          checked_in: false,
          date: la_date,
          state: :reserved
        )
      end

      it { expect { subject }.not_to change { user_session_1.reload.state } }
      it { expect { subject }.to change { user_session_2.reload.state }.to('confirmed') }

      it { expect { subject }.not_to change { user_session_1.reload.reminder_sent_at } }
      it { expect { subject }.not_to change { user_session_2.reload.reminder_sent_at } }

      it 'enques ActiveCampaign CreateDealJob' do
        expect {
          subject
        }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default').once
      end

      it 'does not send sonar message' do
        expect(SonarService).not_to receive(:send_message)
        subject
      end
    end
  end
end
