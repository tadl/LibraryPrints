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
  config.default_items_per_page = 10

  # ─ App name & included models ────────────────────────
  config.main_app_name   = ['Library Prints','Admin']
  config.included_models = %w[
    StaffUser
    Patron
    Job
    Status
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
      only ['Message','FilamentColor','Status']
      visible do
        bindings[:controller].current_staff_user.admin?
      end
    end
  end

  # ──────────────────────────────────────────────────────
  # Printer, StaffUser, Patron, Conversation, Message
  # (all left unchanged)…

  config.model 'Printer' do
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Admin'
    weight           195
    label             'Printer'
    label_plural      'Printers'
    list do
      sort_by :name
      field :id
      field :name
      field :pickup_location
      field :printer_type
      field :printer_model
      field :bed_size
      field :location
    end
    show do
      field :id
      field :name
      field :pickup_location
      field :printer_type
      field :printer_model
      field :bed_size
      field :location
      field :created_at
      field :updated_at
    end
    edit do
      field :name
      field :pickup_location, :belongs_to_association do  # ← this is the key
        label 'Pickup Location'
        inline_add  { bindings[:controller].current_staff_user.admin? }
        inline_edit { bindings[:controller].current_staff_user.admin? }
        associated_collection_scope { Proc.new { |scope| scope.order(:name) } }
      end
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

  config.model 'Status' do
    visible { bindings[:controller].current_staff_user.admin? }
    navigation_label 'Admin'
    weight           212
    label_plural     'Statuses'

    list do
      field :id
      field :name
      field :code
      field :position
      field :jobs_count do
        label 'Job Count'
        # will call Status#jobs_count
        pretty_value do
          bindings[:object].jobs_count
        end
        # disable sorting/search on this virtual
        sortable false
        searchable false
      end
    end

    edit do
      field :name
      field :code
      field :position
    end
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
    list do
      exclude_fields :images
    end
  end

  # ─ Job (formerly PrintJob) ────────────────────────────
  config.model 'Job' do
    navigation_label 'Management'
    weight           300
    label_plural     'Jobs'

    list do
      sort_by :created_at

      field :patron
      field :status, :belongs_to_association do
        label 'Status'
        pretty_value do
          bindings[:object].status.name
        end
        filterable true
        filter_options do
          Status.all.map { |s| [s.name, s.id] }
        end
      end
      field :category do
        label 'Category'
      end

      field :type, :enum do
        label 'Job Type'
        enum { [['Print', 'PrintJob'], ['Scan', 'ScanJob']] }
        filterable true
        filter_options { [['Print', 'PrintJob'], ['Scan', 'ScanJob']] }
        pretty_value do
          value == 'PrintJob' ? 'Print' : 'Scan'
        end
      end

      field :pickup_location
      field :assigned_printer do
        label 'Assigned Printer'
      end
      field :created_at
    end

    show do
      field :id
      field :patron
      field :status, :belongs_to_association do
        label 'Status'
        pretty_value do
          bindings[:object].status.name
        end
      end
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
      field :scan_images do
        label 'Scan Images'
        visible { bindings[:object].is_a?(ScanJob) }
        pretty_value do
          bindings[:object].scan_images.map do |attach|
            # thumbnail
            thumb = begin
              bindings[:view].image_tag(
                attach.variant(resize_to_limit: [100, 100])
              )
            rescue
              ''
            end

            # manually build the relative blob path:
            signed_id = attach.blob.signed_id
            filename  = ERB::Util.url_encode(attach.filename.to_s)
            blob_path = "/rails/active_storage/blobs/#{signed_id}/#{filename}"

            link = bindings[:view].link_to(
              attach.filename.to_s,
              blob_path,
              download: attach.filename.to_s
            )

            "#{thumb} #{link}"
          end.join('<br>').html_safe
        end
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

      field :status, :belongs_to_association do
        label 'Status'
        associated_collection_scope do
          Proc.new { |scope| scope.order(:position) }
        end
      end

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

      field :pickup_location, :enum do
        label 'Pickup Location'
        required true
        enum do
          PickupLocation.where(active: true).order(:position).map { |pl| [pl.name, pl.code] }
        end
        help 'Where should this job be picked up (or scan dropped off)?'
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

        field :scan_images, :active_storage do
          # show a <input type="file" multiple>
          html_attributes { { multiple: true } }

          # disable RailsAdmin's built-in blob preview (which was blowing up)
          pretty_value do
            '' 
          end

          # use help text to render your own thumbnails + download links
          help do
            attachments = bindings[:object].scan_images
            if attachments.any?
              attachments.map do |attach|
                # thumbnail
                thumb = begin
                          bindings[:view].image_tag(
                            attach.variant(resize_to_limit: [100, 100])
                          )
                        rescue
                          ''
                        end
                # manual blob path
                signed_id = attach.blob.signed_id
                filename  = ERB::Util.url_encode(attach.filename.to_s)
                blob_path = "/rails/active_storage/blobs/#{signed_id}/#{filename}"

                link = bindings[:view].link_to(
                  attach.filename.to_s,
                  blob_path,
                  download: attach.filename.to_s
                )

                "#{thumb} #{link}"
              end.join('<br>').html_safe
            end
          end
        end

        field :spray_ok
        field :notes
      end
      field :print_type, :enum do
        required true
        enum do
          %w[FDM Resin].map { |v| [v, v] }
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
        # optional: allow inline creation/editing
        inline_add  { bindings[:controller].current_staff_user.admin? }
        inline_edit { bindings[:controller].current_staff_user.admin? }
        # order the dropdown by printer name
        associated_collection_scope do
          Proc.new { |scope| scope.order(:name) }
        end
      end
    end
  end
end
