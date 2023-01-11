require 'rails_helper'

describe Users::ClaimFreeSession do
  describe '.call' do
    let!(:user) { create(:user, free_session_state:) }
    let!(:payment_method) { create(:payment_method, user:) }

    let(:free_session_state) { :not_claimed }
    let(:intent_id) { rand(1_000).to_s }

    before do
      allow(StripeService).to receive(:create_free_session_intent).and_return(double(id: intent_id))
    end

    subject { Users::ClaimFreeSession.call(user:, payment_method:) }

    it { expect { subject }.to change { user.reload.free_session_state }.to('claimed') }
    it { expect { subject }.to change { user.reload.free_session_payment_intent }.to(intent_id) }

    it 'does not call Stripe service fetch_payment_methods' do
      expect(StripeService).not_to receive(:fetch_payment_methods)
      subject
    end

    it 'calls Stripe service create_free_session_intent with correct params' do
      expect(
        StripeService
      ).to receive(:create_free_session_intent).with(user, payment_method.stripe_id)
      subject
    end

    context 'when payment_method_id is not passed as argument' do
      let!(:payment_method) { nil }
      let!(:user_payment_method) { create(:payment_method, user:, default: true) }

      it { expect { subject }.to change { user.reload.free_session_state }.to('claimed') }
      it { expect { subject }.to change { user.reload.free_session_payment_intent }.to(intent_id) }

      it 'calls Stripe service create_free_session_intent with correct params' do
        expect(
          StripeService
        ).to receive(:create_free_session_intent).with(user, user_payment_method.stripe_id)
        subject
      end

      context 'when user does not have any payment method' do
        before { user.payment_methods.destroy_all }

        it { expect { subject }.to change { user.reload.free_session_state }.to('claimed') }
        it { expect { subject }.not_to change { user.reload.free_session_payment_intent } }

        it 'does not call Stripe service create_free_session_intent' do
          expect(StripeService).not_to receive(:create_free_session_intent)
          subject
        end
      end
    end

    context 'when Stripe service fails' do
      before do
        allow(StripeService).to receive(:create_free_session_intent).and_raise(Stripe::StripeError)
      end

      it { expect(subject.success?).to eq(false) }
      it { expect { subject }.not_to change { user.reload.free_session_state } }
      it { expect { subject }.not_to change { user.reload.free_session_payment_intent } }
    end

    context 'when user free_session_state is different than not_claimed' do
      let(:free_session_state) { %i[claimed used expired].sample }

      it { expect(subject.success?).to eq(true) }
      it { expect { subject }.not_to change { user.reload.free_session_state } }
      it { expect { subject }.not_to change { user.reload.free_session_payment_intent } }

      it 'does not call Stripe service create_free_session_intent' do
        expect(StripeService).not_to receive(:create_free_session_intent)
        subject
      end
    end
  end
end
