module Api
  module V1
    class MessagesController < BaseController
      before_action :set_message, except: [:index, :create, :unread]

      def index
        messages = policy_scope(Message).includes(:sender, :recipient)
        render json: MessageSerializer.new(messages, include: [:sender, :recipient])
      end

      def show
        authorize @message
        render json: MessageSerializer.new(@message, include: [:sender, :recipient])
      end

      def create
        message = current_user.sent_messages.build(message_params)
        authorize message

        if message.save
          render json: MessageSerializer.new(message), status: :created
        else
          render_error(message.errors.full_messages)
        end
      end

      def update
        authorize @message

        if @message.update(message_params)
          render json: MessageSerializer.new(@message)
        else
          render_error(@message.errors.full_messages)
        end
      end

      def destroy
        authorize @message
        @message.destroy
        render_success
      end

      def revoke
        authorize @message
        
        if @message.revoke!
          render_success(message: 'Message revoked successfully')
        else
          render_error('Failed to revoke message')
        end
      end

      def mark_as_read
        authorize @message
        
        if @message.mark_as_read!
          render_success(message: 'Message marked as read')
        else
          render_error('Failed to mark message as read')
        end
      end

      def unread
        messages = policy_scope(Message).unread.includes(:sender, :recipient)
        render json: MessageSerializer.new(messages, include: [:sender, :recipient])
      end

      private

      def set_message
        @message = Message.find(params[:id])
      end

      def message_params
        params.require(:message).permit(
          :recipient_id,
          :content,
          :content_type,
          :expires_at,
          metadata: {}
        )
      end
    end
  end
end 