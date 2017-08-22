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
      content_tag :thead do
        content_tag :tr do
          HEADER.map { |day| content_tag :th, day}.join.html_safe
        end
      end
    end

    def week_rows
      timetable = get_timetable(weeks.first.first, weeks.last.last)
      weeks.map do |week|
        content_tag :tr do
          week.map do |day|
            day_cell(day, timetable.find { |t| t.date == day })
          end.join.html_safe
        end
      end.join.html_safe
    end

    def day_cell(day, timetable = nil)
      if timetable.nil?
        hours, note = 'TBD', ''
      else
        hours = timetable.display_str
        note = content_tag(:div, timetable.note, class: "day-note") unless timetable.note.blank?
      end

      content_tag :td, class: day_classes(day) do
        dayoftheweek = HEADER[day.wday]
        view.capture(day, &callback) + content_tag(:div, day.mday, class: "day-date", :"data-dayoftheweek" =>  dayoftheweek) +
          content_tag(:div, day, class: "fulldate hidden") + content_tag(:div, hours, class: "day-hours") + note
      end
    end

    def day_classes(day)
      classes = []
      classes << "today" if day == Date.current
      classes << "not-month" if day.month != date.month
      classes.empty? ? nil : classes.join(" ")
    end

    def weeks
      first = date.beginning_of_month.beginning_of_week(START_DAY)
      last = date.end_of_month.end_of_week(START_DAY)
      (first..last).to_a.in_groups_of(7)
    end

    private

    def get_timetable(first,last)
      location_id = view.assigns["location"].id
      Timetable.where(location_id: location_id, date: first..last)
    end
end
