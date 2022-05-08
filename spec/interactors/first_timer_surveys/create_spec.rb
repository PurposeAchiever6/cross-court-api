require 'rails_helper'

describe FirstTimerSurveys::Create do
  describe '.call' do
    let!(:user) { create(:user) }
    let(:how_did_you_hear_about_us) { 'Search Engine' }

    subject do
      FirstTimerSurveys::Create.call(
        user: user,
        how_did_you_hear_about_us: how_did_you_hear_about_us
      )
    end

    it { expect { subject }.to change(FirstTimerSurvey, :count).by(1) }

    it 'assigns the right user' do
      subject
      expect(FirstTimerSurvey.last.user).to eq(user)
    end

    it 'assigns the right how_did_you_hear_about_us value' do
      subject
      expect(FirstTimerSurvey.last.how_did_you_hear_about_us).to eq(how_did_you_hear_about_us)
    end

    context 'when the user already has a FirstTimerSurvey' do
      let(:old_how_did_you_hear_about_us) { 'Facebook' }
      let!(:first_timer_survey) do
        create(
          :first_timer_survey,
          user: user,
          how_did_you_hear_about_us: old_how_did_you_hear_about_us
        )
      end

      it { expect { subject }.not_to change(FirstTimerSurvey, :count) }

      it 'updates the how_did_you_hear_about_us column' do
        expect {
          subject
        }.to change {
          first_timer_survey.reload.how_did_you_hear_about_us
        }.from(old_how_did_you_hear_about_us).to(how_did_you_hear_about_us)
      end
    end
  end
end
