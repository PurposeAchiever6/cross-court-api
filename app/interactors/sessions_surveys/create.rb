module SessionsSurveys
  class Create
    include Interactor

    def call
      user = context.user
      rate = context.rate
      feedback = context.feedback

      user_session = user.last_checked_in_user_session

      SessionSurvey.create!(user:, user_session:, rate:, feedback:)
    end
  end
end
