require 'rails_helper'

describe EmailToInactiveUsersJob do
  describe '.perform' do
    let!(:session) { create(:session) }
    let!(:user) { create(:user, credits: user_credits) }

    let!(:user_session_1) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: true,
        date: Time.zone.today - 1.month
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: true,
        date: Time.zone.today - 14.days
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: false,
        date: Time.zone.today + 2.days,
        state: :canceled
      )
    end

    let(:user_credits) { 0 }

    subject { described_class.perform_now }

    it 'calls Klaviyo with the correct parameters' do
      expect_any_instance_of(KlaviyoService).to receive(:event).with(Event::TIME_TO_RE_UP, user).once
      subject
    end

    context 'when user has a future session' do
      let!(:user_session_4) do
        create(
          :user_session,
          user: user,
          session: session,
          checked_in: false,
          date: Time.zone.today + 4.days,
          state: :reserved
        )
      end

      it 'do not call KlaviyoService' do
        expect_any_instance_of(KlaviyoService).not_to receive(:event).with(Event::TIME_TO_RE_UP, user)
        subject
      end
    end

    context 'when the user last checked in session was before 14 days ago' do
      let!(:user_session_4) do
        create(
          :user_session,
          user: user,
          session: session,
          checked_in: true,
          date: Time.zone.today - 5.days
        )
      end

      it 'do not call KlaviyoService' do
        expect_any_instance_of(KlaviyoService).not_to receive(:event).with(Event::TIME_TO_RE_UP, user)
        subject
      end
    end

    context 'when user has at least one credit' do
      let(:user_credits) { rand(1..10) }

      it 'do not call KlaviyoService' do
        expect_any_instance_of(KlaviyoService).not_to receive(:event).with(Event::TIME_TO_RE_UP, user)
        subject
      end
    end
  end
end
