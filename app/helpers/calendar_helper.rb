module CalendarHelper
  def calendar_builder(date = Date.today, &block)
    CalendarBuilder.new(self, date, block).table
  end
end
