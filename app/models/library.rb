class Library < ApplicationRecord
 	validates :name, :code, presence: true, uniqueness: true
 	has_many :timetables
end
