module Hours
  module WifiDensity
    def self.wifi_data_cache_duration
      WIFI_DENSITY['data_cache_duration']
    end

    def self.data_url
      WIFI_DENSITY['data_url']
    end

    def self.percentage_for(location)
      # If this location's code is not mapped in the wifi density config file,
      # that means wifi density info is not supported for the location.
      config_for_location = WIFI_DENSITY['locations'][location.code]
      return nil if config_for_location.nil? || !config_for_location.key?('high') || !config_for_location.key?('cuit_location_ids')
      Rails.cache.fetch('wifi_density_data-' + location.code, expires_in: wifi_data_cache_duration) do
        wifi_density_data_for_locations = Rails.cache.fetch('wifi_density_data', expires_in: wifi_data_cache_duration) do
          fetch_hierarchical_wifi_density_data
        end
        aggregated_locations = {}

        config_for_location['cuit_location_ids'].each do |cuit_location_id|
          location_data = wifi_density_data_for_locations[cuit_location_id.to_s]
          next if location_data.nil?
          aggregated_locations.merge!({cuit_location_id.to_s => location_data})
          aggregated_locations.merge!(recursively_collect_children(location_data))
        end

        # Sum client_count totals from all aggregated locations
        total_client_count = aggregated_locations.values.reduce(0) do |count, location_data|
          count + location_data.fetch('client_count', 0).to_i
        end

        # If total client count is actually reported to be zero, return zero
        return 0 if total_client_count == 0

        # Make sure to use float division here so we can calculate a percentage.
        percentage_integer = ((total_client_count / config_for_location['high'].to_f) * 100).round
        if percentage_integer < 1
          # If there is at least one client, it seems incorrect to say 0%, so always return a minimum of 1%.
          1
        elsif percentage_integer > 100
          # If the expected high was set too low (in wifi_density.yml), we may get a percentage above 100%, so cap at 100%.
          100
        else
          percentage_integer
        end
      end
    end

    def self.fetch_raw_wifi_density_data
      if Rails.env.development?
        JSON.parse(File.read(Rails.root.join('spec/fixtures/files/sample-wifi-density-response.json')))
      else
        JSON.parse(Net::HTTP.get(URI(data_url)))
      end
    end

    def self.fetch_hierarchical_wifi_density_data
      all_location_data = fetch_raw_wifi_density_data

      # Convert raw data into hierarchical data, generating top level entries
      # for any referenced parent_id values that don't exist.

      # Often, we'll get data for locations that reference parent_id values, but
      # those parent_id values won't be in the data.  There are inconsistencies between
      # the sample data that CUIT sent us and the actual data from the feed. Despite this,
      # our code relies on the assumption that the parent_id values are valid whether
      # or not wifi data is sent for those parent values.
      all_location_data.keys.each do |cuit_location_id|
        parent_id = all_location_data[cuit_location_id]['parent_id']
        next if parent_id.nil?
        all_location_data[parent_id] ||= { 'name' => "Location #{parent_id}" }
      end
      # Aggregate child objects under parent objects in 'children' field
      all_location_data.each do |cuit_location_id, single_location_data|
        parent_id = single_location_data['parent_id']
        next if parent_id.nil?
        all_location_data[parent_id]['children'] ||= {}
        all_location_data[parent_id]['children'][cuit_location_id] = single_location_data
      end
      all_location_data
    end

    def self.recursively_collect_children(location_data, children = {})
      if location_data['children']
        location_data['children'].each do |child_location_id, child_location_data|
          # to avoid infinite recursion in the case of bad source data,
          # do not pursue further recursion if this child_location_id is already
          # in the children hash
          unless children.key?(child_location_id)
            children[child_location_id] = child_location_data
            recursively_collect_children(child_location_data, children)
          end
        end
      end
      children
    end
  end
end
