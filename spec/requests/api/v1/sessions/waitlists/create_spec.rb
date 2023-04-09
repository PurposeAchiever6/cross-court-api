require 'rails_helper'

describe 'POST api/v1/sessions/:session_id/waitlists' do
  let!(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
  let!(:user) { create(:user, skill_rating: user_skill_rating) }
  let!(:session) do
    create(
      :session,
      start_time: la_time.tomorrow,
      all_skill_levels_allowed:
    )
  end

  let(:date) { session.start_time }
  let(:user_skill_rating) { 1 }
  let(:all_skill_levels_allowed) { true }

  let(:params) { { date: date.strftime('%d/%m/%Y') } }
  let(:request_headers) { auth_headers }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  subject do
    post api_v1_session_waitlists_path(session_id: session.id),
         headers: request_headers,
         params:,
         as: :json
    response
  end

  it { is_expected.to be_successful }
  it { expect { subject }.to change(UserSessionWaitlist, :count).by(1) }
  it { expect(response_body[:waitlist_placement]).to eq(1) }

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

  context 'when there is no session for the date' do
    include_context 'disable bullet'

    let(:date) { session.start_time + 1.day }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The date is not valid for the requested session') }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'when user is already in the waitlist' do
    include_context 'disable bullet'

    before { create(:user_session_waitlist, session:, user:, date:) }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:errors][:date]).to eq(['has already been taken']) }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'when user is already in the session' do
    include_context 'disable bullet'

    before { create(:user_session, session:, user:, date:) }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('You are already in for this session') }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'when the session is not for all skill levels' do
    include_context 'disable bullet'

    let(:all_skill_levels_allowed) { false }

    before { session.skill_level.update!(min: 4, max: 5) }

    it { is_expected.to have_http_status(:bad_request) }

    it 'returns the correct error message' do
      expect(
        response_body[:error]
      ).to eq("Can not reserve this session if it's outside user's skill level")
    end

    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }

    context 'when the user is inside the session skill level' do
      let(:user_skill_rating) { 4 }

      it { is_expected.to be_successful }
      it { expect { subject }.to change(UserSessionWaitlist, :count).by(1) }
    end
  end
end
