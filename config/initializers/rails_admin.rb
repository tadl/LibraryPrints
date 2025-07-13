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
    Job
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

    # custom Conversation button on Jobs
    conversation do
      only ['Job']
    end

    delete do
      only ['Message','FilamentColor']
      visible do
        bindings[:controller].current_staff_user.admin?
      end
    end
  end

  # ──────────────────────────────────────────────────────
  # Printer, StaffUser, Patron, Conversation, Message
  # (all left unchanged)…
  # ──────────────────────────────────────────────────────

  config.model 'Printer' do
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Admin'
    weight           195
    label             'Printer'
    label_plural      'Printers'
    list do
      sort_by :name
      field :id; field :name; field :printer_type; field :printer_model; field :bed_size; field :location
    end
    show do
      field :id; field :name; field :printer_type; field :printer_model; field :bed_size; field :location
      field :created_at; field :updated_at
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
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Admin'
    weight           200
    label_plural     'Staff Users'
    list do
      field :id; field :name; field :email; field :admin
    end
    edit do
      field(:name)  { read_only true }
      field(:email) { read_only true }
      field :admin
    end
  end

  config.model 'Patron' do
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Admin'
    weight           210
    label_plural     'Patrons'
  end

  config.model 'Conversation' do
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Admin'
    weight           220
    label_plural     'Conversations'
  end

  config.model 'Message' do
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Admin'
    weight           230
    label_plural     'Messages'
  end

  # ─ Job (formerly PrintJob) ────────────────────────────
  config.model 'Job' do
    navigation_label 'Management'
    weight           300
    label_plural     'Jobs'

    list do
      sort_by :created_at
      field :id
      field :patron
      field :status
      field :category do
        label 'Category'
      end
      field :print_type
      field :pickup_location
      field :assigned_printer do
        label 'Assigned Printer'
      end
      field :created_at
    end

    show do
      field :id
      field :patron
      field :status
      field :category do
        label 'Category'
      end
      field :type do
        label 'Job Type'
      end

      ## Print-only fields
      field :model_file, :active_storage do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :url do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :filament_color do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :print_time_estimate do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :slicer_weight do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :slicer_cost do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :actual_weight do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :actual_cost do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :completion_date, :date do
        visible { bindings[:object].is_a?(PrintJob) }
      end
      field :assigned_printer, :belongs_to_association do
        label    'Assigned Printer'
        visible  { bindings[:object].is_a?(PrintJob) }
      end

      ## Scan-only fields
      field :scan_images, :active_storage do
        visible { bindings[:object].is_a?(ScanJob) }
      end
      field :spray_ok do
        label   'Spray OK?'
        visible { bindings[:object].is_a?(ScanJob) }
      end
      field :notes do
        visible { bindings[:object].is_a?(ScanJob) }
      end

      ## Shared
      field :pickup_location
      field :description
      field :created_at
      field :updated_at
    end

    edit do
      field :patron do
        inline_add   { bindings[:controller].current_staff_user.admin? }
        inline_edit  { bindings[:controller].current_staff_user.admin? }
      end

      field :status

      field :category, :enum do
        label    'Category'
        required true
        enum do
          %w[Patron Staff Assistive\ Aid Fidget Scan].map { |v| [v, v] }
        end
        default_value { bindings[:object].category || 'Patron' }
      end

      field :type, :enum do
        label 'Job Type'
        enum { [['Print', 'PrintJob'], ['Scan', 'ScanJob']] }
        default_value { bindings[:object].type || 'PrintJob' }
      end

      group :print_fields do
        label   'Print-only fields'
        visible { bindings[:object].is_a?(PrintJob) }
        field :model_file, :active_storage
        field :url
        field :filament_color
        field :print_time_estimate
        field :slicer_weight
        field :slicer_cost
        field :actual_weight
        field :actual_cost
        field :completion_date, :date
        field :pickup_location, :enum do
          enum do
            PickupLocation.active.map { |pl| [pl.name, pl.code] }
          end
        end
        field :assigned_printer, :belongs_to_association do
          label 'Assigned Printer'
          inline_add   { bindings[:controller].current_staff_user.admin? }
          inline_edit  { bindings[:controller].current_staff_user.admin? }
          associated_collection_scope { Proc.new { |scope| scope.order(:name) } }
          visible { bindings[:object].is_a?(PrintJob) }
        end
      end

      group :scan_fields do
        label   'Scan-only fields'
        visible { bindings[:object].is_a?(ScanJob) }
        field :scan_images, :active_storage
        field :spray_ok
        field :notes
        field :pickup_location, :enum do
          enum do
            PickupLocation.active.map { |pl| [pl.name, pl.code] }
          end
        end
      end

      field :print_type, :enum do
        required true
        enum do
          %w[FDM Resin Scan].map { |v| [v, v] }
        end
        default_value { 'FDM' }
      end

      field :description, :text
    end
  end

  # ─ FilamentColor & PickupLocation (unchanged) ─────────
  config.model 'FilamentColor' do
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Form Options'
    weight           100
    label_plural     'Filament Colors'
    list do
      sort_by :name; field :name; field :code
    end
    edit do
      field :name; field :code
    end
  end

  config.model 'PickupLocation' do
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Form Options'
    weight           110
    label_plural     'Pickup Locations'
    list do
      sort_by :name; field :name; field :code; field :active
    end
    edit do
      field :name; field :code; field :active
    end
  end
end
