require 'rails_helper'

describe Users::CreatePaymentMethod do
  describe '.call' do
    let!(:user) { create(:user) }

    let(:payment_method_atts) do
      {
        stripe_id: 'stripe-id',
        brand: 'visa',
        exp_month: 9,
        exp_year: 2200,
        last_4: 1234
      }
    end

    before { StripeMocker.new.attach_payment_method(user.stripe_id, payment_method_atts) }

    subject do
      Users::CreatePaymentMethod.call(
        payment_method_stripe_id: payment_method_atts[:stripe_id],
        user: user
      )
    end

    it { expect { subject }.to change(PaymentMethod, :count).by(1) }

    it 'has the expected data' do
      subject
      payment_method = PaymentMethod.last

      expect(payment_method.user).to eq(user)
      expect(payment_method.stripe_id).to eq(payment_method_atts[:stripe_id])
      expect(payment_method.brand).to eq(payment_method_atts[:brand])
      expect(payment_method.exp_month).to eq(payment_method_atts[:exp_month])
      expect(payment_method.exp_year).to eq(payment_method_atts[:exp_year])
      expect(payment_method.last_4).to eq(payment_method_atts[:last_4])
      expect(payment_method.default).to eq(true)
    end

    context 'when there is already a default one' do
      before { create(:payment_method, user: user, default: true) }

      it 'does not assign the new one as default' do
        subject
        payment_method = PaymentMethod.last

        expect(payment_method.default).to eq(false)
      end
    end
  end
end
