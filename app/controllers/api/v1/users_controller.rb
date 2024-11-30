module Api
  module V1
    class UsersController < BaseController
      def index
        users = policy_scope(User)
          .where.not(id: current_user.id)
          .order(:username)
        
        render json: UserSerializer.new(users)
      end

      def show
        user = User.find(params[:id])
        authorize user
        render json: UserSerializer.new(user)
      end

      def search
        query = params[:q].to_s.strip
        return render json: [] if query.blank?

        users = policy_scope(User)
          .where.not(id: current_user.id)
          .where('username ILIKE :q OR email ILIKE :q', q: "%#{query}%")
          .limit(10)
        
        render json: UserSerializer.new(users)
      end
    end
  end
end 