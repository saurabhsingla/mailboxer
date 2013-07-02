class ConversationsController < ApplicationController
	before_filter :authenticate_user!
	helper_method :mailbox, :conversation

	# This method is for creation of a new conversation
	def create
		
		@rec_emails = conversation_params(:recipients).split(',')
		@rec = User.where(email: @rec_emails).all
		conversation = current_user.send_message(@rec, 
			*conversation_params(:body, :subject)).conversation

		redirect_to conversation
	end

	# to show a particular conversation details
	def show
		
		@conv = Conversation.find(params[:id])
		@notif = Notification.where(:conversation_id => params[:id])
	end

	# to reply on a conversation
	def reply
		current_user.reply_to_conversation(conversation, *message_params(:body, ""))
    	redirect_to conversation

	end

	# this is linked with the index page. It shows all the conversations linked with the current user
	def index	
		@conversations = current_user.mailbox.conversations

		@inbox = current_user.mailbox.inbox
		@sentbox = current_user.mailbox.sentbox
		@trash = current_user.mailbox.trash
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
