require 'rails_helper'

describe DropIns::IncrementUserCredits do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:product) { create(:product, season_pass: season_pass, scouting: scouting) }

    let(:season_pass) { false }
    let(:scouting) { false }

    subject { DropIns::IncrementUserCredits.call(user: user, product: product) }

    it { expect { subject }.to change { user.reload.credits }.by(product.credits) }
    it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
    it { expect { subject }.not_to change { user.reload.scouting_credits } }

    context 'when the product is a season pass product' do
      let(:season_pass) { true }

      it 'increments user credits_without_expiration' do
        expect {
          subject
        }.to change { user.reload.credits_without_expiration }.by(product.credits)
      end

      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.scouting_credits } }
    end

    context 'when the product is a scouting product' do
      let(:scouting) { true }

      it { expect { subject }.to change { user.reload.scouting_credits }.by(product.credits) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
    end
  end
end
