require 'rails_helper'

describe Subscriptions::CancelSubscriptionAtPeriodEnd do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:subscription) do
      create(
        :subscription,
        user:,
        status:,
        mark_cancel_at_period_end_at:,
        cancel_at_period_end:
      )
    end

    let(:status) { 'active' }
    let(:mark_cancel_at_period_end_at) { Time.zone.today + 1.week }
    let(:cancel_at_period_end) { false }

    before do
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
      StripeMocker.new.cancel_subscription_at_period_end(subscription.stripe_id)
    end

    subject do
      Subscriptions::CancelSubscriptionAtPeriodEnd.call(
        user:,
        subscription:
      )
    end

    it 'updates cancel_at_period_end' do
      expect { subject }.to change {
        subscription.reload.cancel_at_period_end
      }.from(cancel_at_period_end).to(true)
    end

    it 'updates mark_cancel_at_period_end_at' do
      expect { subject }.to change {
        subscription.reload.mark_cancel_at_period_end_at
      }.from(mark_cancel_at_period_end_at).to(nil)
    end

    it 'calls Slack Service' do
      expect_any_instance_of(SlackService).to receive(
        :subscription_canceled
      ).with(subscription)

      subject
    end

    it 'enques ActiveCampaign::CreateDealJob' do
      expect { subject }.to have_enqueued_job(
        ::ActiveCampaign::CreateDealJob
      ).with(
        ::ActiveCampaign::Deal::Event::CANCELLED_MEMBERSHIP,
        user.id,
        cancelled_membership_name: subscription.product.name
      )
    end

    context 'when the subscription is already canceled' do
      let(:status) { 'canceled' }

      it { expect { subject }.to raise_error(SubscriptionIsNotActiveException) }

      it 'does not update cancel_at_period_end' do
        expect { subject rescue nil }.not_to change { subscription.reload.cancel_at_period_end }
      end

      it 'does not update mark_cancel_at_period_end_at' do
        expect {
          subject rescue nil
        }.not_to change { subscription.reload.mark_cancel_at_period_end_at }
      end
    end

    context 'when the subscription will be canceled at period end' do
      let(:cancel_at_period_end) { true }

      it { expect { subject }.to raise_error(SubscriptionIsNotActiveException) }

      it 'does not update cancel_at_period_end' do
        expect { subject rescue nil }.not_to change { subscription.reload.cancel_at_period_end }
      end

      it 'does not update mark_cancel_at_period_end_at' do
        expect {
          subject rescue nil
        }.not_to change { subscription.reload.mark_cancel_at_period_end_at }
      end
    end
  end
end
