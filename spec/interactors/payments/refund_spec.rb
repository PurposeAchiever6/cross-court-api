require 'rails_helper'

describe Payments::Refund do
  describe '.call' do
    let!(:payment) { create(:payment, status:, amount:) }

    let(:status) { :success }
    let(:amount) { rand(100..1_000) }
    let(:amount_refunded) { amount }

    subject { Payments::Refund.call(payment:, amount_refunded:) }

    it { expect { subject }.to change { payment.reload.status }.from('success').to('refunded') }

    it 'updates payment amount_refunded column' do
      expect { subject }.to change { payment.reload.amount_refunded }.from(0).to(amount_refunded)
    end

    context 'when it is a partial refund' do
      let(:amount_refunded) { amount - 50 }

      it 'updates payment status column' do
        expect {
          subject
        }.to change { payment.reload.status }.from('success').to('partially_refunded')
      end

      it 'updates payment amount_refunded column' do
        expect { subject }.to change { payment.reload.amount_refunded }.from(0).to(amount_refunded)
      end
    end

    context 'when amount_refunded is zero' do
      let(:amount_refunded) { 0 }

      it { expect { subject }.not_to change { payment.reload.status } }
      it { expect { subject }.not_to change { payment.reload.amount_refunded } }
    end

    context 'when the payment is invalid for refund' do
      let(:status) { %i[error refunded].sample }

      it { expect { subject rescue nil }.not_to change { payment.reload.status } }
      it { expect { subject rescue nil }.not_to change { payment.reload.amount_refunded } }
      it { expect { subject }.to raise_error(PaymentInvalidForRefundException) }
    end
  end
end
