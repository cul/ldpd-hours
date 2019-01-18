config_file_location = Rails.root.join('config/wifi_density.yml')
WIFI_DENSITY = File.exists?(config_file_location) ? YAML.load_file(config_file_location) : {}
