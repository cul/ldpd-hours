class Location < ApplicationRecord
  validates :name, :code, presence: true, uniqueness: true
  validate :primary_location_must_be_primary

  has_many :timetables
  belongs_to :primary_location, class_name: 'Location', foreign_key: 'primary_location_id', optional: true

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
end
