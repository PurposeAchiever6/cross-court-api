require 'rails_helper'

describe CanceledSubscriptionsRemindersJob do
  describe '#perform' do
    let!(:subscription_1) do
      create(
        :subscription,
        status: 'active',
        cancel_at_period_end: true,
        current_period_end: Time.zone.tomorrow
      )
    end
    let!(:subscription_2) do
      create(
        :subscription,
        status: 'active',
        cancel_at_period_end: true,
        current_period_end: Time.zone.today + 2.days
      )
    end
    let!(:subscription_3) do
      create(
        :subscription,
        status: 'canceled',
        cancel_at_period_end: true,
        current_period_end: Time.zone.tomorrow
      )
    end
    let!(:subscription_4) do
      create(
        :subscription,
        status: 'active',
        cancel_at_period_end: false,
        current_period_end: Time.zone.tomorrow
      )
    end

    subject { CanceledSubscriptionsRemindersJob.perform_now }

    it 'calls Sonar service' do
      expect(SonarService).to receive(:send_message).once.with(subscription_1.user, anything)
      subject
    end
  end
end
