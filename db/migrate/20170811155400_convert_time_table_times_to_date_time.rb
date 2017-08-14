class ConvertTimeTableTimesToDateTime < ActiveRecord::Migration[5.1]
  def up
    # change all the string values HH:MM to be an appropriate
    # timestamp for the day and tz
    Timetable.all.each do |timetable|
      open_time = nil
      if timetable.open
        open_time = Time.parse(timetable.open, timetable.date.to_time)
        timetable.open = open_time.to_datetime.to_s
      end
      if timetable.close
        close_time = Time.parse(timetable.close, timetable.date.to_time)
        if open_time && close_time < open_time
          close_time = close_time + 1.day
        end
        timetable.close = close_time.to_datetime.to_s
      end
      timetable.save
    end
    # change the column type
    change_column :timetables, :open, :datetime
    change_column :timetables, :close, :datetime
  end

  def down
    # revert the column type
    change_column :timetables, :open, :string
    change_column :timetables, :close, :string
    # convert the string representation to be only HH:MM
    Timetable.all.each do |timetable|
      if timetable.open
        open_time = Time.parse(timetable.open)
        timetable.open = open_time.strftime("%H:%M") 
      end 
      if timetable.close
        close_time = Time.parse(timetable.open)
        timetable.open = close_time.strftime("%H:%M") 
      end
      timetable.save
    end
  end
end
