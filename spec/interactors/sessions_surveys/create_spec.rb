require 'rails_helper'

describe SessionsSurveys::Create do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:checked_in_user_session) { create(:user_session, user:, checked_in: true) }
    let!(:user_session) { create(:user_session, user:, checked_in: false) }
    let(:rate) { rand(1..5) }
    let(:feedback) { 'Some feedback' }

    subject do
      SessionsSurveys::Create.call(
        user:,
        rate:,
        feedback:
      )
    end

    it { expect { subject }.to change(SessionSurvey, :count).by(1) }

    it 'assigns the right user' do
      subject
      expect(SessionSurvey.last.user).to eq(user)
    end

    it 'assigns the right user_session' do
      subject
      expect(SessionSurvey.last.user_session).to eq(checked_in_user_session)
    end

    it 'assigns the right rate value' do
      subject
      expect(SessionSurvey.last.rate).to eq(rate)
    end

    it 'assigns the right feedback value' do
      subject
      expect(SessionSurvey.last.feedback).to eq(feedback)
    end
  end
end
