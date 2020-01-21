require 'rails_helper'

describe RemoveOrphanSessions do
  let(:session)                { create(:session, recurring: IceCube::Rule.weekly) }
  let!(:yesterday_sem_session) { create(:sem_session, session: session, date: Date.yesterday) }
  let(:user)                   { create(:user) }
  before do
    8.times do |i|
      create(:sem_session, session: session, date: Date.current + i.days)
      create(:referee_session, session: session, date: Date.current + i.days)
      create(:user_session, session: session, user: user, date: Date.current + i.days)
    end
  end
  subject { RemoveOrphanSessions.call(session: session) }

  describe '.call' do
    it 'destroys all future sem_sessions which not occur in the new rule' do
      expect { subject }.to change(SemSession, :count).by(-6)
    end

    it 'destroys all future referee_sessions which not occur in the new rule' do
      expect { subject }.to change(RefereeSession, :count).by(-6)
    end

    it 'destroys all future user_sessions which not occur in the new rule' do
      expect { subject }.to change(UserSession, :count).by(-6)
    end

    it 'adds credits to the user corresponding to the deleted user_sessions' do
      expect { subject }.to change { user.reload.credits }.from(0).to(6)
    end
  end
end
