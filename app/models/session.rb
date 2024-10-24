class Session < ApplicationRecord
  belongs_to :user
  
  validates :session_token, :expires_at, presence: true
  encrypts :session_token, deterministic: true
  encrypts :ip, deterministic: true
  
  def expire!
    self.update(expired: true)
  end
end