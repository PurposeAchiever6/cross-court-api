# == Schema Information
#
# Table name: user_session_waitlists
#
#  id         :bigint           not null, primary key
#  date       :date
#  user_id    :bigint
#  session_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state      :integer          default("pending")
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

    let!(:user_1) { create(:user, active_subscription: subscription_1) }
    let!(:user_2) { create(:user, active_subscription: subscription_2) }
    let!(:user_3) { create(:user, active_subscription: subscription_3) }

    let!(:waitlist_item_1) do
      create(
        :user_session_waitlist,
        session:,
        user: user_1,
        state: state_1,
        created_at: created_at_1
      )
    end
    let!(:waitlist_item_2) do
      create(
        :user_session_waitlist,
        session:,
        user: user_2,
        state: state_2,
        created_at: created_at_2
      )
    end
    let!(:waitlist_item_3) do
      create(
        :user_session_waitlist,
        session:,
        user: user_3,
        state: state_3,
        created_at: created_at_3
      )
    end

    let(:subscription_1) { nil }
    let(:subscription_2) { nil }
    let(:subscription_3) { nil }

    let(:state_1) { :pending }
    let(:state_2) { :pending }
    let(:state_3) { :pending }

    let(:created_at_1) { Time.zone.today - 2.days }
    let(:created_at_2) { created_at_1 + 5.minutes }
    let(:created_at_3) { created_at_1 + 10.minutes }

    subject { UserSessionWaitlist.sorted }

    it { is_expected.to eq([waitlist_item_1, waitlist_item_2, waitlist_item_3]) }

    context 'when waitlist_item_2 was created before' do
      let(:created_at_2) { created_at_1 - 5.minutes }

      it { is_expected.to eq([waitlist_item_2, waitlist_item_1, waitlist_item_3]) }
    end

    context 'when waitlist_item_2 has already made it off the waitlist' do
      let(:state_2) { 'success' }

      it { is_expected.to eq([waitlist_item_2, waitlist_item_1, waitlist_item_3]) }
    end

    context 'when waitlist_item_2 user is a member' do
      let!(:subscription_2) { create(:subscription, product: product_2) }
      let!(:product_2) { create(:product, price: 100) }

      it { is_expected.to eq([waitlist_item_2, waitlist_item_1, waitlist_item_3]) }

      context 'when waitlist_item_3 is also a member' do
        let!(:subscription_3) { create(:subscription, product: product_3) }
        let!(:product_3) { create(:product, price: 100) }

        it { is_expected.to eq([waitlist_item_2, waitlist_item_3, waitlist_item_1]) }

        context 'when waitlist_item_3 membership is more important' do
          let!(:product_3) { create(:product, price: 120) }

          it { is_expected.to eq([waitlist_item_3, waitlist_item_2, waitlist_item_1]) }
        end

        context 'when waitlist_item_3 was created before' do
          let(:created_at_3) { created_at_2 - 2.minutes }

          it { is_expected.to eq([waitlist_item_3, waitlist_item_2, waitlist_item_1]) }

          context 'when waitlist_item_3 has is less important' do
            let!(:product_3) { create(:product, price: 80) }

            it { is_expected.to eq([waitlist_item_2, waitlist_item_3, waitlist_item_1]) }
          end
        end
      end
    end
  end
end
