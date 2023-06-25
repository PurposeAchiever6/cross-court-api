require 'rails_helper'

describe ReferralCashPayments::Ignore do
  describe '.call' do
    let!(:referral_cash_payment) { create(:referral_cash_payment, status:) }
    let(:status) { :pending }

    subject { ReferralCashPayments::Ignore.call(referral_cash_payment:) }

    it { expect { subject }.to change { referral_cash_payment.reload.status }.to('ignored') }

    context 'when referral_cash_payment is not pending' do
      let(:status) { %i[paid ignored].sample }

      it { expect { subject rescue nil }.not_to change { referral_cash_payment.reload.status } }

      it 'raises error ReferralCashPaymentIsNotPendingException' do
        expect {
          subject
        }.to raise_error(
          ReferralCashPaymentIsNotPendingException,
          'The referral payment status should be pending'
        )
      end
    end
  end
end
