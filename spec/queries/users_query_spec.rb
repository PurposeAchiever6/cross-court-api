require 'rails_helper'

describe UsersQuery do
  let(:users_query) { UsersQuery.new }

  let!(:user_1) do
    create(
      :user,
      free_session_state: :not_claimed,
      free_session_expiration_date: Time.zone.today - 1.day
    )
  end

  let!(:user_2) do
    create(
      :user,
      free_session_state: :not_claimed,
      free_session_expiration_date: Time.zone.today + 23.days
    )
  end

  let!(:user_3) do
    create(
      :user,
      free_session_state: :not_claimed,
      free_session_expiration_date: Time.zone.today + 15.days
    )
  end

  let!(:user_4) do
    create(
      :user,
      free_session_state: :not_claimed,
      free_session_expiration_date: Time.zone.today + 20.days
    )
  end

  let!(:user_5) do
    create(
      :user,
      free_session_state: %i[claimed used].sample,
      free_session_expiration_date: Time.zone.today + 23.days
    )
  end

  let!(:user_6) do
    create(
      :user,
      free_session_state: %i[claimed used].sample,
      free_session_expiration_date: Time.zone.today - 2.days
    )
  end

  describe '.expired_free_session_users' do
    subject { users_query.expired_free_session_users }

    it { is_expected.to match_array([user_1]) }
  end

  describe '.free_session_not_used_in' do
    subject { users_query.free_session_not_used_in(7.days) }

    it { is_expected.to match_array([user_2]) }
  end

  describe '.free_session_expires_in' do
    subject { users_query.free_session_expires_in(15.days) }

    it { is_expected.to match_array([user_3]) }
  end
end