class User < ApplicationRecord
  has_many :permissions, dependent: :destroy

  before_validation :add_ldap_info

  # Configure devise
  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [Rails.env.development? ? :developer : :cas]

  def password
    Devise.friendly_token[0,20]
  end

  def password=(*val)
  end

  def administrator?
    !self.permissions.admin_roles.blank?
  end

  def manager?
    !self.permissions.manager_roles.blank?
  end

  def editor?
    !self.permissions.editor_roles.blank?
  end

  def role
    Permission::VALID_ROLES.find { |role| send("#{role}?") }
  end

  def has_role?
    !role.blank?
  end

  def editable_locations
    self.permissions
      .editor_roles
      .map{ |p| Location.find(p.subject_id) }
  end

  # Updating permissions. Destroys all previously defined permissions.
  # Recreates them based on the parameters given. If 'administrator' or 'manager'
  # role is given, adds in corresponding permission for user. If 'editor' is
  # passed in as the role editor permissions are added based on the the list if
  # location_ids given. location_ids are ignored if passed in with
  # 'administrator' or 'manager' role.
  #
  # @return [true] if updating permissions was successful
  # @return [false] if updating permissions failed
  def update_permissions(params)
    role = params.fetch(:role, nil)
    location_ids = params.fetch(:location_ids, [])

    if role.blank?
      errors.add(:permissions, :invalid, message: "role cannot be blank")
      return false
    elsif !Permission::VALID_ROLES.include?(role)
      errors.add(:permissions, :invalid, message: "role not valid")
      return false
    end

    # If correct role is already set, skip.
    return true if (role == Permission::ADMINISTRATOR) && self.administrator?
    return true if (role == Permission::MANAGER) && self.manager?

    if role == Permission::EDITOR
      # Check that all location ids are valid.
      begin
        Location.find(location_ids)
      rescue ActiveRecord::RecordNotFound => e
        errors.add(:permissions, :invalid, message: "one or more of the location ids given is invalid") # TODO: could probably use e to find out what the invalid record is
        return false
      end
    end

    self.permissions.destroy_all

    case role
    when Permission::ADMINISTRATOR, Permission::MANAGER
      permissions.create(role: role)
    when Permission::EDITOR
      location_ids.each do |id|
        permissions.create(role: role, subject_class: Location.to_s, subject_id: id)
      end
    end

    true
  end

  private

  def add_ldap_info
    return false unless self.uid.present?
    return true if self.email.present? && self.name.present?
    ldap = Cul::LDAP.new
    if entry = ldap.find_by_uni(self.uid)
      self.email = entry.email
      self.name = entry.name
    end
  end
end
