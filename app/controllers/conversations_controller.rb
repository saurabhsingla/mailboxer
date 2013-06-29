class ConversationsController < ApplicationController
	before_filter :authenticate_user!
	helper_method :mailbox, :conversation

	def create
		# debugger
		@rec_emails = conversation_params(:recipients)
		# debugger
		@rec = User.where(email: @rec_emails).all
		# debugger

		conversation = current_user.send_message(@rec, 
			*conversation_params(:body, :subject)).conversation

		redirect_to conversation

	end

	def show
		@conv = Conversation.find(params[:id])
		@notif = Notification.where(:conversation_id => params[:id])
		# @sender = User.find(@notif.sender_id)

		# @receipts = @conv.receipts.all
		# # where(:notification.sender_id => current_user.id)
		# # @sender = User.find(@conv.sender_id)
		# @receipts.each do |rec|
		# @receiver = User.find(rec.receiver_id)	
		# @sender = User.find(rec.notification.sender_id)
		# # @recBody = rec.body
		# # 		@recSubject = rec.subject
		# end

		# @notif = Notification.where(conversation_id: @conv.id)

		# @notifications = @conv.receipts.notifications

		# @receiver = User.find(@conv.receipts.all)
		# debugger
	end

	def reply
		current_user.reply_to_conversation(conversation, *message_params(:body, :subject))
    	redirect_to conversation

	end
	def index	
		@conversations = current_user.mailbox.conversations

		@inbox = current_user.mailbox.inbox
		@sentbox = current_user.mailbox.sentbox
		@trash = current_user.mailbox.trash
	end

	def trash
		# debugger
    conversation.move_to_trash(current_user)
    redirect_to :conversations
  	end

  	def untrash
  		conversation.untrash(current_user)
  		redirect_to :conversations
  	end

	def conversation
		# debugger
   	 	@conversation ||= mailbox.conversations.find(params[:id])
  	end

	def mailbox
		@mailbox ||= current_user.mailbox
	end
	def conversation_params(*keys)
    	fetch_params(:conversation, *keys)
  	end

  	def message_params(*keys)
    	fetch_params(:message, *keys)
  	end

  def fetch_params(key, *subkeys)
    params[key].instance_eval do
      case subkeys.size
      when 0 then self
      when 1 then self[subkeys.first]
      else subkeys.map{|k| self[k] }
      end
    end
  end
end
