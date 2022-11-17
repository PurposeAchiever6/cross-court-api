require 'rails_helper'

describe DropIns::SendPurchaseSlackNotification do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:product) { create(:product, season_pass: season_pass) }

    let(:season_pass) { true }

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject { DropIns::SendPurchaseSlackNotification.call(user: user, product: product) }

    it 'sends a Slack message' do
      expect_any_instance_of(Slack::Notifier).to receive(:ping)
      subject
    end

    it 'calls Slack Service correct method' do
      expect_any_instance_of(SlackService).to receive(:season_pass_purchased).with(product)
      subject
    end

    context 'when the product is not a season pass' do
      let(:season_pass) { false }

      it 'does not call Slack Service' do
        expect_any_instance_of(SlackService).not_to receive(:season_pass_purchased)
        subject
      end
    end
  end
end
