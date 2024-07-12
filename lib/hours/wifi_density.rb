module Hours
  module WifiDensity
    def self.wifi_data_cache_duration
      WIFI_DENSITY[:data_cache_duration]
    end

    def self.data_url
      WIFI_DENSITY[:data_url]
    end

    def self.percentage_for(location)
      # If this location's code is not mapped in the wifi density config file,
      # that means wifi density info is not supported for the location.
      config_for_location = location_wifi_configuration(location)
      return nil if config_for_location.nil? || !config_for_location.key?(:high) || !config_for_location.key?(:cuit_location_ids)
      Rails.cache.fetch('wifi_density_data-' + location.code, expires_in: wifi_data_cache_duration) do
        wifi_density_data_for_locations = hierarchical_wifi_density_data
        aggregated_locations = {}

        config_for_location[:cuit_location_ids]&.each do |cuit_location_id|
          location_data = wifi_density_data_for_locations[cuit_location_id.to_s]
          next if location_data.nil?
          aggregated_locations.merge!({cuit_location_id.to_s => location_data})
          aggregated_locations.merge!(recursively_collect_children(location_data))
        end

        # Return nil if no aggregated_locations were found for the given id.
        # This indicates that we have no data for this location.
        return nil if aggregated_locations.blank?

        # Sum client_count totals from all aggregated locations
        total_client_count = aggregated_locations.values.reduce(0) do |count, location_data|
          count + location_data.fetch('client_count', 0).to_i
        end

        # If total client count is actually reported to be zero, return zero
        return 0 if total_client_count == 0

        # Make sure to use float division here so we can calculate a percentage.
        percentage_integer = ((total_client_count / config_for_location[:high].to_f) * 100).round
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

    def self.location_wifi_configuration(location)
      {
        high: (location.wifi_connections_baseline.to_i if location.wifi_connections_baseline.present?),
        cuit_location_ids: (location.access_point_ids.map(&:to_s) if location.access_point_ids.present?)
      }
    end

    def self.raw_wifi_density_data
      Rails.cache.fetch('raw_wifi_density_data', expires_in: wifi_data_cache_duration) do
        cacheable_data = fetch_raw_wifi_density_data
        now = DateTime.now
        cacheable_data.each do |ap_id, location_data|
          ap = AccessPoint.find_or_create_by(id: ap_id)
          if ap.client_count != location_data['client_count'].to_i
            ap.update(client_count: location_data['client_count'].to_i)
            location_data['updated_at'] = now
          else
            location_data['updated_at'] = ap.updated_at
          end
        end
        cacheable_data
      end
    end

    def self.fetch_raw_wifi_density_data
      if Rails.env.development? || Rails.env.test?
        JSON.parse(File.read(Rails.root.join('spec/fixtures/files/sample-wifi-density-response.json')))
      else
        JSON.parse(Net::HTTP.get(URI(data_url)))
      end
    end

    def self.hierarchical_wifi_density_data
      Rails.cache.fetch('hierarchical_wifi_density_data', expires_in: wifi_data_cache_duration) do
        fetch_hierarchical_wifi_density_data
      end
    end

    def self.fetch_hierarchical_wifi_density_data
      all_location_data = raw_wifi_density_data

      stale_time = DateTime.now - 2.hours
      all_location_data.reject! { |k, v| v['updated_at'] < stale_time }

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

    # add child access point nodes to their parent's children hash
    # but keep them in the top-level hash
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

    def self.default_access_point_data_for_id(ap_id, suffix = "")
      { 'id' => ap_id, 'name' => "Location #{ap_id}#{suffix}" }
    end

    def self.access_point_trees(location = nil)
      stored_ids = location ? location.access_point_ids.to_a : []
      aggregated_locations = raw_wifi_density_data.reduce({}) do |acc, entry|
        ap_id, ap_data = *entry
        acc[ap_id] ||= default_access_point_data_for_id(ap_id)
        acc[ap_id].merge!(ap_data)
        if parent_id = ap_data['parent_id']
          acc[parent_id] ||= default_access_point_data_for_id(parent_id)
        end
        acc
      end

      roots = rollup_children(aggregated_locations).transform_values(&:deep_symbolize_keys)
      stored_ids.each { |id| roots[id.to_s] ||= default_access_point_data_for_id(id, " [no current data]").symbolize_keys }
      roots.map { |k,v| AccessPointStruct.new(**v) }
    end

    # add child access point nodes to their parent's children hash
    # and remove them from the top-level hash
    def self.rollup_children(data = {})
      parent_ids = data.values.map { |v| v['parent_id'] }.compact
      return data if parent_ids.length == 0

      (data.keys - parent_ids).each do |leaf_id|
        leaf = data[leaf_id]
        next unless parent_id = leaf['parent_id']
        parent = data[parent_id] ||= default_access_point_data_for_id(parent_id)
        (parent['children'] ||= {})[leaf_id] = data.delete(leaf_id)
      end
      rollup_children(data)
    end

    class AccessPointStruct
      attr_accessor :children, :id, :name, :parent_id, :updated_at
      def initialize(children: nil, id:, name:, parent_id: nil, updated_at: nil, **args)
        @id = id
        @name = name
        @parent_id = parent_id
        @updated_at = updated_at
        @children = (children || {}).transform_values { |c| AccessPointStruct.new(**c) }
      end
    end
  end
end
