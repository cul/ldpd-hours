module CalendarHelper
  def calendar_builder(date = Date.current, &block)
    CalendarBuilder.new(self, date, block).table
  end
end
