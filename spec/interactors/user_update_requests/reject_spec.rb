require 'rails_helper'

describe UserUpdateRequests::Reject do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:user_update_request) { create(:user_update_request, user: user, status: status) }
    let(:status) { :pending }

    before { allow(SendSonar).to receive(:message_customer) }

    subject { UserUpdateRequests::Reject.call(user_update_request: user_update_request) }

    it { expect { subject }.to change { user_update_request.reload.status }.to('rejected') }

    it 'calls Sonar service' do
      expect(SonarService).to receive(:send_message).with(
        user,
        "Hey #{user.first_name}, unfortunately we are unable to complete your CC skill " \
        'level adjustment at this time. If you have any questions, feel free to email ' \
        "us at #{ENV['CC_TEAM_EMAIL']}.\n"
      )

      subject
    end

    context 'when user_update_request is not pending' do
      let(:status) { %i[approved rejected ignored].sample }

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
