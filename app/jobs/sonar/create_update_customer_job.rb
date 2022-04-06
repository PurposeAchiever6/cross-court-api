module Sonar
  class CreateUpdateCustomerJob < ApplicationJob
    queue_as :default

    def perform(user_id)
      user = User.find(user_id)
      SonarService.add_update_customer(user)
    end
  end
end
