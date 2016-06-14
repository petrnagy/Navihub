Turnout.configure do |config|
  config.app_root = '.'
  config.named_maintenance_file_paths = {default: config.app_root.join('tmp', 'maintenance.yml').to_s}
  config.default_maintenance_page = Turnout::MaintenancePage::HTML
  config.default_reason = "We're sorry, but the page is currently unavailable because of short maintenance window.<br><br>Stay tuned! This should not take more than a few seconds."
  config.default_allowed_paths = []
  config.default_response_code = 503
  config.default_retry_after = 60
end
