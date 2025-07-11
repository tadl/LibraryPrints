# app/models/staff_user.rb
class StaffUser < ApplicationRecord
  # Required fields
  validates :uid,   presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Build or update a user from OmniAuth data
  def self.from_omniauth(auth)
    user = find_or_initialize_by(uid: auth.uid)
    user.email      = auth.info.email
    user.name       = auth.info.name
    user.avatar_url = auth.info.image
    user.save! if user.changed?
    user
  end

  def admin?
    self.admin
  end
end
