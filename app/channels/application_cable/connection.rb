module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.headers[:HTTP_AUTHORIZATION]&.split(' ')&.last
      return reject_unauthorized_connection if token.blank?

      payload = JWT.decode(
        token,
        Rails.application.credentials.devise_jwt_secret_key,
        true,
        algorithm: 'HS256'
      ).first

      user = User.find_by(id: payload['sub'])
      return reject_unauthorized_connection unless user

      user
    rescue JWT::DecodeError
      reject_unauthorized_connection
    end
  end
end 