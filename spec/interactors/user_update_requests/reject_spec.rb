require 'rails_helper'

describe UserUpdateRequests::Reject do
  describe '.call' do
    let!(:user_update_request) { create(:user_update_request, status: status) }
    let(:status) { :pending }

    subject { UserUpdateRequests::Reject.call(user_update_request: user_update_request) }

    it { expect { subject }.to change { user_update_request.reload.status }.to('rejected') }

    context 'when user_update_request is not pending' do
      let(:status) { %i[approved rejected].sample }

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
