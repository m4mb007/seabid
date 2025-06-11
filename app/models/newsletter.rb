class Newsletter < ApplicationRecord
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  
  before_create :set_default_subscription_status
  
  private
  
  def set_default_subscription_status
    self.subscribed = true if subscribed.nil?
  end
end
