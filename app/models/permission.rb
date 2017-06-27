class Permission < ApplicationRecord
  belongs_to :user
  validates :action, :subject_class, presence: true
end
