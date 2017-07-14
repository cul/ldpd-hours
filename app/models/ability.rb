class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    user ||= User.new # guest user (not logged in)

    alias_action :exceptional_edit, :batch_edit, :batch_update, to: :update_timetable

    if user.administrator?
      can :manage, :all
    elsif user.manager?
      can :update, Location
      can :update_timetable, Timetable
    elsif !(roles = user.permissions.editor_roles).empty?
      roles.map(&:subject_id).each do |id|
        can :update, Location, id: id
        can :update_timetable, Timetable, location_id: id
      end
    end
  end
end
