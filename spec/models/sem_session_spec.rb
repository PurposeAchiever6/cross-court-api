# == Schema Information
#
# Table name: sem_sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  session_id :integer
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sem_sessions_on_session_id                       (session_id)
#  index_sem_sessions_on_user_id                          (user_id)
#  index_sem_sessions_on_user_id_and_session_id_and_date  (user_id,session_id,date) UNIQUE
#

require 'rails_helper'

describe SemSession do
  describe 'validations' do
    subject { build(:sem_session) }

    it { is_expected.to validate_presence_of(:date) }
  end

  describe 'callbacks' do
    let(:date)    { Date.current }
    let(:session) { create(:session, :daily) }
    let(:user1)   { create(:user) }

    context 'when there is no sem assigned' do
      let(:sem_session) do
        build(:sem_session, session: session, user: user1, date: date)
      end

      it 'assigns the sem to the session' do
        expect { sem_session.save! }.to change { session.sem(date)&.id }
          .from(nil)
          .to(sem_session.user_id)
      end
    end

    context 'when there is a previous sem assigned' do
      let(:user2) { create(:user) }
      let!(:first_sem_session) do
        create(:sem_session, session: session, user: user1, date: date)
      end
      let(:second_sem_session) do
        build(:sem_session, session: session, user: user2, date: date)
      end

      it 'assigns the new sem to the session' do
        expect { second_sem_session.save! }.to change { session.sem(date).id }
          .from(first_sem_session.user_id)
          .to(second_sem_session.user_id)
      end
    end
  end
end
