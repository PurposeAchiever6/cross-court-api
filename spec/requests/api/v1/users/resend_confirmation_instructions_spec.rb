require 'rails_helper'

describe 'POST api/v1/user/resend_confirmation_instructions', type: :request do
  let!(:user)  { create(:user) }
  let(:params) { { email: user.email } }

  subject do
    post resend_confirmation_instructions_api_v1_user_path,
         params:,
         headers: auth_headers,
         as: :json
  end

  context 'when the user is not confirmed' do
    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'sends an email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context 'when the user is already confirmed' do
    before do
      user.update!(confirmed_at: Time.current)
    end

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it "doesn't send the email" do
      expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end
end
