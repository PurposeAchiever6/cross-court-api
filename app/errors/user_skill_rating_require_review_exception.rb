class UserSkillRatingRequireReviewException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.users.skill_rating_require_review')

    super(message)
  end
end
