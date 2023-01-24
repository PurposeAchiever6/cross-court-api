require 'rails_helper'

describe UserUpdateRequests::Approve do
  describe '.call' do
    let!(:user) { create(:user, skill_rating: old_skill_rating) }
    let!(:user_update_request) do
      create(
        :user_update_request,
        user:,
        status:,
        requested_attributes:
      )
    end

    let(:status) { :pending }
    let(:requested_attributes) { { skill_rating: new_skill_rating } }

    let(:new_skill_rating) { 5 }
    let(:old_skill_rating) { 3 }

    before { allow(SendSonar).to receive(:message_customer) }

    subject { UserUpdateRequests::Approve.call(user_update_request:) }

    it 'updates user skill rating' do
      expect {
        subject
      }.to change { user.reload.skill_rating }.from(old_skill_rating).to(new_skill_rating)
    end

    it { expect { subject }.to change { user_update_request.reload.status }.to('approved') }

    it 'calls Sonar service' do
      expect(SonarService).to receive(:send_message).with(
        user,
        "Hey #{user.first_name}! Your CC skill level adjustment request has been approved.\n"
      )

      subject
    end

    context 'when user_update_request is not pending' do
      let(:status) { %i[approved rejected ignored].sample }

      it { expect { subject rescue nil }.not_to change { user.reload.skill_rating } }

      it { expect { subject rescue nil }.not_to change { user_update_request.reload.status } }

      it 'does not call Sonar service' do
        expect(SonarService).not_to receive(:send_message)
        subject rescue nil
      end

      it 'raises error UserUpdateRequestIsNotPendingException' do
        expect {
          subject
        }.to raise_error(
          UserUpdateRequestIsNotPendingException,
          'The request status should be pending'
        )
      end
    end
  end
end
