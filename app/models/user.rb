class User < ApplicationRecord
  include Cul::Omniauth::Users

  has_many :permissions, dependent: :destroy

  before_validation :add_ldap_info

  def password
    Devise.friendly_token[0,20]
  end

  def password=(*val)
  end

  def admin?
    can? :manage, :all
  end

  def editor?
    !editable_locations.count.zero?
  end

  def editable_locations
    self.permissions
      .where(action: 'edit', subject_class: Location.to_s)
      .where.not(subject_id: nil)
      .map{ |p| Location.find(p.subject_id) }
  end

  # Updating permissions. Destroys all previously definited permissions.
  # Recreates them based on the paramters given. If admin flag is true,
  # adds adnub access (can :manage, all). If not admin, recreates editor
  # permissions using the array given.
  def update_permissions(params)
    admin = params.fetch(:admin, false)
    location_ids = params.fetch(:location_ids, [])

    admin = ActiveRecord::Type::Boolean.new.cast(admin) # Convert to bool.
    return if(admin && self.admin?)

    self.permissions.destroy_all

    # Check that all location ids are valid.
    begin
      Location.find(location_ids)
    rescue ActiveRecord::RecordNotFound => e
      errors.add(:permissions, :invalid, message: "one or more of the location ids given is invalid") # TODO: could probably use e to find out what the invalid record is
      return false
    end

    if admin
      permissions.create(action: 'manage', subject_class: 'all')
    else
      location_ids.each do |id|
        permissions.create(action: 'edit', subject_class: Location.to_s, subject_id: id)
      end
    end

    return true
  end

  private

  def add_ldap_info
    return false unless self.uid.present?
    ldap = Cul::LDAP.new
    if entry = ldap.find_by_uni(self.uid)
      self.email = entry.email
      self.name = entry.name
    end
  end
end
