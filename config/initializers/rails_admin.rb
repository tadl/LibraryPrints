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
  config.included_models = %w[StaffUser Patron PrintJob FilamentColor PickupLocation]

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

  config.model 'FilamentColor' do
    navigation_label 'Form Options'
    weight 100
    label_plural 'Filament Colors'
    list do
      sort_by :name
      field :name
      field :code
    end
    edit do
      field :name
      field :code
    end
  end

  config.model 'PickupLocation' do
    navigation_label 'Form Options'
    weight 110
    label_plural 'Pickup Locations'
    list do
      sort_by :name
      field :name
      field :code
      field :active
    end
    edit do
      field :name
      field :code
      field :active
    end
  end

  config.model 'Patron' do
    navigation_label 'Admin'
    weight 200
    label_plural   'Patrons'
  end

  config.model 'StaffUser' do
    navigation_label 'Admin'
    weight 210
    label_plural   'Staff Users'
  end

  config.model 'PrintJob' do
    navigation_label 'Print Management'
    weight 300
    label_plural   'Print Jobs'
  end


end
