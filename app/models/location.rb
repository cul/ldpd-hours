class Location < ApplicationRecord
  validates :name, :code, presence: true, uniqueness: true
  has_many :timetables
  # TODO: when a location is deleted any permissions related to that location should also be deleted
end
