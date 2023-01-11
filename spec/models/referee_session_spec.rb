# == Schema Information
#
# Table name: employee_sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  session_id :integer
#  date       :date             not null
#  state      :integer          default("unconfirmed"), not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_employee_sessions_on_session_id  (session_id)
#  index_employee_sessions_on_type        (type)
#  index_employee_sessions_on_user_id     (user_id)
#

require 'rails_helper'

describe RefereeSession do
  describe 'validations' do
    subject { build(:referee_session) }

    it { is_expected.to validate_presence_of(:date) }
  end

  describe 'callbacks' do
    let(:date)    { Date.current }
    let(:session) { create(:session, :daily) }
    let(:user1)   { create(:user) }

    context 'when there is no referee assigned' do
      let(:referee_session) do
        build(:referee_session, session:, user: user1, date:)
      end

      it 'assigns the referee to the session' do
        expect { referee_session.save! }.to change { session.referee(date)&.id }
          .from(nil)
          .to(referee_session.user_id)
      end
    end

    context 'when there is a previous referee assigned' do
      let(:user2) { create(:user) }
      let!(:first_referee_session) do
        create(:referee_session, session:, user: user1, date:)
      end
      let(:second_referee_session) do
        build(:referee_session, session:, user: user2, date:)
      end

      it 'assigns the new referee to the session' do
        expect { second_referee_session.save! }.to change { session.referee(date).id }
          .from(first_referee_session.user_id)
          .to(second_referee_session.user_id)
      end
    end
  end
end
