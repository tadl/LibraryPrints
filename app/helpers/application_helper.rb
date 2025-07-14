module ApplicationHelper
  # Returns an Array of crumb hashes: { name:, path: (optional) }
  def breadcrumb_items
    # Don’t show on any of these “public” form pages
    skip = %w[
      submit_print create_print_job
      submit_scan  create_scan_job
      token_request send_token
      token_thank_you thank_you
    ]
    return [] if controller_name == 'portal' && skip.include?(action_name)

    items = []
    # always start with Home
    items << { name: 'Home', path: root_path }

    if controller_name == 'portal'
      case action_name
      when 'dashboard'
        items << { name: 'Dashboard' }
      when 'show', 'create_message'
        items << { name: 'Dashboard', path: dashboard_path }
        items << { name: 'Details' }
      end
    end

    items
  end
end
