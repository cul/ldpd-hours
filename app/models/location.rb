class Location < ApplicationRecord
  validates :name, :code, presence: true, uniqueness: { case_sensitive: true }
  validate :primary_location_must_be_primary

  has_many :timetables
  has_many :access_points_locations
  has_many :access_points, through: :access_points_locations

  belongs_to :primary_location, class_name: 'Location', foreign_key: 'primary_location_id', optional: true
  accepts_nested_attributes_for :access_points

  # TODO: when a location is deleted any permissions related to that location should also be deleted

  def primary_location_must_be_primary
    if primary_location
      if primary
        errors.add :primary_location, "primary locations cannot have a primary location"
      end

      unless primary_location.primary == true
        errors.add :primary_location, "cannot assign non-primary location as primary location"
      end
    end
  end

  def self.attributes_protected_by_default
    [] # override ["id"]
  end

  # Note: To build an API response for a single date value,
  # call this method with both the start_date and
  # end_date set to the single date value.
  def build_api_response(start_date, end_date)
    if start_date > end_date
      raise RangeError.new("build_api_response: start_date is larger than end_date.")
    end

    # Note: date_range is a scope defined in timetable.rb

    # Old behavior : return nothing for non-existent timetables. Just the
    # following one-liner, in case want to revert back to that behavior
    # timetables.date_range(start_date,end_date).map {|t| t.api_response_hash}

    # New behavior: Instead of no-op for non-existent timetables, we want to return
    # a hash with default values for each non-existent timetable
    hash = timetables.date_range(start_date,end_date).map do |t|
      [t.date.strftime("%F"),  t.day_info_hash]
    end.to_h
    (start_date..end_date).map do |d|
      hash.fetch(d.strftime("%F"), Timetable.default_day_info_hash(d))
    end
  end
end
