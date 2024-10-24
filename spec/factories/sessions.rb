FactoryBot.define do
  factory :session do
    association :user
    session_token { SecureRandom.hex(25) }
    data { nil }
    expires_at { 3.days.from_now }
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
    expired { false }
    logout_at { nil }
    created_at { Time.now }
    updated_at { Time.now }
  end
end