require 'rails_helper'

describe 'PUT /api/v1/user/update_skill_rating' do
  let!(:user) { create(:user, skill_rating: old_skill_rating) }
  let!(:another_user) { create(:user, skill_rating: old_skill_rating) }

  let(:old_skill_rating) { 2 }
  let(:new_skill_rating) { 3 }

  let(:params) { { user: { skill_rating: new_skill_rating }, email: another_user.email } }
  let(:request_headers) { auth_headers }

  subject do
    put update_skill_rating_api_v1_user_path,
        headers: request_headers,
        params:,
        as: :json
    response
  end

  before { ENV['SKILL_RATINGS_FOR_REVIEW'] = '4,5' }

  it { is_expected.to be_successful }
  it { expect(subject.body).to be_empty }
  it { expect { subject }.not_to change { another_user.reload.skill_rating } }

  it 'updates user skill rating' do
    expect {
      subject
    }.to change { user.reload.skill_rating }.from(old_skill_rating).to(new_skill_rating)
  end

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_successful }
    it { expect { subject }.not_to change { user.reload.skill_rating } }

    it 'updates user skill rating' do
      expect {
        subject
      }.to change { another_user.reload.skill_rating }.from(old_skill_rating).to(new_skill_rating)
    end

    context 'when the user does not exist' do
      before { params[:email] = 'not-exist' }

      it { is_expected.to have_http_status(:not_found) }
      it { expect { subject }.not_to change { user.reload.skill_rating } }
      it { expect { subject }.not_to change { another_user.reload.skill_rating } }
    end
  end

  context 'when user tries to update to a reviewable skill rating' do
    let(:new_skill_rating) { [4, 5].sample }
    let(:response_body) do
      JSON.parse(subject.body).with_indifferent_access
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect { subject }.not_to change { user.reload.skill_rating } }
    it { expect { subject }.not_to change { another_user.reload.skill_rating } }

    it 'returns the correct error message' do
      expect(
        response_body[:error]
      ).to match('The new skill rating needs to be reviewed by our team before being updated')
    end
  end
end
