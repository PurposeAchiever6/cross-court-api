require 'rails_helper'

describe Sessions::RemoveVote do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:session) { create(:session) }
    let!(:user_session_vote) do
      create(
        :user_session_vote,
        session:,
        user:,
        date: session.start_time
      )
    end

    let(:date) { session.start_time }

    subject { Sessions::RemoveVote.call(session:, user:, date:) }

    it { expect { subject }.to change(UserSessionVote, :count).by(-1) }

    context 'when the user did not vote for that date' do
      let(:date) { session.start_time + 1.day }

      it { expect { subject }.to raise_error(UserDidNotVoteSessionException) }
      it { expect { subject rescue nil }.not_to change(UserSessionVote, :count) }
    end

    context 'when the user did not vote' do
      before { user_session_vote.destroy }

      it { expect { subject }.to raise_error(UserDidNotVoteSessionException) }
      it { expect { subject rescue nil }.not_to change(UserSessionVote, :count) }
    end
  end
end
