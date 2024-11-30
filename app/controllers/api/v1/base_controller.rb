module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization
      
      before_action :authenticate_user!
      
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from Pundit::NotAuthorizedError, with: :forbidden
      rescue_from ActionController::ParameterMissing, with: :bad_request
      
      private
      
      def not_found
        render json: { error: 'Resource not found' }, status: :not_found
      end
      
      def forbidden
        render json: { error: 'Access denied' }, status: :forbidden
      end
      
      def bad_request
        render json: { error: 'Bad request' }, status: :bad_request
      end
      
      def render_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end
      
      def render_success(data = nil, status = :ok)
        if data
          render json: data, status: status
        else
          head status
        end
      end
    end
  end
end 