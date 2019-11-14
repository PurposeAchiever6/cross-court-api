require 'rails_helper'

describe UserSessionEmail do
  let(:user)          { create(:user) }
  let(:session)       { create(:session) }
  let!(:user_session) { build(:user_session, user: user, session: session) }

  describe '.save!' do
    let(:user_session_email) { UserSessionEmail.new(user_session) }

    it 'sends an email to the consumer' do
      expect { user_session_email.save! }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
