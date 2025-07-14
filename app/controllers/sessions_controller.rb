# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  # -- your existing staff login logic stays untouched --
  def create
    auth = request.env['omniauth.auth']
    staff = StaffUser.from_omniauth(auth)
    session[:staff_user_id] = staff.id
    redirect_to rails_admin.dashboard_path
  end

  # DELETE /logout
  def destroy
    if current_staff_user
      session.delete(:staff_user_id)
      reset_session
      redirect_to root_path, notice: "Staff user signed out."

    elsif cookies.encrypted[:patron_id]
      # expire the Patron’s token so the magic-link can’t be reused
      if (patron = Patron.find_by(id: cookies.encrypted[:patron_id]))
        patron.expire_token!
      end

      cookies.delete(:patron_id)
      reset_session
      redirect_to root_path, notice: "You’ve been logged out."

    else
      reset_session
      redirect_to root_path
    end
  end

  private

  # (Optional) Example OAuth revoke helper—call it above if needed
  def revoke_oauth_token(token)
    client = OAuth2::Client.new(
      Rails.application.credentials.dig(:oauth, :client_id),
      Rails.application.credentials.dig(:oauth, :client_secret),
      site: 'https://oauth2.googleapis.com'
    )
    client.request(:post, '/revoke', params: { token: token })
  rescue => e
    Rails.logger.warn("Token revoke failed: #{e.message}")
  end
end
