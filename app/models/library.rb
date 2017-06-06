class Library < ApplicationRecord
	self.primary_key = "code"
  	has_many :library_calendars, primary_key: "code"
 	validates :name, :code, presence: true, uniqueness: true
end
