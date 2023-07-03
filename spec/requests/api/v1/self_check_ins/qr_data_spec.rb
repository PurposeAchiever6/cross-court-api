require 'rails_helper'

describe 'GET api/v1/self_check_ins/qr_data' do
  let(:is_sem) { true }
  let(:user) { create(:user, is_sem:) }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  subject do
    get qr_data_api_v1_self_check_ins_path, headers: auth_headers, params: {}, as: :json
    response
  end

  it { is_expected.to be_successful }

  it 'returns the data' do
    expect(response_body[:data]).not_to be_empty
  end

  it 'returns the refresh time' do
    expect(response_body[:refresh_time_ms]).to eq(
      SelfCheckIns::QrData::REFRESH_TIME.in_milliseconds
    )
  end

  context 'when the user is not employee' do
    let(:is_sem) { false }

    it { is_expected.to be_unauthorized }
  end
end
