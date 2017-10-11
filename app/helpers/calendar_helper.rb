module CalendarHelper
  def calendar_builder(date = Date.current, &block)
    CalendarBuilder.new(self, date, block).table
  end

  def until_or_closed(location, open)
    @closings ||= begin
      closings = {}
      open.each do |timetable|
        message = timetable.all_day? ? "OPEN" : "Until #{timetable.close_time.strftime("%l:%M %P")}"
        closings[timetable.location_id] = message
      end
      closings
    end
    @closings.fetch(location.id, "CLOSED")
  end
end
