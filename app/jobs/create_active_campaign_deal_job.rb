class CreateActiveCampaignDealJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 10.seconds, attempts: 10 do |job, error|
    job.log_error(job, error)
  end

  def log_error(job, exception)
    message = "Error when calling ActiveCampaign: #{exception.message} with arguments: #{job.arguments}"
    Rails.logger.error(message)
  end

  def perform(event, user_id, args = {})
    user = User.find(user_id)
    ActiveCampaignService.new.create_deal(event, user, args)
  end
end
