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
    Printer
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

  config.model 'Printer' do
    visible do
      bindings[:controller].current_staff_user.admin?
    end
    navigation_label 'Admin'
    weight           195
    label             'Printer'
    label_plural      'Printers'

    list do
      sort_by :name
      field :id
      field :name
      field :printer_type
      field :printer_model
      field :bed_size
      field :location
    end

    show do
      field :id
      field :name
      field :printer_type
      field :printer_model
      field :bed_size
      field :location
      field :created_at
      field :updated_at
    end

    edit do
      field :name
      field :printer_type, :enum do
        enum { ['FDM', 'Resin', 'Scan'] }
        help 'e.g. FDM, Resin, Scan'
      end
      field :printer_model
      field :bed_size, :string do
        help 'e.g. 200x200x200 mm'
      end
      field :location
    end
  end

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
      field :assigned_printer do
        label 'Assigned Printer'
      end
      field :pickup_location
      field :created_at
    end

    show do
      field :id
      field :patron
      field :status
      field :job_type
      field :print_type
      field :print_time_estimate
      field :slicer_weight
      field :slicer_cost
      field :actual_weight
      field :actual_cost
      field :completion_date
      field :assigned_printer do
        label 'Assigned Printer'
      end
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
      field :job_type, :enum do
        enum do
          %w[Patron Staff Assistive\ Aid Fidget Scan].map { |v| [v, v] }
        end
      end
      field :print_type, :enum do
        enum do
          %w[FDM Resin Scan].map { |v| [v, v] }
        end
        default_value { 'FDM' }
      end
      field :print_time_estimate
      field :slicer_weight
      field :slicer_cost
      field :actual_weight
      field :actual_cost
      field :completion_date, :date
      field :assigned_printer do
        label 'Assigned Printer'
        associated_collection_scope do
          Proc.new { |scope|
            scope.order(:name)
          }
        end
      end

      field :filament_color, :enum do
        label 'Filament Color'
        enum do
          FilamentColor.all.map { |c| [c.name, c.code] }
        end
        default_value { bindings[:object].filament_color }
      end

      field :pickup_location, :enum do
        label 'Pickup Location'
        enum do
          PickupLocation.where(active: true)
                        .map { |pl| [pl.name, pl.code] }
        end
        default_value { bindings[:object].pickup_location }
      end

      field :model_file, :active_storage
      field :description, :text
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
