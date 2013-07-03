class ConversationsController < ApplicationController
	before_filter :authenticate_user!
	helper_method :mailbox, :conversation
	include ConversationsHelper

	# This method is for creation of a new conversation
	def create
		
		@rec_emails = conversation_params(:recipients).split(',')
		@rec = User.where(email: @rec_emails).all
		conversation = current_user.send_message(@rec, 
			*conversation_params(:body, :subject)).conversation

		redirect_to conversation
	end

	def displayinbox

		@convs = current_user.mailbox.inbox
		@countInboxConvUnread = 0
		@convs.each do |inbox|
			inbox.receipts.each do |receipt|
				if !receipt.is_read? && receipt.receiver_id == current_user.id
					@countInboxConvUnread = @countInboxConvUnread + 1
					break
				end
			end			
		end
		# debugger
	end

	def displaysentbox
		@convs = current_user.mailbox.sentbox
		@countSentboxConvUnread = 0
		@convs.each do |sentbox|
			sentbox.receipts.each do |receipt|
				if !receipt.is_read? && receipt.receiver_id == current_user.id
					@countSentboxConvUnread = @countSentboxConvUnread + 1
					break
				end
			end			
		end
	end

	def displaytrash
		@convs = current_user.mailbox.trash
		@countTrashConvUnread = 0
		@convs.each do |trash|
			trash.receipts.each do |receipt|
				if !receipt.is_read? && receipt.receiver_id == current_user.id
					@countTrashConvUnread = @countTrashConvUnread + 1
					break
				end
			end			
		end
	end

	# to show a particular conversation details
	def show
		@conv = Conversation.find(params[:id])

		# make is_read true when the current user has opened the conversation
		@conv.receipts.each do |receipt|
			
			if receipt.receiver_id == current_user.id
				
				receipt.is_read = true
				receipt.save
				
			end
		end
		
		@notif = Notification.where(:conversation_id => params[:id])
	end


	# to reply on a conversation
	def reply
		current_user.reply_to_conversation(conversation, *message_params(:body, ""))
    	redirect_to conversation

	end

	# this is linked with the index page. It shows all the conversations linked with the current user
	def index	
		@inbox = current_user.mailbox.inbox
		@countInboxConvUnread = 0
		@inbox.each do |inbox|
			inbox.receipts.each do |receipt|
				if !receipt.is_read? && receipt.receiver_id == current_user.id
					@countInboxConvUnread = @countInboxConvUnread + 1
					break
				end
			end			
		end
		
		@sentbox = current_user.mailbox.sentbox
		@countSentboxConvUnread = 0
		@sentbox.each do |sentbox|
			sentbox.receipts.each do |receipt|
				if !receipt.is_read? && receipt.receiver_id == current_user.id
					@countSentboxConvUnread = @countSentboxConvUnread + 1
					break
				end
			end			
		end

		@trash = current_user.mailbox.trash
		@countTrashConvUnread = 0
		@trash.each do |trash|
			trash.receipts.each do |receipt|
				if !receipt.is_read? && receipt.receiver_id == current_user.id
					@countTrashConvUnread = @countTrashConvUnread + 1
					break
				end
			end			
		end
	end

	# to trash a particular conversation
	def trash

	    conversation.move_to_trash(current_user)
	    # Completely delete the conversation if all the participants of the conversation have
	    # trashed the conversation.
	    if_trashed = false
	    conversation.participants.each do |participient|
	    	if_trashed = conversation.is_completely_trashed?(participient)
	    	
	    	if !if_trashed
	    		break
	    	end
	    end
	    
	    if if_trashed
	    	conversation.messages.destroy_all
	    end
    	redirect_to :conversations
  	end

  	# to untrash a trashed conversation
  	def untrash
  		conversation.untrash(current_user)
  		redirect_to :conversations
  	end

  	# to permanently delete a conversation. Currently not in use.
  	def permanentdel
  		conversation.delete(current_user)
  		redirect_to :conversations
  	end

  	# to append a conversation based on the id
	def conversation
		
   	 	@conversation ||= mailbox.conversations.find(params[:id])
  	end

  	# fetched the current user mailbox. Provided by the gem
	def mailbox
		@mailbox ||= current_user.mailbox
	end

	# breaks the parameters and passes on to fetch_params function to fetch 
	# a result based on the parameters passed.
	def conversation_params(*keys)
    	fetch_params(:conversation, *keys)
  	end

  	# breaks the parameters and passes on to fetch_params function to fetch 
	# a result based on the parameters passed.
  	def message_params(*keys)
    	fetch_params(:message, *keys)
  	end

  	# fetches a result based on the parameters passed. 
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
