require 'rails_helper'

describe SurveySmsJob do
  describe '.perform' do
    before do
      allow(SonarService).to receive(:send_message)
      Timecop.freeze(Time.current)
    end

    after do
      Timecop.return
    end

    let(:los_angeles_time) do
      Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
    end
    let(:los_angeles_date) { los_angeles_time.to_date }

    let!(:session_1) { create(:session, time: los_angeles_time - 1.5.hours) }

    let!(:user_session_1) do
      create(:user_session, session: session_1, checked_in: true, date: los_angeles_date)
    end
    let!(:user_session_2) do
      create(:user_session, session: session_1, checked_in: true, date: los_angeles_date)
    end
    let!(:user_session_3) do
      create(:user_session, session: session_1, checked_in: true, date: los_angeles_date + 1.day)
    end
    let!(:user_session_4) do
      create(:user_session, session: session_1, checked_in: false, date: los_angeles_date)
    end

    let(:expected_message_user_1) do
      I18n.t(
        'notifier.survey_reminder',
        name: user_session_1.user.first_name,
        survey_link: "#{ENV['FRONTENT_URL']}/survey"
      )
    end

    let(:expected_message_user_2) do
      I18n.t(
        'notifier.survey_reminder',
        name: user_session_2.user.first_name,
        survey_link: "#{ENV['FRONTENT_URL']}/survey"
      )
    end

    subject { described_class.perform_now }

    it 'calls the SonarService with the correct parameters' do
      expect(SonarService).to receive(:send_message).with(user_session_1.user, expected_message_user_1).once
      expect(SonarService).to receive(:send_message).with(user_session_2.user, expected_message_user_2).once

      subject
    end
  end
end