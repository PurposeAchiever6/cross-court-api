require 'rails_helper'

describe 'PUT api/v1/purchases/create_free_session_intent' do
  let(:user)   { create(:user) }
  let(:params) { { payment_method: 'pm123456789' } }

  before do
    stub_request(:post, %r{stripe.com/v1/payment_intents})
      .to_return(status: 200, body: File.new('spec/fixtures/charge_succeeded.json'))
    allow_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
  end

  subject do
    put create_free_session_intent_api_v1_purchases_path, params: params, headers: auth_headers, as: :json
  end

  context "when the user hasn't claimed the free session" do
    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'updates user free_session_status' do
      expect { subject }.to change { user.reload.free_session_state }
        .from('not_claimed').to('claimed')
    end

    it 'updates user free_session_payment_intent' do
      expect { subject }.to change { user.reload.free_session_payment_intent }
    end

    it 'calls the klaviyo service' do
      expect_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
      subject
    end
  end

  context 'when the user has already claimed the free session' do
    before do
      user.free_session_claimed!
    end

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it "doesn't increment user credits" do
      expect { subject }.not_to change { user.reload.credits }
    end

    it "doesn't update user free_session_status" do
      expect { subject }.not_to change { user.reload.free_session_state }
    end
  end
end