class User < ApplicationRecord
  include Cul::Omniauth::Users

  has_many :permissions, dependent: :destroy

  before_validation :add_email

  def password
    Devise.friendly_token[0,20]
  end

  def password=(*val)
  end

  def admin?
    can? :manage, :all
  end

  def editor?
    !edit_permissions.count.zero?
  end

  def edit_permissions
    self.permissions
      .where(action: 'edit', subject_class: Library.to_s)
      .where.not(subject_id: nil)
  end

  # Updating permissions. Destroys all previously definited permissions.
  # Recreates them based on the paramters given. If admin flag is true,
  # adds adnub access (can :manage, all). If not admin, recreates editor
  # permissions using the array given.
  def update_permissions(params)
    admin = params.fetch(:admin, false)
    library_ids = params.fetch(:library_ids, [])

    admin = ActiveRecord::Type::Boolean.new.cast(admin) # Convert to bool.
    return if(admin && self.admin?)

    self.permissions.destroy_all

    # Check that all library ids are valid.
    begin
      Library.find(library_ids)
    rescue RecordNotFound => e
      errors.add(:permissions, message: "One or more of the library ids given is invalid") # could probably use e to find out what the invalid record is
      return false
    end

    if admin
      permissions.create(action: 'manage', subject_class: 'all')
    else
      library_ids.each do |id|
        permissions.create(action: 'edit', subject_class: Library.to_s, subject_id: id)
      end
    end

    return true
  end

  def add_email
    if self.uid.present?
      self.email = self.uid + "@columbia.edu"
    else
      return false
    end
  end
end
