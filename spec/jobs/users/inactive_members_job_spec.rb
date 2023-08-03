require 'rails_helper'

describe Users::InactiveMembersJob do
  describe '.perform' do
    let!(:session) { create(:session) }
    let!(:user) { create(:user) }
    let!(:product) { create(:product, credits: rand(4..8)) }

    let!(:active_subscription) do
      create(
        :subscription,
        user:,
        product:,
        current_period_end: active_subscription_current_period_end
      )
    end

    let!(:last_checked_in_user_session) do
      create(
        :user_session,
        user:,
        session:,
        checked_in: true,
        date: Time.zone.today - date_ago_last_session
      )
    end

    let(:active_subscription_current_period_end) { 2.weeks.from_now }
    let(:date_ago_last_session) { 1.week }
    let(:user_subscription_credits) { product.credits / 2 }

    let(:credits_left_reminder_msg) do
      I18n.t(
        'notifier.sonar.subscription_credits_left_reminder',
        name: user.first_name,
        credits_left: user_subscription_credits,
        end_date: active_subscription_current_period_end.strftime('%e of %B'),
        schedule_url: "#{ENV.fetch('FRONTENT_URL', nil)}/locations"
      )
    end

    let(:book_reminder_msg) do
      I18n.t(
        'notifier.sonar.active_subscription_book_reminder',
        name: user.first_name,
        schedule_url: "#{ENV.fetch('FRONTENT_URL', nil)}/locations"
      )
    end

    before do
      user.update!(subscription_credits: user_subscription_credits)
      allow(SendSonar).to receive(:message_customer)
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
      ActiveCampaignMocker.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).mock
    end

    subject { described_class.perform_now }

    it 'sends credits left reminder message' do
      expect(SonarService).to receive(:send_message).with(user, credits_left_reminder_msg).once
      subject
    end

    it 'sends member credits left slack message' do
      expect_any_instance_of(SlackService).to receive(
        :member_with_credits_left
      ).with(
        subscription_name: product.name,
        credits_used: product.credits - user_subscription_credits
      )
      subject
    end

    it 'creates Active Campaign deal' do
      expect_any_instance_of(ActiveCampaignService).to receive(:create_deal).with(
        ::ActiveCampaign::Deal::Event::AT_RISK_MEMBERS, user
      )
      subject
    end

    context 'when user is not a member' do
      before { active_subscription.destroy }

      it 'does not send credits left reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, credits_left_reminder_msg)
        subject
      end

      it 'does not send book reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
        subject
      end
    end

    context 'when user has a future session reserved' do
      let!(:first_future_user_session) do
        create(
          :user_session,
          user:,
          session:,
          checked_in: false,
          date: Time.zone.today + rand(1..10).days
        )
      end

      it 'does not send credits left reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, credits_left_reminder_msg)
        subject
      end

      it 'does not send book reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
        subject
      end
    end

    context 'when user has never played a session' do
      before { last_checked_in_user_session.destroy }

      it 'does not send credits left reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, credits_left_reminder_msg)
        subject
      end

      it 'does not send book reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
        subject
      end
    end

    context 'when active subscription is unlimited' do
      let!(:product) { create(:product, :unlimited) }

      it 'does not send credits left reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, credits_left_reminder_msg)
        subject
      end

      it 'sends book reminder message' do
        expect(SonarService).to receive(:send_message).with(user, book_reminder_msg).once
        subject
      end

      context 'when user last checked in session was not one week ago' do
        let(:date_ago_last_session) { 1.week + [-1.day, 1.day].sample }

        it 'does not send book reminder message' do
          expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
          subject
        end
      end

      context 'when user has zero credits' do
        let(:user_subscription_credits) { 0 }

        it 'does not send book reminder message' do
          expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
          subject
        end
      end
    end

    context 'when user has used his subscription credits' do
      let(:user_subscription_credits) { (product.credits / 2) - 1 }

      it 'does not send credits left reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, credits_left_reminder_msg)
        subject
      end

      it 'sends book reminder message' do
        expect(SonarService).to receive(:send_message).with(user, book_reminder_msg).once
        subject
      end

      context 'when user last checked in session was not one week ago' do
        let(:date_ago_last_session) { 1.week + [-1.day, 1.day].sample }

        it 'does not send book reminder message' do
          expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
          subject
        end
      end

      context 'when user has zero credits' do
        let(:user_subscription_credits) { 0 }

        it 'does not send book reminder message' do
          expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
          subject
        end
      end
    end

    context 'when subscription perdiod end is not in two weeks' do
      let(:active_subscription_current_period_end) { 2.weeks.from_now + [-1.day, 1.day].sample }

      it 'does not send credits left reminder message' do
        expect(SonarService).not_to receive(:send_message).with(user, credits_left_reminder_msg)
        subject
      end

      it 'sends book reminder message' do
        expect(SonarService).to receive(:send_message).with(user, book_reminder_msg).once
        subject
      end

      context 'when user last checked in session was not one week ago' do
        let(:date_ago_last_session) { 1.week + [-1.day, 1.day].sample }

        it 'does not send book reminder message' do
          expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
          subject
        end
      end

      context 'when user has zero credits' do
        let(:user_subscription_credits) { 0 }

        it 'does not send book reminder message' do
          expect(SonarService).not_to receive(:send_message).with(user, book_reminder_msg)
          subject
        end
      end
    end
  end
end
