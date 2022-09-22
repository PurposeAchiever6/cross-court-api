module Users
  class UpdateSkillRating
    include Interactor

    def call
      user = context.user
      new_skill_rating = context.skill_rating.to_f

      raise UserSkillRatingRequireReviewException if needs_review?(user, new_skill_rating)

      user.update!(skill_rating: new_skill_rating)
    end

    private

    def needs_review?(user, new_skill_rating)
      user_skill_rating = user.skill_rating
      skill_ratings_for_review = ENV.fetch('SKILL_RATINGS_FOR_REVIEW', '').split(',').map(&:to_f)

      user_skill_rating \
        && user_skill_rating < new_skill_rating \
          && skill_ratings_for_review.include?(new_skill_rating)
    end
  end
end
