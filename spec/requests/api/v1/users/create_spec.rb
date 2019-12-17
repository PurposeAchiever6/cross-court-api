require 'rails_helper'

describe 'POST api/v1/users', type: :request do
  let(:user)            { User.last }
  let(:failed_response) { 422 }

  before do
    stub_request(:post, %r{stripe.com/v1/customers})
      .to_return(status: 200, body: File.new('spec/fixtures/customer_creation_ok.json'))
  end

  describe 'POST create' do
    let(:email)                 { 'test@test.com' }
    let(:password)              { '12345678' }
    let(:password_confirmation) { '12345678' }
    let(:name)                  { 'Johnny' }
    let(:phone_number)          { '1234567' }

    let(:params) do
      {
        user: {
          name: name,
          email: email,
          password: password,
          password_confirmation: password_confirmation,
          phone_number: phone_number
        }
      }
    end

    it 'returns a successful response' do
      post user_registration_path, params: params, as: :json

      expect(response).to have_http_status(:success)
    end

    it 'creates the user' do
      expect {
        post user_registration_path, params: params, as: :json
      }.to change(User, :count).by(1)
    end

    it 'returns the user' do
      post user_registration_path, params: params, as: :json

      expect(json[:user][:id]).to eq(user.id)
      expect(json[:user][:email]).to eq(user.email)
      expect(json[:user][:uid]).to eq(user.uid)
      expect(json[:user][:provider]).to eq('email')
      expect(json[:user][:name]).to eq(user.name)
      expect(json[:user][:phone_number]).to eq(user.phone_number)
    end

    context 'when the email is not correct' do
      let(:email) { 'invalid_email' }

      it 'does not create a user' do
        expect {
          post user_registration_path, params: params, as: :json
        }.not_to change { User.count }
      end

      it 'does not return a successful response' do
        post user_registration_path, params: params, as: :json

        expect(response.status).to eq(failed_response)
      end
    end

    context 'when the password is incorrect' do
      let(:password)              { 'short' }
      let(:password_confirmation) { 'short' }
      let(:new_user)              { User.find_by(email: email) }

      it 'does not create a user' do
        post user_registration_path, params: params, as: :json

        expect(new_user).to be_nil
      end

      it 'does not return a successful response' do
        post user_registration_path, params: params, as: :json

        expect(response.status).to eq(failed_response)
      end
    end

    context 'when passwords don\'t match' do
      let(:password)              { 'shouldmatch' }
      let(:password_confirmation) { 'dontmatch' }
      let(:new_user)              { User.find_by(email: email) }

      it 'does not create a user' do
        post user_registration_path, params: params, as: :json

        expect(new_user).to be_nil
      end

      it 'does not return a successful response' do
        post user_registration_path, params: params, as: :json

        expect(response.status).to eq(failed_response)
      end
    end
  end
end
