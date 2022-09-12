require 'rails_helper'

describe UserUpdateRequests::Approve do
  describe '.call' do
    let!(:user) { create(:user, skill_rating: old_skill_rating) }
    let!(:user_update_request) do
      create(
        :user_update_request,
        user: user,
        status: status,
        requested_attributes: requested_attributes
      )
    end

    let(:status) { :pending }
    let(:requested_attributes) { { skill_rating: new_skill_rating } }

    let(:new_skill_rating) { 5 }
    let(:old_skill_rating) { 3 }

    subject { UserUpdateRequests::Approve.call(user_update_request: user_update_request) }

    it 'updates user skill rating' do
      expect {
        subject
      }.to change { user.reload.skill_rating }.from(old_skill_rating).to(new_skill_rating)
    end

    it { expect { subject }.to change { user_update_request.reload.status }.to('approved') }

    context 'when user_update_request is not pending' do
      let(:status) { %i[approved rejected].sample }

      it { expect { subject rescue nil }.not_to change { user.reload.skill_rating } }

      it { expect { subject rescue nil }.not_to change { user_update_request.reload.status } }

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
