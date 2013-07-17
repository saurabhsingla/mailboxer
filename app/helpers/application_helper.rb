module ApplicationHelper
	# def unreadinboxnumber
	# 	@inbox = current_user.mailbox.inbox
	# 	@countInboxConvUnread = 0
	# 	@inbox.each do |inbox|
	# 		inbox.receipts.each do |receipt|
	# 			if !receipt.is_read? && receipt.receiver_id == current_user.id
	# 				@countInboxConvUnread = @countInboxConvUnread + 1
	# 				break
	# 			end
	# 		end			
	# 	end
	# 	return @countInboxConvUnread
	# end

	# def unreadsentnumber
	# 	@sentbox = current_user.mailbox.sentbox
	# 	@countSentboxConvUnread = 0
	# 	@sentbox.each do |sentbox|
	# 		sentbox.receipts.each do |receipt|
	# 			if !receipt.is_read? && receipt.receiver_id == current_user.id
	# 				@countSentboxConvUnread = @countSentboxConvUnread + 1
	# 				break
	# 			end
	# 		end			
	# 	end
	# 	return @countSentboxConvUnread
	# end
	
	# def unreadtrashnumber

	# 	@trash = current_user.mailbox.trash
	# 	@countTrashConvUnread = 0
	# 	@trash.each do |trash|
	# 		trash.receipts.each do |receipt|
	# 			if !receipt.is_read? && receipt.receiver_id == current_user.id
	# 				@countTrashConvUnread = @countTrashConvUnread + 1
	# 				break
	# 			end
	# 		end			
	# 	end
	# 	return @countTrashConvUnread
	# end
end
