module ConversationsHelper
	public
	def createDate(date)

		month = 'Jan'
		case date.month
		when 1
			month = 'Jan'
		when 2
			month = 'Feb' 
		when 3
			month = 'Mar'
		when 4
			month = 'Apr'
		when 5
			month = 'May'
		when 6
			month = 'Jun'
		when 7
			month = 'Jul'
		when 8
			month = 'Aug'
		when 9
			month = 'Sep'
		when 10
			month = 'Oct'
		when 11
			month = 'Nov'
		when 12
			month = 'Dec'
		end

		date = date.day.to_s + " " + month + " " + date.year.to_s
		return date
	end
	def createDateTime(date)

		month = 'Jan'
		case date.month
		when 1
			month = 'Jan'
		when 2
			month = 'Feb' 
		when 3
			month = 'Mar'
		when 4
			month = 'Apr'
		when 5
			month = 'May'
		when 6
			month = 'Jun'
		when 7
			month = 'Jul'
		when 8
			month = 'Aug'
		when 9
			month = 'Sep'
		when 10
			month = 'Oct'
		when 11
			month = 'Nov'
		when 12
			month = 'Dec'
		end

		date = date.day.to_s + " " + month + " " + date.year.to_s + 
		"  " + date.hour.to_s + ":" + date.min.to_s + ":" + date.sec.to_s

		return date
	end
end
