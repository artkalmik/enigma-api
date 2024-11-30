Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.1
  config.send_default_pii = false
  
  config.before_send = lambda do |event, hint|
    # Не отправляем ошибки в development
    return nil if Rails.env.development?
    
    # Фильтруем чувствительные данные
    if event.extra&.dig(:params)
      event.extra[:params] = event.extra[:params].except(
        'password',
        'password_confirmation',
        'current_password',
        'private_key',
        'secret'
      )
    end
    
    event
  end
end 