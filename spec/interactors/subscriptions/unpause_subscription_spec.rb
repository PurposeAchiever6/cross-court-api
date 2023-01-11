require 'rails_helper'

describe Subscriptions::UnpauseSubscription do
  describe '.call' do
    let(:subscription_status) { 'paused' }
    let!(:subscription) { create(:subscription, status: subscription_status) }
    let!(:subscription_pause) do
      create(:subscription_pause, subscription:, status: :finished)
    end
    let(:user) { subscription.user }
    let(:stripe_invoice_id) { 'il_1Kooo9EbKIwsJiGZ9Ip7Efqr' }

    before do
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
      StripeMocker.new.unpause_subscription(subscription.stripe_id)
      StripeMocker.new.retrieve_invoice(user.stripe_id, stripe_invoice_id)
      user.update!(subscription_credits: 0)
    end

    subject { described_class.call(subscription:) }

    it 'updates subscription status' do
      expect { subject }.to change {
        subscription.reload.status
      }.from(subscription_status).to('active')
    end

    it 'updates subscription_pause unpaused_at attr' do
      expect { subject }.to change {
        subscription_pause.reload.unpaused_at
      }.from(nil).to(anything)
    end

    it 'updates the user credits' do
      expect { subject }.to change {
        user.reload.subscription_credits
      }.from(0).to(subscription.product.credits)
    end

    it 'creates the payment' do
      expect { subject }.to change(Payment, :count).by(1)
    end

    it 'creates a Payment with the expected data' do
      subject
      payment = Payment.last

      expect(payment.amount.to_f).to eq(1239 / 100.00)
      expect(payment.user).to eq(user)
      expect(payment.description).to eq("#{subscription.name} (unpaused)")
      expect(payment.discount.to_f).to eq(123 / 100.00)
      expect(payment.last_4).to eq(subscription.payment_method.last_4)
      expect(payment.stripe_id).to eq('pi_1Kooo9EbKIwsJiGZCM')
      expect(payment.status).to eq('success')
      expect(payment.cc_cash).to eq(0)
    end

    it 'calls Slack Service' do
      expect_any_instance_of(SlackService).to receive(:subscription_unpaused)
      subject
    end

    context 'when the subscription is active' do
      let(:subscription_status) { 'active' }

      it { expect { subject }.to raise_error(SubscriptionIsNotPausedException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.status } }

      it 'does not call Slack Service' do
        expect_any_instance_of(SlackService).not_to receive(:subscription_unpaused)
        subject rescue nil
      end
    end
  end
end
