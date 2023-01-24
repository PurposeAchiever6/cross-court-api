require 'rails_helper'

describe Subscriptions::CancelAtPeriodEndJob do
  describe '#perform' do
    let!(:subscription_1) do
      create(
        :subscription,
        status: 'active',
        cancel_at_period_end: false,
        mark_cancel_at_period_end_at: Time.zone.today
      )
    end
    let!(:subscription_2) do
      create(
        :subscription,
        status: 'active',
        cancel_at_period_end: true,
        mark_cancel_at_period_end_at: Time.zone.today
      )
    end
    let!(:subscription_3) do
      create(
        :subscription,
        status: 'canceled',
        cancel_at_period_end: true,
        mark_cancel_at_period_end_at: Time.zone.today
      )
    end
    let!(:subscription_4) do
      create(
        :subscription,
        status: 'active',
        cancel_at_period_end: false,
        mark_cancel_at_period_end_at: Time.zone.today + 1.day
      )
    end
    let!(:subscription_5) do
      create(
        :subscription,
        status: 'active',
        cancel_at_period_end: false,
        mark_cancel_at_period_end_at: Time.zone.today
      )
    end

    subject { Subscriptions::CancelAtPeriodEndJob.perform_now }

    it 'calls Subscriptions::CancelSubscriptionAtPeriodEnd' do
      expect(Subscriptions::CancelSubscriptionAtPeriodEnd).to receive(
        :call
      ).with({ user: subscription_1.user, subscription: subscription_1 })

      expect(Subscriptions::CancelSubscriptionAtPeriodEnd).to receive(
        :call
      ).with({ user: subscription_5.user, subscription: subscription_5 })

      subject
    end
  end
end
