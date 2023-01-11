require 'rails_helper'

describe Sessions::AssignDefaultEmployeesJob do
  describe '#perform' do
    let(:referee) { create(:user, :referee) }
    let(:sem) { create(:user, :sem) }
    let(:another_sem) { create(:user, :sem) }
    let(:coach) { create(:user, :coach) }
    let(:another_coach) { create(:user, :coach) }
    let(:location) { create(:location) }
    let(:recurring_rule) { IceCube::Rule.weekly }
    let!(:current_time) { Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)) }
    let!(:session_time) { current_time }
    let!(:session) do
      create(
        :session,
        location:,
        recurring: recurring_rule,
        default_referee_id: referee.id,
        default_sem_id: sem&.id,
        default_coach_id: coach.id,
        start_time: session_time
      )
    end

    subject { Sessions::AssignDefaultEmployeesJob.perform_now }

    it 'creates a referee session' do
      expect { subject }.to change { RefereeSession.count }.by(1)
    end

    it 'creates a sem session' do
      expect { subject }.to change { SemSession.count }.by(1)
    end

    it 'creates a coach session' do
      expect { subject }.to change { CoachSession.count }.by(1)
    end

    context 'when there are others employees already assigned' do
      before do
        SemSession.create!(
          user_id: another_sem.id,
          session_id: session.id,
          date: session.start_time + 1.week
        )
        CoachSession.create!(
          user_id: another_coach.id,
          session_id: session.id,
          date: session.start_time + 1.week
        )
      end

      it 'creates a referee session' do
        expect { subject }.to change { RefereeSession.count }.by(1)
      end

      it 'does not creates a sem session' do
        expect { subject }.not_to change { SemSession.count }
      end

      it 'does not creates a coach session' do
        expect { subject }.not_to change { CoachSession.count }
      end
    end

    context 'when only some default employees are assigned' do
      let(:sem) { nil }

      it 'creates a referee session' do
        expect { subject }.to change { RefereeSession.count }.by(1)
      end

      it 'does not creates a sem session' do
        expect { subject }.not_to change { SemSession.count }
      end

      it 'creates a coach session' do
        expect { subject }.to change { CoachSession.count }.by(1)
      end
    end
  end
end
