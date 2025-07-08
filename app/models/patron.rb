class Patron < ApplicationRecord
  has_many :print_jobs, dependent: :destroy

  before_create :generate_access_token

  # Returns true if the token was sent within the last 7 days
  def token_valid?
    token_sent_at.present? && token_sent_at >= 7.days.ago
  end

  # Clear out old token so it can’t be reused
  def expire_token!
    update!(access_token: nil, token_sent_at: nil)
  end

  private

  def generate_access_token
    self.access_token = SecureRandom.urlsafe_base64(24)
    self.token_sent_at = Time.current
  end
end
