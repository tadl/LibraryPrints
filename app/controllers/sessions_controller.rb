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
    # —— Staff logout ——
    if current_staff_user
      # Clear the staff-user session
      session.delete(:staff_user_id)

      # (Optional) If you stored an OAuth token for staff, revoke it here
      # revoke_oauth_token(session[:oauth_token]) if session[:oauth_token]
      # session.delete(:oauth_token)

      reset_session
      redirect_to root_path, notice: "Staff user signed out."

    # —— Patron logout ——
    elsif cookies.encrypted[:patron_id]
      # If you stored a token in session or db for patrons, revoke/clear it
      session.delete(:access_token)

      # Remove the patron cookie
      cookies.delete(:patron_id)

      reset_session
      redirect_to root_path, notice: "You’ve been logged out."

    # —— Fallback ——
    else
      # No one was logged in
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
