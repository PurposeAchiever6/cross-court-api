require 'rails_helper'

describe Sessions::Cancel do
  describe '.call' do
    let!(:session) { create(:session) }
    let!(:user_session_1) { create(:user_session, session:, date:) }
    let!(:user_session_2) { create(:user_session, session:, date:) }
    let!(:user_session_3) { create(:user_session, session:, date:, state: :canceled) }

    let(:date) { Time.zone.today + 2.days }

    before do
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
      allow(SendSonar).to receive(:message_customer)
    end

    subject { Sessions::Cancel.call(session:, date:) }

    it { expect { subject }.to change(Session, :count).by(-1) }

    it { expect { subject }.to change { user_session_1.user.reload.credits }.by(1) }
    it { expect { subject }.to change { user_session_2.user.reload.credits }.by(1) }
    it { expect { subject }.not_to change { user_session_3.user.reload.credits } }

    it 'updates user_session_1 state' do
      expect { subject }.to change { user_session_1.reload.state }.from('reserved').to('canceled')
    end

    it 'updates user_session_2 state' do
      expect { subject }.to change { user_session_2.reload.state }.from('reserved').to('canceled')
    end

    it { expect { subject }.not_to change { user_session_3.reload.state } }

    it 'calls Sonar service' do
      expect(SonarService).to receive(:send_message).twice
      subject
    end

    context 'when the session has already been played' do
      let(:date) { Time.zone.today - 2.days }

      it { expect { subject }.to raise_error(PastSessionException) }

      it { expect { subject rescue nil }.not_to change(Session, :count) }
      it { expect { subject rescue nil }.not_to change { user_session_1.user.reload.credits } }
      it { expect { subject rescue nil }.not_to change { user_session_1.reload.state } }
    end

    context 'when the session is recurring' do
      let!(:session) { create(:session, :daily) }

      it { expect { subject }.not_to change(Session, :count) }
      it { expect { subject }.to change { session.session_exceptions.reload.count }.by(1) }
      it { expect { subject }.to change { user_session_1.user.reload.credits }.by(1) }

      it 'updates user_session_1 state' do
        expect { subject }.to change { user_session_1.reload.state }.from('reserved').to('canceled')
      end
    end
  end
end
