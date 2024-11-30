Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = ['ActionController::API', 'ActionController::Base']
  
  config.lograge.custom_options = lambda do |event|
    {
      time: Time.current.iso8601,
      user_id: event.payload[:user_id],
      params: event.payload[:params].except(
        'controller',
        'action',
        'format',
        'password',
        'password_confirmation'
      ),
      remote_ip: event.payload[:remote_ip],
      request_id: event.payload[:request_id],
      exception: event.payload[:exception]&.first,
      exception_message: event.payload[:exception]&.last
    }
  end

  config.lograge.custom_payload do |controller|
    {
      user_id: controller.current_user&.id,
      remote_ip: controller.request.remote_ip,
      request_id: controller.request.request_id
    }
  end

  config.lograge.formatter = Lograge::Formatters::Json.new
end 