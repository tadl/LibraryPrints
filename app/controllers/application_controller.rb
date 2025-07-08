# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  helper_method :current_staff_user

  def current_staff_user
    @current_staff_user ||= StaffUser.find_by(id: session[:staff_user_id])
  end

  private

end
