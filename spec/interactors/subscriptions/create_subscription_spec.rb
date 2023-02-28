require 'rails_helper'

describe Subscriptions::CreateSubscription do
  describe '.call' do
    let!(:user) { create(:user, reserve_team:) }
    let!(:payment_method) { create(:payment_method, user:) }
    let!(:product) { create(:product, available_for:) }
    let(:promo_code) { nil }
    let(:stripe_response_status) { 'active' }
    let(:stripe_invoice_id) { 'in_1Fin1BEbKIwsJiGZiMSDSLzw' }
    let(:reserve_team) { false }
    let(:available_for) { :everyone }

    let(:stripe_response) do
      {
        id: 'stripe-subscription-id',
        items: double(data: [double(id: 'stripe-subscription-item-id')]),
        status: stripe_response_status,
        current_period_start: Time.current.to_i,
        current_period_end: 1.month.from_now.to_i,
        cancel_at: nil,
        canceled_at: nil,
        cancel_at_period_end: false,
        pause_collection: nil,
        latest_invoice: stripe_invoice_id
      }
    end

    before do
      allow(StripeService).to receive(:create_subscription).and_return(double(stripe_response))
      StripeMocker.new.retrieve_invoice(user.stripe_id, stripe_invoice_id)
    end

    subject do
      Subscriptions::CreateSubscription.call(
        user:,
        product:,
        payment_method:,
        promo_code:,
        amount: product.price
      )
    end

    it { expect { subject }.to change(Subscription, :count).by(1) }

    it 'assigns the payment method to the subscription' do
      subject
      expect(Subscription.last.payment_method).to eq(payment_method)
    end

    it 'calls the stripes create_subscription method with the correct params' do
      expect(StripeService).to receive(
        :create_subscription
      ).with(user, product, payment_method.stripe_id, promo_code)
      subject
    end

    it 'enques Subscriptions::FirstMonthSurveyEmailJob' do
      expect { subject }.to have_enqueued_job(
        ::Subscriptions::FirstMonthSurveyEmailJob
      ).once.with { |subscription_id| subscription_id == Subscription.last.id }
    end

    context 'when is not the first subscription' do
      before { create(:subscription, status: :canceled, user:) }

      it { expect { subject }.not_to have_enqueued_job(::Subscriptions::FirstMonthSurveyEmailJob) }
    end

    context 'when user already has an active subscription' do
      let!(:active_subscription) { create(:subscription, user:, product:) }

      it { expect(subject.success?).to eq(false) }
      it { expect { subject }.not_to change(Subscription, :count) }
    end

    context 'when stripe subscription returns with incomplete status' do
      let(:stripe_response_status) { 'incomplete' }

      it { expect(subject.success?).to eq(false) }
      it { expect { subject }.not_to change(Subscription, :count) }
    end

    context 'when the user is not Reserve Team and the subscription is' do
      let(:available_for) { :reserve_team }

      it { expect { subject }.to raise_error(ReserveTeamMismatchException) }
      it { expect { subject rescue nil }.not_to change(Subscription, :count) }
    end

    context 'when the user is Reserve Team and the subscription is not' do
      let(:reserve_team) { true }

      it { expect { subject }.to raise_error(ReserveTeamMismatchException) }
      it { expect { subject rescue nil }.not_to change(Subscription, :count) }
    end
  end
end
