require 'rails_helper'

describe Users::UpdateSkillRating do
  describe '.call' do
    let!(:user) { create(:user, skill_rating: old_skill_rating) }

    let(:old_skill_rating) { nil }
    let(:new_skill_rating) { 3 }

    before { ENV['SKILL_RATINGS_FOR_REVIEW'] = '4,5' }

    subject { Users::UpdateSkillRating.call(user: user, skill_rating: new_skill_rating) }

    it 'updates user skill rating' do
      expect {
        subject
      }.to change { user.reload.skill_rating }.from(old_skill_rating).to(new_skill_rating)
    end

    context 'when user tries to update to a reviewable skill rating' do
      let(:new_skill_rating) { [4, 5].sample }

      it 'updates user skill rating' do
        expect {
          subject
        }.to change { user.reload.skill_rating }.from(old_skill_rating).to(new_skill_rating)
      end

      context 'when user old skill rating is lower than the new one' do
        let(:old_skill_rating) { [1, 2, 3].sample }

        it { expect { subject rescue nil }.not_to change { user.reload.skill_rating } }
        it { expect { subject }.to raise_error(UserSkillRatingRequireReviewException) }

        context 'when SKILL_RATINGS_FOR_REVIEW does not match' do
          let(:new_skill_rating) { 4 }

          before { ENV['SKILL_RATINGS_FOR_REVIEW'] = '5' }

          it 'updates user skill rating' do
            expect {
              subject
            }.to change { user.reload.skill_rating }.from(old_skill_rating).to(new_skill_rating)
          end
        end
      end

      context 'when user old skill rating is higher than the new one' do
        let(:old_skill_rating) { 5 }
        let(:new_skill_rating) { 4 }

        it 'updates user skill rating' do
          expect {
            subject
          }.to change { user.reload.skill_rating }.from(old_skill_rating).to(new_skill_rating)
        end
      end
    end
  end
end
