require 'rails_helper'

describe 'POST api/v1/users', type: :request do
  let(:user)            { User.last }
  let(:failed_response) { 422 }

  before do
    stub_request(:post, %r{stripe.com/v1/customers})
      .to_return(status: 200, body: File.new('spec/fixtures/customer_creation_ok.json'))
    allow_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
    allow(SonarService).to receive(:add_customer).and_return(1)
  end

  describe 'POST create' do
    let(:email)                 { 'test@test.com' }
    let(:password)              { '12345678' }
    let(:password_confirmation) { '12345678' }
    let(:first_name)            { 'Johnny' }
    let(:last_name)             { 'Doe' }
    let(:phone_number)          { '1234567' }
    let(:zipcode)               { '1212121' }

    let(:params) do
      {
        user: {
          first_name: first_name,
          last_name: last_name,
          email: email,
          password: password,
          password_confirmation: password_confirmation,
          phone_number: phone_number,
          zipcode: zipcode
        }
      }
    end

    subject { post user_registration_path, params: params, as: :json }

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'creates the user' do
      expect { subject }.to change(User, :count).by(1)
    end

    it 'returns the user' do
      subject

      expect(json[:user][:id]).to eq(user.id)
      expect(json[:user][:email]).to eq(user.email)
      expect(json[:user][:uid]).to eq(user.uid)
      expect(json[:user][:provider]).to eq('email')
      expect(json[:user][:first_name]).to eq(user.first_name)
      expect(json[:user][:last_name]).to eq(user.last_name)
      expect(json[:user][:phone_number]).to eq(user.phone_number)
      expect(json[:user][:zipcode]).to eq(user.zipcode)
    end

    it 'calls the klaviyo service' do
      expect_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
      subject
    end

    it 'calls the sonar service' do
      expect(SonarService).to receive(:add_customer).and_return(1)
      subject
    end

    context 'when the email is not correct' do
      let(:email) { 'invalid_email' }

      it 'does not create a user' do
        expect { subject }.not_to change { User.count }
      end

      it 'does not return a successful response' do
        subject
        expect(response.status).to eq(failed_response)
      end
    end

    context 'when the password is incorrect' do
      let(:password)              { 'short' }
      let(:password_confirmation) { 'short' }
      let(:new_user)              { User.find_by(email: email) }

      it 'does not create a user' do
        subject
        expect(new_user).to be_nil
      end

      it 'does not return a successful response' do
        subject
        expect(response.status).to eq(failed_response)
      end
    end

    context 'when passwords don\'t match' do
      let(:password)              { 'shouldmatch' }
      let(:password_confirmation) { 'dontmatch' }
      let(:new_user)              { User.find_by(email: email) }

      it 'does not create a user' do
        subject
        expect(new_user).to be_nil
      end

      it 'does not return a successful response' do
        subject
        expect(response.status).to eq(failed_response)
      end
    end
  end
end
