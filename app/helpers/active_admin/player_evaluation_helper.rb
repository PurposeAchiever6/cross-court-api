module ActiveAdmin
  module PlayerEvaluationHelper
    def player_evaluation_form_sections
      PlayerEvaluationFormSection.all.includes(:options)
    end
  end
end
