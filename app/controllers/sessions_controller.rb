# app/controllers/sessions_controller.rb

class SessionsController < ApplicationController
  # OmniAuth callback
  def create
    auth = request.env['omniauth.auth']
    staff = StaffUser.from_omniauth(auth)
    session[:staff_user_id] = staff.id
    redirect_to rails_admin.dashboard_path
  end

  # Logout
  def destroy
    session.delete(:staff_user_id)
    redirect_to root_path
  end
end
