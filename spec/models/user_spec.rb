# == Schema Information
#
# Table name: users
#
#  id                          :integer          not null, primary key
#  email                       :string
#  encrypted_password          :string           default(""), not null
#  reset_password_token        :string
#  reset_password_sent_at      :datetime
#  allow_password_change       :boolean          default(FALSE)
#  remember_created_at         :datetime
#  sign_in_count               :integer          default(0), not null
#  current_sign_in_at          :datetime
#  last_sign_in_at             :datetime
#  current_sign_in_ip          :inet
#  last_sign_in_ip             :inet
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  provider                    :string           default("email"), not null
#  uid                         :string           default(""), not null
#  tokens                      :json
#  confirmation_token          :string
#  confirmed_at                :datetime
#  confirmation_sent_at        :datetime
#  name                        :string           default("")
#  phone_number                :string
#  credits                     :integer          default(0), not null
#  is_referee                  :boolean          default(FALSE), not null
#  is_sem                      :boolean          default(FALSE), not null
#  stripe_id                   :string
#  free_session_state          :integer          default(0), not null
#  free_session_payment_intent :string
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_is_referee            (is_referee)
#  index_users_on_is_sem                (is_sem)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#

require 'rails_helper'

describe User do
  describe 'validations' do
    subject { build :user }
    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
    it { is_expected.to validate_numericality_of(:credits).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:free_session_state) }
    it {
      is_expected.to define_enum_for(:free_session_state)
        .with_values(%i[not_claimed claimed used])
        .with_prefix(:free_session)
    }

    context 'when was created with regular login' do
      subject { build :user }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive.scoped_to(:provider) }
      it { is_expected.to validate_presence_of(:email) }
    end
  end
end
