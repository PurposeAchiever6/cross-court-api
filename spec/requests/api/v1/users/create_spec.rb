require 'rails_helper'

describe 'POST api/v1/users', type: :request do
  let(:user) { User.last }

  before do
    stub_request(:post, %r{stripe.com/v1/customers})
      .to_return(status: 200, body: File.new('spec/fixtures/customer_creation_ok.json'))
    ActiveCampaignMocker.new.mock
    Timecop.freeze.change(hour: 10)
  end

  after { Timecop.return }

  describe 'POST create' do
    let(:email) { Faker::Internet.email }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:phone_number) { Faker::PhoneNumber.cell_phone }
    let(:params) { { user: { email:, first_name:, last_name:, phone_number: } } }

    subject { post user_registration_path, params:, as: :json }

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
      expect(json[:user][:first_name]).to eq(user.first_name)
      expect(json[:user][:last_name]).to eq(user.last_name)
      expect(json[:user][:phone_number]).to eq(user.phone_number)
    end

    it 'calls the active campaign service' do
      expect_any_instance_of(ActiveCampaignService).to receive(:create_update_contact)
      subject
    end

    it 'calls the active campaign service to create the deal' do
      expect { subject }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default')
    end

    it 'calls the sonar service' do
      expect(SonarService).to receive(:add_update_customer).and_return(1)
      subject
    end

    context 'when the email is not correct' do
      let(:email) { 'invalid_email' }

      it 'does not create a user' do
        expect { subject }.not_to change { User.count }
      end

      it 'does not return a successful response' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the communication with an external service fails' do
      before do
        allow_any_instance_of(
          ActiveCampaignService
        ).to receive(:create_update_contact).and_raise(ActiveCampaignException, 'error')
      end

      it 'return an json error' do
        subject
        expect(response).to have_http_status(:conflict)
      end

      it { expect { subject }.not_to change { User.count } }
    end
  end
end
