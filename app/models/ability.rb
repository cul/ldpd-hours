class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :index, :show, to: :read
    alias_action :batch_edit, :exceptional_edit, to: :bulk_edit
    # Define abilities for the passed in user here.
    user ||= User.new # guest user (not logged in)

    if user.administrator?
      can :manage, :all
    elsif user.manager?
      can [:read, :edit, :update], Location # Restricting fields that can be updated via strong params
      can :manage, Timetable

      # Further restrictions to restrict manager's to only creating editors
      # will be implemented in the controller method for create/update.
      can :create, User
      can [:read, :update, :destroy, :edit], User do |u|
        u.editor? || u.role.blank?
      end
    else
      user.permissions.editor_roles.map(&:subject_id).each do |id|
        Rails.logger.debug "subject_id = #{id}"
        can [:read, :edit, :update], Location, id: id
        can [:new, :read, :edit, :bulk_edit], Timetable, location_id: id
        can [:create, :update, :destroy, :batch_update], Timetable, location_id: id
      end
    end
  end
end
