class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, except: :events

  before_action :set_paper_trail_whodunnit

  protected

  def admin_request?
    request.path.start_with?('/admin')
  end

  def user_for_paper_trail
    return "admin-#{current_admin_user.id}" if admin_request? && current_admin_user

    current_user ? "user-#{current_user.id}" : nil
  end
end
