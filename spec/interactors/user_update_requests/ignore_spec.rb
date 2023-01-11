require 'rails_helper'

describe UserUpdateRequests::Ignore do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:user_update_request) { create(:user_update_request, user:, status:) }
    let(:status) { :pending }

    subject { UserUpdateRequests::Ignore.call(user_update_request:) }

    it { expect { subject }.to change { user_update_request.reload.status }.to('ignored') }

    context 'when user_update_request is not pending' do
      let(:status) { %i[approved rejected ignored].sample }

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
