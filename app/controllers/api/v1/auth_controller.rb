module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:register, :login, :verify_two_factor]
      
      def register
        user = User.new(user_params)
        
        if user.save
          render json: {
            message: 'Registration successful',
            user: UserSerializer.new(user).serializable_hash
          }, status: :created
        else
          render_error(user.errors.full_messages)
        end
      end

      def login
        user = User.find_by(email: params[:email])
        
        if user&.valid_password?(params[:password])
          if user.two_factor_enabled?
            user.generate_two_factor_code!
            render json: { 
              message: 'Please enter 2FA code',
              requires_2fa: true,
              temp_token: user.temp_authentication_token 
            }
          else
            sign_in(user)
            render json: {
              message: 'Login successful',
              token: current_token,
              user: UserSerializer.new(user).serializable_hash
            }
          end
        else
          render_error('Invalid email or password', :unauthorized)
        end
      end

      def verify_two_factor
        user = User.find_by_temp_authentication_token(params[:temp_token])
        
        if user&.verify_two_factor(params[:code])
          sign_in(user)
          render json: {
            message: 'Login successful',
            token: current_token,
            user: UserSerializer.new(user).serializable_hash
          }
        else
          render_error('Invalid 2FA code', :unauthorized)
        end
      end

      def logout
        current_user.update(temp_authentication_token: nil)
        sign_out current_user
        render_success(message: 'Logged out successfully')
      end

      private

      def user_params
        params.require(:user).permit(
          :email,
          :password,
          :password_confirmation,
          :username
        )
      end

      def current_token
        request.env['warden-jwt_auth.token']
      end
    end
  end
end 