require 'rails_helper'

describe Users::DestroyPaymentMethod do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:payment_method) do
      create(
        :payment_method,
        user:,
        stripe_id:,
        default:
      )
    end

    let(:stripe_id) { 'stripe-id' }
    let(:default) { false }
    let(:payment_method_id) { payment_method.id }
    let(:payment_method_atts) do
      {
        stripe_id:,
        brand: 'visa',
        exp_month: 9,
        exp_year: 2200,
        last_4: 1234
      }
    end

    before { StripeMocker.new.detach_payment_method(user.stripe_id, payment_method_atts) }

    subject do
      Users::DestroyPaymentMethod.call(
        payment_method_id:,
        user:
      )
    end

    it { expect { subject }.to change(PaymentMethod, :count).by(-1) }

    context 'when the deleted is the default' do
      let(:default) { true }
      let!(:payment_method_2) { create(:payment_method, user:) }
      let!(:payment_method_3) { create(:payment_method, user:) }

      it 'assign default to the next most recent one' do
        subject
        expect(user.payment_methods.reload.order(created_at: :desc).first.default).to eq(true)
      end
    end

    context 'when payment method is not found' do
      let(:payment_method_id) { -1 }
      let!(:other_user) { create(:user) }
      let!(:payment_method) { create(:payment_method, user: other_user, stripe_id:) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
      it { expect { subject rescue nil }.not_to change(PaymentMethod, :count) }
    end

    context 'when payment method has an active subscription' do
      let!(:subscription) { create(:subscription, user:, payment_method:) }

      it { expect { subject }.to raise_error(PaymentMethodHasActiveSubscriptionException) }
      it { expect { subject rescue nil }.not_to change(PaymentMethod, :count) }
    end
  end
end
