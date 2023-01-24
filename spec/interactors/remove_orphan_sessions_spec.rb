require 'rails_helper'

describe RemoveOrphanSessions do
  before do
    Timecop.freeze(Time.current)
  end

  after do
    Timecop.return
  end

  let!(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end
  let!(:los_angeles_date) { los_angeles_time.to_date }

  let(:session) { create(:session, :daily) }
  let!(:yesterday_sem_session) do
    create(:sem_session, session:, date: los_angeles_date.yesterday)
  end
  let!(:yesterday_ref_session) do
    create(:referee_session, session:, date: los_angeles_date.yesterday)
  end
  let!(:yesterday_user_session) do
    create(:user_session, session:, date: los_angeles_date.yesterday)
  end
  let(:user) { create(:user) }

  before do
    8.times do |i|
      create(:sem_session, session:, date: los_angeles_date + i.days)
      create(:referee_session, session:, date: los_angeles_date + i.days)
      create(:user_session, session:, user:, date: los_angeles_date + i.days)
    end
  end

  describe '.call' do
    context 'when recurring attribute is updated' do
      subject { session.update!(recurring: IceCube::Rule.weekly) }

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

    context 'when end_time attribute is updated' do
      subject { session.update!(end_time: los_angeles_date + 2.days) }

      it 'destroys all future sem_sessions which occur after the end_time' do
        expect { subject }.to change(SemSession, :count).by(-5)
      end

      it 'destroys all future referee_sessions which occur after the end_time' do
        expect { subject }.to change(RefereeSession, :count).by(-5)
      end

      it 'destroys all future user_sessions which  occur after the end_time' do
        expect { subject }.to change(UserSession, :count).by(-5)
      end

      it 'adds credits to the user corresponding to the deleted user_sessions' do
        expect { subject }.to change { user.reload.credits }.from(0).to(5)
      end
    end
  end
end
