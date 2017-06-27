class Library < ApplicationRecord
  validates :name, :code, presence: true, uniqueness: true
  has_many :timetables
  # TODO: when a library is deleted any permissions related to that library should also be deleted
end
