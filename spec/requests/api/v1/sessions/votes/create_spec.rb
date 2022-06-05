require 'rails_helper'

describe 'POST api/v1/sessions/:session_id/votes' do
  let!(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
  let!(:user) { create(:user) }
  let!(:session) { create(:session, start_time: la_time.tomorrow, coming_soon: coming_soon) }
  let(:date) { session.start_time }
  let(:coming_soon) { true }

  let(:params) { { date: date.strftime('%d/%m/%Y') } }
  let(:request_headers) { auth_headers }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  subject do
    post api_v1_session_votes_path(session_id: session.id),
         headers: request_headers,
         params: params,
         as: :json
    response
  end

  it { is_expected.to be_successful }
  it { expect { subject }.to change(UserSessionVote, :count).by(1) }
  it { expect(subject.body).to be_blank }

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }
    it { expect { subject }.not_to change(UserSessionVote, :count) }
  end

  context 'when date is not present' do
    before { params.delete(:date) }

    it { is_expected.to have_http_status(:unprocessable_entity) }
    it { expect(response_body[:error]).to eq('A required param is missing') }
    it { expect { subject }.not_to change(UserSessionVote, :count) }
  end

  context 'when date format is invalid' do
    before { params[:date] = date.strftime('%m-%d-%Y') }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The date value format is invalid') }
    it { expect { subject }.not_to change(UserSessionVote, :count) }
  end

  context 'when there is no session for the date' do
    let(:date) { session.start_time + 1.day }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The date is not valid for the requested session') }
    it { expect { subject }.not_to change(UserSessionVote, :count) }
  end

  context 'when user has already voted for that session and date' do
    before { create(:user_session_vote, session: session, user: user, date: date) }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:errors][:date]).to eq(['has already been taken']) }
    it { expect { subject }.not_to change(UserSessionVote, :count) }
  end

  context 'when session is not coming soon' do
    let(:coming_soon) { false }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The session should be a coming soon session') }
    it { expect { subject }.not_to change(UserSessionVote, :count) }
  end
end
