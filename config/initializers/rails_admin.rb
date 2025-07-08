# config/initializers/rails_admin.rb
RailsAdmin.config do |config|
  # Make RailsAdmin controllers inherit from our ApplicationController,
  # so they have access to helper methods like `current_staff_user`.
  config.parent_controller = '::ApplicationController'

  # Authentication: redirect to Google OAuth if no signed-in staff user
  config.authenticate_with do
    redirect_to '/auth/google_oauth2' unless current_staff_user
  end

  # Tell RailsAdmin how to fetch the current user
  config.current_user_method(&:current_staff_user)

  # Optional: authorization via CanCanCan
  # config.authorize_with :cancancan

  # ==== RailsAdmin Asset Source (suppress warning) ====
  # If you prefer importmap (Rails 7), set:
  # config.asset_source = :importmap
  # Or keep sprockets by default.
  # config.asset_source = :sprockets

  # === UI & Actions Configuration (example) ===
  config.main_app_name = ['Library Prints', 'Admin']
  config.included_models = %w[StaffUser Patron PrintJob]

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new   { except ['StaffUser'] }
    export
    bulk_delete
    show
    edit
    delete
  end

  # You can further customize model config here...
end
