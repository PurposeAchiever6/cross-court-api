require 'rails_helper'

describe 'PUT api/v1/user/', type: :request do
  let!(:user) { create(:user, gender: :male) }

  let(:first_name) { 'Johnny' }
  let(:last_name) { 'Doe' }
  let(:phone_number) { '1234567' }
  let(:zipcode) { '12345' }
  let(:birthday) { Time.zone.today - 25.years }
  let(:gender) { 'female' }
  let(:work_occupation) { 'Manager' }
  let(:work_company) { 'Nestle' }
  let(:work_industry) { 'Food' }
  let(:links) { ['www.fb.com/123', 'www.twitter.com/123'] }

  let(:params) do
    {
      user: {
        first_name:,
        last_name:,
        phone_number:,
        zipcode:,
        birthday:,
        gender:,
        work_occupation:,
        work_company:,
        work_industry:,
        links:
      }
    }
  end

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  subject do
    put api_v1_user_path, params:, headers: auth_headers, as: :json
    response
  end

  it { is_expected.to be_successful }

  it { expect { subject }.to change { user.reload.first_name }.to(first_name) }
  it { expect { subject }.to change { user.reload.last_name }.to(last_name) }
  it { expect { subject }.to change { user.reload.phone_number }.to(phone_number) }
  it { expect { subject }.to change { user.reload.zipcode }.to(zipcode) }
  it { expect { subject }.to change { user.reload.birthday }.to(birthday) }
  it { expect { subject }.to change { user.reload.gender }.to(gender) }
  it { expect { subject }.to change { user.reload.work_occupation }.to(work_occupation) }
  it { expect { subject }.to change { user.reload.work_company }.to(work_company) }
  it { expect { subject }.to change { user.reload.work_industry }.to(work_industry) }
  it { expect { subject }.to change { user.reload.links }.to(links) }

  it { expect(response_body[:user][:id]).to eq(user.id) }

  context 'with missing user param' do
    let(:params) { {} }

    it { is_expected.to have_http_status(:unprocessable_entity) }
    it { expect(response_body[:error]).to eq('A required param is missing') }
  end

  context 'when first name is empty' do
    let(:first_name) { '' }

    it { is_expected.to have_http_status(:bad_request) }
    it 'returns the correct error message' do
      expect(response_body[:errors][:first_name]).to eq(["can't be blank"])
    end
  end

  context 'when the password is incorrect' do
    let(:password) { 'short' }
    let(:password_confirmation) { 'short' }

    let(:params) { { user: { password:, password_confirmation: } } }

    it { is_expected.to have_http_status(:bad_request) }
    it 'returns the correct error message' do
      expect(response_body[:errors][:password]).to eq(['is too short (minimum is 8 characters)'])
    end
  end

  context 'when the password confirmation does not match' do
    let(:password) { 'some-password' }
    let(:password_confirmation) { 'wrong-password' }

    let(:params) { { user: { password:, password_confirmation: } } }

    it { is_expected.to have_http_status(:bad_request) }
    it 'returns the correct error message' do
      expect(response_body[:errors][:password_confirmation]).to eq(["doesn't match Password"])
    end
  end
end
