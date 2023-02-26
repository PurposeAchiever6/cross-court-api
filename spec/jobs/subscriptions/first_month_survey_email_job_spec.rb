require 'rails_helper'

describe Subscriptions::FirstMonthSurveyEmailJob do
  describe '#perform' do
    let(:status) { :active }
    let!(:subscription) { create(:subscription, status:) }
    let!(:user) { create(:user, :confirmed, active_subscription: subscription) }

    subject { described_class.perform_now(subscription.id) }

    it { expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1) }

    context 'when subscription is not active' do
      let(:status) { %i[paused canceled].sample }

      it { expect { subject }.not_to change { ActionMailer::Base.deliveries.count } }
    end
  end
end
