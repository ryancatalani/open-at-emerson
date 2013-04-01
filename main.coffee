$ ->
	$.getJSON("hours.json", (json) ->

		main = $("#main")

		for type, arr of json.location_categories
			cat_div = $("<div></div>")
			cat_div.addClass("category")
			type_title = (type.split('_').map (word) -> word.charAt(0).toUpperCase() + word.slice(1)).join(' ') # Based on http://stackoverflow.com/questions/1026069/capitalize-the-first-letter-of-string-in-javascript
			$("<h3>#{type_title}</h3>").appendTo(cat_div)

			for location in arr
				loc_div = $("<div></div>")
				loc_div.addClass('location')
				status_results = isOpen(location)
				open = status_results.open
				if open
					$("<div></div>").addClass('status').text('Open').appendTo(loc_div)
				else
					$("<div></div>").addClass('status').text('Closed').appendTo(loc_div)
				$("<h4>#{location.name}</h4>").appendTo(loc_div)
				$("<div></div>").addClass('notes').html(status_results.notes).appendTo(loc_div) if status_results.notes?
				loc_div.addClass('open') if open
				loc_div.appendTo(cat_div)

			cat_div.appendTo(main)

	)

	isOpen = (location) ->

		# console.log location.name

		day = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"][ new Date().getDay() ]
		weekend = day in ["sunday", "saturday"]
		current_date = Date.now()
		current_time = new Date().toTimeString().split(' ')[0] # To go from something like "20:59:53 GMT-0400 (EDT)" to "20:59:53"
		hours = []
		sel = {}
		open = false

		another_hour_interval_today = false
		next_sel = {}
		next_open_time = ""


		ret = {}

		if location.multiple_hour_periods?
			for period, period_i in location.multiple_hour_periods
				if typeof period.period_dates[0] == "string"
					if current_date > Date.parse(period.period_dates[0]) and current_date < Date.parse(period.period_dates[1])
						sel = period
						break
				else
					for inner_period in period.period_dates
						if current_date > Date.parse(inner_period[0]) and current_date < Date.parse(inner_period[1])
							sel = period
							break
		else
			sel = location
			next_sel = location

		if sel["#{day}_hours"]?
			hours = sel["#{day}_hours"]
		else
			hours = if weekend then sel.weekend_hours else sel.weekday_hours

		if hours.length == 0
			open = false
		else if typeof hours[0] == "string"
			open = (current_time > "#{hours[0]}:00") and (current_time < "#{hours[1]}:00") # Because current_time has seconds
		else
			for inner_hours, i in hours
				if (current_time > "#{inner_hours[0]}:00") and (current_time < "#{inner_hours[1]}:00")
					open = true
					if i < hours.length - 1
						another_hour_interval_today = true
						next_open_time = hours[i+1][0]
					break

		# console.log next_open_time
		ret.open = open
		ret.notes = sel.notes if sel.notes?

		return ret