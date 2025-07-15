class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.is_a?(StaffUser)

    # always allow staff to enter RailsAdmin
    can :access, :rails_admin
    can :read,   :dashboard

    if user.admin?
      can :manage, :all
    else
      # Jobs: view & update only
      alias_action :index, :show, :edit, :update, to: :read
      can   :read,   Job
      can   :update, Job
      can   :conversation, Job

      # allow exports if you need:
      # can :export, Job

      # Lookup tables: only read
      can :read, [
        Status,
        Category,
        Printer,
        PrintType,
        FilamentColor,
        PickupLocation,
        Patron
      ]

      # Disallow destructive on jobs
      cannot :destroy, Job

      # Disallow Patron edit
      cannot :edit, Patron

      # And block everything else completely
      cannot :manage, [
        Message,
        Conversation,
        StaffUser
      ]
    end
  end
end
