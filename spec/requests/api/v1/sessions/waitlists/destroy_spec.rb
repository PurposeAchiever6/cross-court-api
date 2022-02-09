require 'rails_helper'

describe 'DELETE api/v1/sessions/:session_id/waitlists' do
  let!(:user) { create(:user) }
  let!(:session) { create(:session) }
  let!(:user_session_waitlist) do
    create(
      :user_session_waitlist,
      session: session,
      user: user,
      date: session.start_time,
      reached: reached
    )
  end

  let(:date) { session.start_time }
  let(:reached) { false }

  let(:params) { { date: date.strftime('%m/%d/%Y') } }
  let(:request_headers) { auth_headers }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  subject do
    delete api_v1_session_waitlists_path(session_id: session.id),
           headers: request_headers,
           params: params,
           as: :json
    response
  end

  it { is_expected.to be_successful }
  it { expect { subject }.to change(UserSessionWaitlist, :count).by(-1) }
  it { expect(subject.body).to be_blank }

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'when date is not present' do
    before { params.delete(:date) }

    it { is_expected.to have_http_status(:unprocessable_entity) }
    it { expect(response_body[:error]).to eq('A required param is missing') }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'when date format is invalid' do
    before { params[:date] = date.strftime('%m-%d-%Y') }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The date value format is invalid') }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'when the user is not in the waitlist for that date' do
    let(:date) { session.start_time + 1.day }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The user is not in the waitlist') }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'when the user session waitlist does not exist' do
    before { user_session_waitlist.destroy }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The user is not in the waitlist') }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'if the user has already been reached' do
    let(:reached) { true }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The user is not in the waitlist') }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end
end
