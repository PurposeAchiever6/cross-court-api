require 'rails_helper'

describe Users::GetPaymentMethods do
  describe '.call' do
    let!(:user) { create(:user) }
    let(:user_payment_methods) { %i[pm_1 pm_2] }

    before do
      allow(StripeService).to receive(:fetch_payment_methods).and_return(user_payment_methods)
    end

    subject { Users::GetPaymentMethods.call(user: user) }

    it { expect(subject.payment_methods).to eq(user_payment_methods) }
    it { expect(subject.default_payment_method).to eq(:pm_1) }

    it 'calls Stripe service with correct params' do
      expect(StripeService).to receive(:fetch_payment_methods).with(user)
      subject
    end
  end
end
