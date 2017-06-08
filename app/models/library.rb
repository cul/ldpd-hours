class Library < ApplicationRecord
	# self.primary_key = "code"
 	validates :name, :code, presence: true, uniqueness: true
end
