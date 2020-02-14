require 'rails_helper'

describe UserSessionWithValidDate do
  let(:user)    { create(:user) }
  let(:session) { create(:session, :daily) }

  describe '.save!' do
    context 'when the date is correct' do
      let!(:user_session) do
        build(:user_session, user: user, session: session, date: Date.tomorrow)
      end
      let(:user_session_with_valid_date) { UserSessionWithValidDate.new(user_session) }

      it 'creates the user_session' do
        expect { user_session_with_valid_date.save! }.to change(UserSession, :count).from(0).to(1)
      end
    end

    context 'when the date is incorrect' do
      let!(:user_session) do
        build(:user_session, user: user, session: session, date: Date.yesterday)
      end
      let(:user_session_with_valid_date) { UserSessionWithValidDate.new(user_session) }

      it 'raises an exception' do
        expect { user_session_with_valid_date.save! }.to raise_error(InvalidDateException)
      end
    end
  end
end
