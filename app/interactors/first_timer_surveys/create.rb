module FirstTimerSurveys
  class Create
    include Interactor

    def call
      user = context.user
      how_do_you_hear_about_us = context.how_do_you_hear_about_us

      survey = FirstTimerSurvey.find_or_create_by!(user: user)
      survey.update!(how_do_you_hear_about_us: how_do_you_hear_about_us)
    end
  end
end
