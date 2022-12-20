# == Schema Information
#
# Table name: payments
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  amount          :decimal(10, 2)   not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  description     :string           not null
#  discount        :decimal(10, 2)   default(0.0)
#  last_4          :string
#  stripe_id       :string
#  status          :integer          default("success")
#  error_message   :string
#  cc_cash         :decimal(10, 2)   default(0.0)
#  chargeable_type :string
#  chargeable_id   :integer
#
# Indexes
#
#  index_payments_on_chargeable_type_and_chargeable_id  (chargeable_type,chargeable_id)
#  index_payments_on_status                             (status)
#  index_payments_on_user_id                            (user_id)
#

require 'rails_helper'

describe Payment do
  describe 'validations' do
    subject { build(:payment) }

    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end
end
