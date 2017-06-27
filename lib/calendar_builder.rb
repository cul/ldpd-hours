class CalendarBuilder < Struct.new(:view, :date, :callback)
    HEADER = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    START_DAY = :sunday

    delegate :content_tag, to: :view

    def table
      content_tag :table, class: "calendar table table-bordered table-striped", id: "selectable" do
        header + week_rows
      end
    end

    def header
      content_tag :tr do
        HEADER.map { |day| content_tag :th, day }.join.html_safe
      end
    end

    def week_rows
      weeks.map do |week|
        content_tag :tr do
          week.map { |day| day_cell(day) }.join.html_safe
        end
      end.join.html_safe
    end

    def day_cell(day)
      todays_hours = @times.select{|timetable| timetable.date == day}
      hours = todays_hours.empty? ? content_tag(:span, "TBD") : formatted_hours(todays_hours.flatten)
      note = (todays_hours.empty? || todays_hours.first.note.blank?) ? "" : content_tag(:span, todays_hours.first.note)
      content_tag :td, view.capture(day, &callback) + content_tag(:p, day, class: "hidden") + hours + note, class: day_classes(day)
    end

    def day_classes(day)
      classes = []
      classes << "today" if day == Date.today
      classes << "not-month" if day.month != date.month
      classes.empty? ? nil : classes.join(" ")
    end

    def weeks
      first = date.beginning_of_month.beginning_of_week(START_DAY)
      last = date.end_of_month.end_of_week(START_DAY)
      get_times(first,last)
      (first..last).to_a.in_groups_of(7)
    end

    private

    def get_times(first,last)
      library_id = view.assigns["library"].id
      @times = Timetable.where(library_id: library_id, date: first..last)
    end

    def formatted_hours(timetable)
      timetable = timetable.first
      if timetable.open && timetable.close
        content = "#{timetable.open.to_time.strftime('%l:%M%p')}-#{timetable.close.to_time.strftime('%l:%M%p')}".gsub(/\s+/, "")
      elsif timetable.closed
        content = "Closed"
      else
        content = "TBD"
      end
      content_tag(:span, content)
    end
end