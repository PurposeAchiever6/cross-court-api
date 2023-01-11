require 'rails_helper'

describe UserSessions::ConsumeScoutingCredit do
  describe '.call' do
    let!(:user) { create(:user, scouting_credits:) }
    let!(:session) { create(:session, is_open_club: open_club, skill_session:) }
    let!(:user_session) { create(:user_session, user:, session:, scouting:) }

    let(:scouting_credits) { rand(1..5) }
    let(:scouting) { true }
    let(:not_charge_user_credit) { false }
    let(:skill_session) { false }
    let(:open_club) { false }

    subject do
      UserSessions::ConsumeScoutingCredit.call(
        user_session:,
        not_charge_user_credit:
      )
    end

    it { expect { subject }.to change { user.reload.scouting_credits }.by(-1) }

    context 'when not_charge_user_credit is true' do
      let(:not_charge_user_credit) { true }

      it { expect { subject }.not_to change { user.reload.scouting_credits } }
    end

    context 'when user session has not been marked for scouting' do
      let(:scouting) { false }

      it { expect { subject }.not_to change { user.reload.scouting_credits } }
    end

    context 'when session is open club' do
      let(:open_club) { true }

      it { expect { subject rescue nil }.not_to change { user.reload.scouting_credits } }

      it 'raises error InvalidSessionForScoutingException' do
        expect { subject }.to raise_error(
          InvalidSessionForScoutingException,
          'The session is not valid for scouting'
        )
      end
    end

    context 'when session is a skill session' do
      let(:skill_session) { true }

      it { expect { subject rescue nil }.not_to change { user.reload.scouting_credits } }

      it 'raises error InvalidSessionForScoutingException' do
        expect { subject }.to raise_error(
          InvalidSessionForScoutingException,
          'The session is not valid for scouting'
        )
      end
    end

    context 'when the user does not have any scouting credit' do
      let(:scouting_credits) { 0 }

      it { expect { subject rescue nil }.not_to change { user.reload.scouting_credits } }

      it 'raises error NotEnoughScoutingCreditsException' do
        expect { subject }.to raise_error(
          NotEnoughScoutingCreditsException,
          'Not enough scouting sessions. Please buy one'
        )
      end
    end
  end
end
