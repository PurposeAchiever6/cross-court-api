# == Schema Information
#
# Table name: user_session_waitlists
#
#  id         :integer          not null, primary key
#  date       :date
#  user_id    :integer
#  session_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state      :integer
#
# Indexes
#
#  index_user_session_waitlists_on_date_and_session_id_and_user_id  (date,session_id,user_id) UNIQUE
#  index_user_session_waitlists_on_session_id                       (session_id)
#  index_user_session_waitlists_on_user_id                          (user_id)
#

require 'rails_helper'

describe UserSessionWaitlist do
  subject { build :user_session_waitlist }

  context 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(%i[session_id user_id]) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:session) }
  end

  describe '.sorted' do
    let!(:session) { create(:session) }
    let!(:user_1) { create(:user) }
    let!(:user_2) { create(:user) }
    let!(:waitlist_item_1) do
      create(
        :user_session_waitlist,
        session: session,
        user: user_1,
        state: state_1,
        created_at: created_at_1
      )
    end
    let!(:waitlist_item_2) do
      create(
        :user_session_waitlist,
        session: session,
        user: user_2,
        state: state_2,
        created_at: created_at_2
      )
    end

    let(:created_at_1) { Time.zone.today - 2.days }
    let(:created_at_2) { created_at_1 + 5.minutes }
    let(:state_1) { :pending }
    let(:state_2) { :pending }

    subject { UserSessionWaitlist.sorted }

    it { is_expected.to eq([waitlist_item_1, waitlist_item_2]) }

    context 'when waitlist_item_2 was created before' do
      let(:created_at_2) { created_at_1 - 5.minutes }

      it { is_expected.to eq([waitlist_item_2, waitlist_item_1]) }
    end

    context 'when waitlist_item_2 has already made it off the waitlist' do
      let(:state_2) { 'success' }

      it { is_expected.to eq([waitlist_item_2, waitlist_item_1]) }
    end

    context 'when waitlist_item_2 user is a member' do
      let!(:user_2) { create(:user, :with_unlimited_subscription) }

      it { is_expected.to eq([waitlist_item_2, waitlist_item_1]) }

      context 'when there is another member' do
        let!(:user_3) { create(:user, :with_unlimited_subscription) }
        let!(:waitlist_item_3) do
          create(
            :user_session_waitlist,
            session: session,
            user: user_3,
            state: state_3,
            created_at: created_at_3
          )
        end

        let(:created_at_3) { created_at_2 - 2.minutes }
        let(:state_3) { :pending }

        it { is_expected.to eq([waitlist_item_3, waitlist_item_2, waitlist_item_1]) }
      end
    end
  end
end
