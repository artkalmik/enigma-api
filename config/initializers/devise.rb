Devise.setup do |config|
  config.mailer_sender = 'noreply@enigma-messenger.com'

  # JWT конфигурация
  config.jwt do |jwt|
    jwt.secret = ENV.fetch('DEVISE_JWT_SECRET_KEY') { Rails.application.credentials.devise_jwt_secret_key }
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/auth/sign_in$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/auth/sign_out$}]
    ]
    jwt.expiration_time = 24.hours.to_i
  end

  # Конфигурация для API
  config.navigational_formats = []
  config.skip_session_storage = [:http_auth]
  
  # Безопасность
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :both
  config.maximum_attempts = 5
  config.unlock_in = 1.hour

  # Двухфакторная аутентификация
  config.max_login_attempts = 3
  config.allowed_otp_drift_seconds = 30
end 