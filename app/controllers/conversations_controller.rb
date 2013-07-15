class ConversationsController < ApplicationController
	before_filter :authenticate_user!
	helper_method :mailbox, :conversation
	include ConversationsHelper
	require 'will_paginate/array'

	# This method is for creation of a new conversation
	def create
		
		@rec_emails = conversation_params(:recipients).split(',')
		@rec = User.where(email: @rec_emails).all
		conversation = current_user.send_message(@rec, 
			*conversation_params(:body, :subject)).conversation

		redirect_to conversation
	end

	def displayinbox
		# debugger
		# if(params[:box] == nil)
			@search = params[:search]
			@convs = current_user.mailbox.inbox
			@countInboxConvUnread = 0
			@convFinal = []
			@convs.each do |inbox|
				# debugger
				inbox.receipts.each do |receipt|
					if !receipt.is_read? && receipt.receiver_id == current_user.id
						@countInboxConvUnread = @countInboxConvUnread + 1
						break
					end
				end
				if @search == nil 
					@convFinal = @convs
				elsif inbox.subject.include? @search
					@convFinal.push(inbox)
				end		
			end	
			@convFinal = @convFinal.paginate(:page => params[:page], :per_page => 10)
			
	end

	def show_trashed
		@conv = Conversation.find(params[:id])
		@receipts = @conv.receipts.all(:order => 'updated_at DESC')
		unless @conv.is_participant?(current_user)
        	flash[:alert] = "You do not have permission to view that conversation."
        	return redirect_to root_path
      	end
		# make is_read true when the current user has opened the conversation
		@conv.receipts.each do |receipt|
			
			if receipt.receiver_id == current_user.id				
				receipt.is_read = true
				receipt.save				
			end
		end
		
		@notif = Notification.where(:conversation_id => params[:id])
	end

	def displaysentbox
		@search = params[:search]
		@convs = current_user.mailbox.sentbox
		@countSentboxConvUnread = 0
		@convFinal = []
		@convs.each do |sentbox|
			sentbox.receipts.each do |receipt|
				if !receipt.is_read? && receipt.receiver_id == current_user.id
					@countSentboxConvUnread = @countSentboxConvUnread + 1
					break
				end
			end		
			if @search == nil 
					@convFinal = @convs
				elsif sentbox.subject.include? @search
					@convFinal.push(sentbox)				
			end	
		end
		@convFinal = @convFinal.paginate(:page => params[:page], :per_page => 10)
	end

	def displaytrash
		@search = params[:search]
		@convstemp = current_user.mailbox.conversations(:order => 'lasttrashed_at DESC')
		@convs = []
		@convFinal = []
		@convstemp.each do |conv|
			if conv.is_trashed?(current_user)
				@convs.push(conv)
			end
		end
		# @convs = @convs.paginate(:page => params[:page], :per_page => 10)
		@countTrashConvUnread = 0
		if !@convs.empty?
			@convs.each do |trash|
				trash.receipts.each do |receipt|
					if !receipt.is_read? && receipt.receiver_id == current_user.id
						@countTrashConvUnread = @countTrashConvUnread + 1
						break
					end
				end
				if @search == nil 
					@convFinal = @convs
				elsif trash.subject.include? @search
					@convFinal.push(trash)				
				end	
			end
		end
		@convFinal = @convFinal.paginate(:page => params[:page], :per_page => 10)
	end

	# to show a particular conversation details
	def show
		@conv = Conversation.find(params[:id])
		unless @conv.is_participant?(current_user)
        	flash[:alert] = "You do not have permission to view that conversation."
        	return redirect_to root_path
      	end
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
		if message_params(:subject).empty?
			current_user.reply_to_conversation(conversation, 
			*message_params(:body, ""), should_untrash=false)
		else
			current_user.reply_to_conversation(conversation, 
			*message_params(:body, :subject), should_untrash=false)
		end
    	redirect_to conversation

	end

	def replysingleuser

		recifreply = Receipt.find(params[:notif_id])
		currconversation = recifreply.notification.conversation
		# in case To: field has been specified
		if !params[:recipients].empty?
			@rec_emails = params[:recipients].split(',')
			@rec = User.where(email: @rec_emails).all
			if params[:subject].empty?
				debugger
				current_user.reply(currconversation,@rec,params[:body] )
			else
				current_user.reply(currconversation,@rec,params[:body],
					params[:subject] )
			end
		else			
			if params[:subject].empty?
				current_user.reply_to_sender(recifreply,params[:body])
			else
				current_user.reply_to_sender(recifreply,params[:body],
					params[:subject])
			end
		end
		redirect_to conversation
	end

	# this is linked with the index page. It shows all the conversations linked with the current user
	def index	
		
	end

	# to trash individual receipt
	def trashnotif
		receiptToBeDeleted = Receipt.find(params[:id])
		
		receiptToBeDeleted.move_to_trash
		dateTime = Time.new
		receiptToBeDeleted.updated_at = dateTime.to_time
		receiptToBeDeleted.save

		conversation = Conversation.find(receiptToBeDeleted.notification.conversation.id)
		conversation.lasttrashed_at = dateTime.to_time
		conversation.save
		
		redirect_to conversation
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
