# config/initializers/rails_admin.rb
require Rails.root.join('lib/rails_admin/config/actions/conversation')

RailsAdmin.config do |config|
  # ─ Authentication & inheritance ───────────────────────
  config.parent_controller = '::ApplicationController'
  config.authenticate_with do
    redirect_to '/auth/google_oauth2' unless current_staff_user
  end
  config.current_user_method(&:current_staff_user)

  config.asset_source           = :sprockets
  config.default_items_per_page = 10

  # ─ App name & included models ────────────────────────
  config.main_app_name   = ['Library Prints', 'Admin']
  config.included_models = %w[
    StaffUser
    Patron
    Job
    Status
    Printer
    PrintType
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
      only ['Message', 'FilamentColor', 'Status']
      visible do
        bindings[:controller].current_staff_user.admin?
      end
    end
  end

  # ─ Printer ────────────────────────────────────────────
  config.model 'Printer' do
    visible            { bindings[:controller].current_staff_user.admin? }
    navigation_label   'Admin'
    weight              195
    label               'Printer'
    label_plural        'Printers'

    list do
      sort_by :name
      field :id
      field :name
      field :pickup_location
      field :print_type
      field :printer_model
      field :bed_size
      field :location
    end

    show do
      field :id
      field :name
      field :pickup_location
      field :print_type
      field :printer_model
      field :bed_size
      field :location
      field :created_at
      field :updated_at
    end

    edit do
      field :name
      field :pickup_location, :belongs_to_association do
        label           'Pickup Location'
        inline_add      { bindings[:controller].current_staff_user.admin? }
        inline_edit     { bindings[:controller].current_staff_user.admin? }
        associated_collection_scope { Proc.new { |scope| scope.order(:name) } }
      end
      field :print_type, :belongs_to_association do
        label           'Print Type'
        inline_add      true
        inline_edit     true
        associated_collection_scope { Proc.new { |scope| scope.order(:position) } }
      end
      field :printer_model
      field :bed_size, :string do
        help 'e.g. 200x200x200 mm'
      end
      field :location
    end
  end

  # ─ PrintType ──────────────────────────────────────────
  config.model 'PrintType' do
    visible           { bindings[:controller].current_staff_user.admin? }
    navigation_label  'Admin'
    label              'Print Type'
    label_plural       'Print Types'
    weight             198

    list do
      sort_by :position
      field :name
      field :code
      field :position
    end

    show do
      field :id
      field :name
      field :code
      field :position
      field :created_at
      field :updated_at
    end

    edit do
      field :name do
        help 'Human‐readable label (e.g. “FDM”).'
      end
      field :code do
        help 'Machine value (e.g. “fdm”). Must be unique.'
      end
      field :position do
        help 'Order in dropdowns.'
      end
    end
  end


  # ─ StaffUser ──────────────────────────────────────────
  config.model 'StaffUser' do
    visible           { bindings[:controller].current_staff_user.admin? }
    navigation_label  'Admin'
    weight             200
    label_plural       'Staff Users'

    list do
      field :id
      field :name
      field :email
      field :admin
    end

    edit do
      field(:name)  { read_only true }
      field(:email) { read_only true }
      field :admin
    end
  end

  # ─ Patron ─────────────────────────────────────────────
  config.model 'Patron' do
    visible          { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Admin'
    weight            210
    label_plural      'Patrons'
  end

  # ─ Status ─────────────────────────────────────────────
  config.model 'Status' do
    visible           { bindings[:controller].current_staff_user.admin? }
    navigation_label  'Admin'
    weight             212
    label_plural       'Statuses'

    list do
      field :id
      field :name
      field :code
      field :position
      field :jobs_count do
        label       'Job Count'
        pretty_value { bindings[:object].jobs_count }
        sortable    false
        searchable  false
      end
    end

    edit do
      field :name
      field :code
      field :position
    end
  end

  # ─ Conversation ───────────────────────────────────────
  config.model 'Conversation' do
    visible           { bindings[:controller].current_staff_user.admin? }
    navigation_label  'Admin'
    weight             220
    label_plural       'Conversations'
  end

  # ─ Message ────────────────────────────────────────────
  config.model 'Message' do
    visible           { bindings[:controller].current_staff_user.admin? }
    navigation_label  'Admin'
    weight             230
    label_plural       'Messages'

    list do
      exclude_fields :images
    end
  end

  # ─ Job (STI base for PrintJob & ScanJob) ───────────────
  config.model 'Job' do
    navigation_label 'Management'
    weight           300
    label_plural     'Jobs'

    # ---- LIST ----
    list do
      sort_by :created_at

      field :patron
      field :status, :belongs_to_association do
        label        'Status'
        pretty_value { bindings[:object].status.name }
        filterable   true
        filter_options { Status.all.map { |s| [s.name, s.id] } }
      end
      field :category
      field :type, :enum do
        label          'Job Type'
        enum           { [['Print','PrintJob'], ['Scan','ScanJob']] }
        filterable     true
        filter_options { [['Print','PrintJob'], ['Scan','ScanJob']] }
        pretty_value   { value == 'PrintJob' ? 'Print' : 'Scan' }
      end
      field :pickup_location
      field :assigned_printer do
        label 'Assigned Printer'
      end
      field :created_at
    end

    # ---- SHOW ----
    show do
      field :id
      field :patron
      field :status, :belongs_to_association do
        label        'Status'
        pretty_value { bindings[:object].status.name }
      end
      # we don’t need category shown here any more? remove if you’d like
      field :category
      field :type do
        label 'Job Type'
      end

      # print-only
      group :print_fields do
        label   'Print Details'
        visible { bindings[:object].is_a?(PrintJob) }
        field :print_type,  :belongs_to_association do
          label          'Print Type'
          pretty_value   { bindings[:object].print_type&.name }
          filterable     true
          associated_collection_scope { ->(scope){ scope.order(:position) } }
        end
        field :model_file,  :active_storage
        field :url
        field :filament_color
        field :print_time_estimate
        field :slicer_weight
        field :slicer_cost
        field :actual_weight
        field :actual_cost
        field :completion_date
        field :assigned_printer
      end

      # scan-only
      group :scan_fields do
        label   'Scan Details'
        visible { bindings[:object].is_a?(ScanJob) }

        field :scan_image, :active_storage do
          label 'Submitted Photo'
          pretty_value do
            img = bindings[:object].scan_image
            if img.attached?
              # build a thumbnail…
              thumb = bindings[:view].image_tag(
                img.variant(resize_to_limit: [300, 300]),
                class: 'rounded shadow',
                style: 'margin:4px;max-width:300px;'
              )
              # …then link it via the Rails routes helpers directly
              blob_url = Rails.application.routes.url_helpers.
                           rails_blob_path(img, disposition: 'attachment', only_path: true)
              bindings[:view].link_to(thumb, blob_url, target: '_blank', rel: 'noopener')
            else
              bindings[:view].content_tag(:em, 'No photo uploaded.')
            end
          end
        end

        field :spray_ok
        field :notes
      end

      # shared
      field :pickup_location
      field :description
      field :created_at
      field :updated_at
    end

    # ---- EDIT ----
    edit do
      field :patron do
        inline_add   { bindings[:controller].current_staff_user.admin? }
        inline_edit  { bindings[:controller].current_staff_user.admin? }
      end

      field :status, :belongs_to_association do
        label 'Status'
        associated_collection_scope { ->(scope){ scope.order(:position) } }
      end

      field :category, :enum do
        label          'Category'
        required       true
        enum           { %w[Patron Staff Assistive\ Aid Fidget Scan].map { |v| [v,v] } }
        default_value  { bindings[:object].category || 'Patron' }
      end

      field :type, :enum do
        label         'Job Type'
        enum          { [['Print','PrintJob'], ['Scan','ScanJob']] }
        default_value { bindings[:object].type || 'PrintJob' }
      end

      field :pickup_location, :enum do
        label       'Pickup Location'
        required    true
        enum        { PickupLocation.where(active: true).order(:position).pluck(:name, :code) }
        help        'Where should this job be picked up (or scan dropped off)?'
      end

      group :print_fields do
        label   'Print-only fields'
        visible { bindings[:object].is_a?(PrintJob) }

        field :print_type, :belongs_to_association do
          label                   'Print Type'
          inline_add              false
          inline_edit             false
          associated_collection_scope { ->(scope){ scope.order(:position) } }
        end
        field :model_file, :active_storage
        field :url
        field :filament_color, :enum do
          enum          { FilamentColor.order(:name).pluck(:name, :code) }
          default_value { bindings[:object].filament_color }
        end
        field :print_time_estimate
        field :slicer_weight
        field :slicer_cost
        field :actual_weight
        field :actual_cost
        field :completion_date, :date
        field :assigned_printer, :belongs_to_association do
          inline_add   { bindings[:controller].current_staff_user.admin? }
          inline_edit  { bindings[:controller].current_staff_user.admin? }
          associated_collection_scope { ->(scope){ scope.order(:name) } }
        end
      end

      group :scan_fields do
        label   'Scan-only fields'
        visible { bindings[:object].is_a?(ScanJob) }

        field :scan_image, :active_storage do
          label 'Submitted Photo'
          help  'Upload one photo (replaces the existing image)'
        end

        field :spray_ok
        field :notes
      end

      field :description, :text
    end
  end

  # ─ FilamentColor ──────────────────────────────────────
  config.model 'FilamentColor' do
    visible           { bindings[:controller].current_staff_user.admin? }
    navigation_label  'Form Options'
    weight             100
    label_plural       'Filament Colors'

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

  # ─ PickupLocation ─────────────────────────────────────
  config.model 'PickupLocation' do
    visible           { bindings[:controller].current_staff_user.admin? }
    navigation_label  'Form Options'
    weight             110
    label_plural       'Pickup Locations'

    list do
      sort_by :name
      field :name
      field :code
      field :active
      field :scanner
      field :fdm_printer
      field :resin_printer
    end

    edit do
      field :name
      field :code
      field :active
      field :scanner, :boolean do
        help "Check if this location has a 3D scanner"
      end
      field :fdm_printer, :boolean do
        help "Check if this location has an FDM printer"
      end
      field :resin_printer, :boolean do
        help "Check if this location has a resin printer"
      end
      field :printers, :has_many_association do
        label 'Printers at this Location'
        help  'Select which printers live at this pickup location'
        inline_add  { bindings[:controller].current_staff_user.admin? }
        inline_edit { bindings[:controller].current_staff_user.admin? }
        associated_collection_scope { Proc.new { |scope| scope.order(:name) } }
      end
    end
  end
end
