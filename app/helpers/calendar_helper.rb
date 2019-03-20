module CalendarHelper
  def calendar_builder(date = Date.current, &block)
    CalendarBuilder.new(self, date, block).table
  end

  def until_or_closed(location, open)
    @closings ||= begin
      closings = {}
      open.each do |timetable|
        message = timetable.all_day? ? "OPEN" : "#{timetable.open_time.strftime("%l:%M %P")} - #{timetable.close_time.strftime("%l:%M %P")}"
        closings[timetable.location_id] = message
      end
      closings
    end
    @closings.fetch(location.id, "CLOSED")
  end

  def page_title(location = nil)
    return "Library Hours and Locations Open Now" unless location
    if location.name =~ /\shours$/i
      return location.name
    else
      return "#{location.name} Hours"
    end
  end
end
