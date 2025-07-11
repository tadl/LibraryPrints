# config/initializers/rails_admin.rb
require Rails.root.join('lib/rails_admin/config/actions/conversation')

RailsAdmin.config do |config|
  # ─ Authentication & inheritance ───────────────────────
  config.parent_controller = '::ApplicationController'
  config.authenticate_with do
    redirect_to '/auth/google_oauth2' unless current_staff_user
  end
  config.current_user_method(&:current_staff_user)

  config.asset_source = :sprockets
  # ─ App name & included models ────────────────────────
  config.main_app_name   = ['Library Prints','Admin']
  config.included_models = %w[
    StaffUser
    Patron
    PrintJob
    FilamentColor
    PickupLocation
    Conversation
    Message
  ]

  # ─ Actions ────────────────────────────────────────────
  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new   { except ['StaffUser'] }
    export
    bulk_delete
    show
    edit

    # <–– your custom Conversation button ––>
    conversation do
      only ['PrintJob']
    end

    delete do
      only ['Message','FilamentColor']
      visible do
        bindings[:controller].current_staff_user.admin?
      end
    end
  end

  # ─ Models ─────────────────────────────────────────────

  config.model 'StaffUser' do
    visible do
      bindings[:controller].current_staff_user.admin?
    end
    navigation_label 'Admin'
    weight           200
    label_plural     'Staff Users'
    list do
      field :id
      field :name
      field :email
      field :admin
    end
    edit do
      field :name do
        read_only true
      end
      field :email do
        read_only true
      end
      field :admin
    end
  end

  config.model 'Patron' do
    visible do
      bindings[:controller].current_staff_user.admin?
    end
    navigation_label 'Admin'
    weight           210
    label_plural     'Patrons'
  end

  config.model 'Conversation' do
    visible do
      bindings[:controller].current_staff_user.admin?
    end
    navigation_label 'Admin'
    weight           220
    label_plural     'Conversations'
  end

  config.model 'Message' do
    visible do
      bindings[:controller].current_staff_user.admin?
    end
    navigation_label 'Admin'
    weight           230
    label_plural     'Messages'
  end

  config.model 'PrintJob' do
    navigation_label 'Print Management'
    weight           300
    label_plural     'Print Jobs'

    list do
      sort_by :created_at
      field :id
      field :patron
      field :status
      field :pickup_location
      field :created_at
    end

    show do
      field :id
      field :patron
      field :status
      field :description
      field :filament_color
      field :pickup_location
      field :model_file, :active_storage
      field :created_at
      field :updated_at
    end

    edit do
      field :patron
      field :status
      field :description

      field :filament_color, :enum do
        label 'Filament Color'
        enum do
          # [display_name, stored_value]
          FilamentColor.all.map { |c| [c.name, c.code] }
        end
        # pre-select the existing value:
        default_value do
          bindings[:object].filament_color
        end
      end

      field :pickup_location, :enum do
        label 'Pickup Location'
        enum do
          PickupLocation.where(active: true).map { |pl| [pl.name, pl.code] }
        end
        default_value do
          bindings[:object].pickup_location
        end
      end

      field :model_file, :active_storage
    end

  end

  config.model 'FilamentColor' do
    visible do
      bindings[:controller].current_staff_user.admin?
    end
    navigation_label 'Form Options'
    weight           100
    label_plural     'Filament Colors'
    list do
      sort_by :name
      field :name; field :code
    end
    edit do
      field :name; field :code
    end
  end

  config.model 'PickupLocation' do
    visible do
      bindings[:controller].current_staff_user.admin?
    end
    navigation_label 'Form Options'
    weight           110
    label_plural     'Pickup Locations'
    list do
      sort_by :name
      field :name; field :code; field :active
    end
    edit do
      field :name; field :code; field :active
    end
  end
end
