# == Schema Information
#
# Table name: products
#
#  id                                     :integer          not null, primary key
#  credits                                :integer          default(0), not null
#  name                                   :string           not null
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  price                                  :decimal(10, 2)   default(0.0), not null
#  order_number                           :integer          default(0), not null
#  product_type                           :integer          default("one_time")
#  stripe_price_id                        :string
#  label                                  :string
#  deleted_at                             :datetime
#  price_for_members                      :decimal(10, 2)
#  stripe_product_id                      :string
#  referral_cc_cash                       :decimal(, )      default(0.0)
#  price_for_first_timers_no_free_session :decimal(10, 2)
#  available_for                          :integer          default("everyone")
#  skill_session_credits                  :integer          default(0)
#  max_rollover_credits                   :integer
#  season_pass                            :boolean          default(FALSE)
#
# Indexes
#
#  index_products_on_deleted_at    (deleted_at)
#  index_products_on_product_type  (product_type)
#

require 'rails_helper'

describe Product do
  describe 'validations' do
    subject { build(:product) }

    it { is_expected.to validate_presence_of(:credits) }
  end

  describe 'price' do
    let!(:user) { create(:user, free_session_state: user_free_session_state) }
    let!(:product) do
      create(
        :product,
        price: price,
        price_for_members: price_for_members,
        price_for_first_timers_no_free_session: price_for_first_timers_no_free_session,
        product_type: product_type
      )
    end

    let(:price) { rand(1_000) }
    let(:price_for_members) { rand(1_000) }
    let(:price_for_first_timers_no_free_session) { rand(1_000) }
    let(:product_type) { 'one_time' }
    let(:user_free_session_state) { :not_claimed }

    subject { product.price(user) }

    it { is_expected.to eq(price) }

    context 'when product is recurring' do
      let(:product_type) { 'recurring' }

      it { is_expected.to eq(price) }
    end

    context 'when price_for_members is nil' do
      let(:price_for_members) { nil }

      it { is_expected.to eq(price) }
    end

    context 'when price_for_first_timers_no_free_session is nil' do
      let(:price_for_first_timers_no_free_session) { nil }

      it { is_expected.to eq(price) }
    end

    context 'when user has an active subscription' do
      before { user.subscriptions << create(:subscription) }

      it { is_expected.to eq(price_for_members) }

      context 'when product is recurring' do
        let(:product_type) { 'recurring' }

        it { is_expected.to eq(price) }
      end

      context 'when price_for_members is nil' do
        let(:price_for_members) { nil }

        it { is_expected.to eq(price) }
      end

      context 'when user is first timer and has not received a free session' do
        let(:user_free_session_state) { :not_apply }

        it { is_expected.to eq(price_for_first_timers_no_free_session) }
      end
    end

    context 'when user is first timer and has not received a free session' do
      let(:user_free_session_state) { :not_apply }

      it { is_expected.to eq(price_for_first_timers_no_free_session) }

      context 'when product is recurring' do
        let(:product_type) { 'recurring' }

        it { is_expected.to eq(price) }
      end

      context 'when price_for_first_timers_no_free_session is nil' do
        let(:price_for_first_timers_no_free_session) { nil }

        it { is_expected.to eq(price) }
      end

      context 'when user is not a first timer' do
        let!(:user_session) { create(:user_session, user: user) }

        it { is_expected.to eq(price) }
      end

      context 'when user already has a credit' do
        before { user.increment!(:credits) }

        it { is_expected.to eq(price) }
      end
    end

    describe 'price with no args' do
      subject { product.price }

      it { is_expected.to eq(price) }
    end
  end
end
