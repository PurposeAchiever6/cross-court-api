# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  start_time  :date             not null
#  recurring   :text
#  time        :time             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer          not null
#  end_time    :date
#  level       :integer          default("basic"), not null
#
# Indexes
#
#  index_sessions_on_location_id  (location_id)
#

require 'rails_helper'

describe Session do
  describe 'validations' do
    subject { build :session }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:time) }
    it { is_expected.to belong_to(:location) }
  end

  describe 'callbacks' do
    let!(:session)               { create(:session, :daily) }
    let!(:yesterday_sem_session) { create(:sem_session, session: session, date: Date.yesterday) }
    let(:new_recurring_rule)     { IceCube::Rule.weekly }
    let(:user)                   { create(:user) }
    before do
      8.times do |i|
        create(:sem_session, session: session, date: Date.current + i.days)
        create(:referee_session, session: session, date: Date.current + i.days)
        create(:user_session, session: session, user: user, date: Date.current + i.days)
      end
    end

    context 'when updating the recurring rule' do
      it 'destroys all future sem_sessions which not occur in the new rule' do
        expect {
          session.update!(recurring: new_recurring_rule)
        }.to change(SemSession, :count).by(-6)
      end

      it 'destroys all future referee_sessions which not occur in the new rule' do
        expect {
          session.update!(recurring: new_recurring_rule)
        }.to change(RefereeSession, :count).by(-6)
      end

      it 'destroys all future user_sessions which not occur in the new rule' do
        expect {
          session.update!(recurring: new_recurring_rule)
        }.to change(UserSession, :count).by(-6)
      end

      it 'adds credits to the user corresponding to the deleted user_sessions' do
        expect {
          session.update!(recurring: new_recurring_rule)
        }.to change { user.reload.credits }.from(0).to(6)
      end
    end
  end
end
