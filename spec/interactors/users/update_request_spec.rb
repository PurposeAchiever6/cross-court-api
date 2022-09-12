require 'rails_helper'

describe Users::UpdateRequest do
  describe '.call' do
    let!(:user) { create(:user) }
    let(:requested_attributes) { { skill_rating: rand(1..5) } }
    let(:reason) { 'Some reason' }

    subject do
      Users::UpdateRequest.call(
        user: user,
        requested_attributes: requested_attributes,
        reason: reason
      )
    end

    it { expect { subject }.to change(UserUpdateRequest, :count).by(1) }

    it 'sends update_request email' do
      expect { subject }.to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with('UserMailer', 'update_request', anything, anything)
    end
  end
end
