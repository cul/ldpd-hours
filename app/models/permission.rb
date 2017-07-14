class Permission < ApplicationRecord
  ADMINISTRATOR = 'administrator'.freeze
  MANAGER       = 'manager'.freeze
  EDITOR        = 'editor'.freeze

  VALID_ROLES = [ADMINISTRATOR, MANAGER, EDITOR]

  belongs_to :user
  validates :role, presence: true

  scope :admin_roles,   -> { where(role: ADMINISTRATOR, subject_class: nil, subject_id: nil) }
  scope :manager_roles, -> { where(role: MANAGER, subject_class: nil, subject_id: nil) }
  scope :editor_roles, -> { where(role: EDITOR, subject_class: Location.to_s).where.not(subject_id: nil) }
end
