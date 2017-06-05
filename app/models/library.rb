class Library < ApplicationRecord
	self.primary_key = "code"
  	has_one :calendar, primary_key: "code"
 	validates :name, :code, presence: true, uniqueness: true
end
