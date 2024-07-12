class AccessPointsLocation < ApplicationRecord
  belongs_to :location
  belongs_to :access_point
end
