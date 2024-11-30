module Api
  module V1
    class ProfilesController < BaseController
      def show
        render json: UserSerializer.new(current_user)
      end

      def update
        if current_user.update(profile_params)
          render json: UserSerializer.new(current_user)
        else
          render_error(current_user.errors.full_messages)
        end
      end

      def enable_two_factor
        if current_user.enable_two_factor!
          render json: {
            message: '2FA enabled successfully',
            secret: current_user.two_factor_secret,
            qr_code: current_user.two_factor_qr_code
          }
        else
          render_error('Failed to enable 2FA')
        end
      end

      def disable_two_factor
        if current_user.verify_two_factor(params[:code])
          current_user.disable_two_factor!
          render_success(message: '2FA disabled successfully')
        else
          render_error('Invalid 2FA code')
        end
      end

      def verify_two_factor
        if current_user.verify_two_factor(params[:code])
          render_success(message: '2FA verification successful')
        else
          render_error('Invalid 2FA code')
        end
      end

      private

      def profile_params
        params.require(:user).permit(
          :username,
          :email,
          :password,
          :password_confirmation,
          settings: {}
        )
      end
    end
  end
end 