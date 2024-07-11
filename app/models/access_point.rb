class AccessPoint < ApplicationRecord
  has_many :access_points_locations
  has_many :locations, through: :access_points_locations
end
