class Library < ApplicationRecord
	validates :name, :code, presence: true, uniqueness: true
end
