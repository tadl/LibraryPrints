class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.is_a?(StaffUser)
    can :manage, :all
  end
end
