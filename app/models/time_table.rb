class TimeTable < ApplicationRecord
  	belongs_to :library, primary_key: "code"
end