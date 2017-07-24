class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    user ||= User.new # guest user (not logged in)

    alias_action :exceptional_edit, :batch_edit, :batch_update, to: :update_timetable

    if user.administrator?
      can :manage, :all
    elsif user.manager?
      can [:read, :update], Location # Restricting fields that can be updated via strong params
      can :update_timetable, Timetable

      # Further restrictions to restrict manager's to only creating editors
      # will be implemented in the controller method for create/update.
      can :create, User
      can [:read, :update, :destroy], User do |u|
        u.editor? || u.role.blank?
      end
    elsif !(roles = user.permissions.editor_roles).empty?
      roles.map(&:subject_id).each do |id|
        Rails.logger.debug "subject_id = #{id}"
        can [:read, :update], Location, id: id  # Restricting fields that can be updated via strong params
        can :update_timetable, Timetable, location: { id: id }
      end
    end
  end
end
