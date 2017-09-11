class Timetable < ApplicationRecord
  belongs_to :location

  def open_time
    generate_time(open)
  end

  def close_time
    generate_time(close)
  end

  def generate_time(open_or_close)
    return nil if date.blank? || open_or_close.blank?
    open_or_close.in_time_zone
  end

  def open_at?(time)
    result = (open_time < time.in_time_zone) && (close_time > time.in_time_zone)
    if result && location.primary_location
      return result && location.primary_location.open_at?(time)
    end
    result
  end

  def self.batch_update_or_create(timetable_params, open, close)
    params, values = [],[]
    (timetable_params["dates"].count).times{ params.push("(?,?,?,?,?,?,?,?,?)")}
    overnight = open && open > close
    timetable_params["tbd"] = "0" if timetable_params["tbd"].blank?
    timetable_params["closed"] = "0" if timetable_params["closed"].blank?
    timetable_params["dates"].each do |day|
      time = day.to_time.in_time_zone
      if open
        if overnight
          open_time = Time.zone.parse(open, time)
          close_time = Time.zone.parse(close, time.change(day: 1))
        else
          open_time = Time.zone.parse(open, time)
          close_time = Time.zone.parse(close, time)
        end
      else
        open_time = nil
        close_time = nil
      end
      values.push(timetable_params['location_id'], day, open_time, close_time, timetable_params['closed'], timetable_params['tbd'], timetable_params['note'], Time.current, Time.current)
    end

    bulk_insert_users_sql_arr = ["REPLACE INTO timetables (location_id,date,open,close,closed,tbd,note,created_at,updated_at) VALUES #{params.join(", ")}"] + values
    sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_insert_users_sql_arr)
    ActiveRecord::Base.connection.exec_update(sql)
  end

  def display_str
    if self.open && self.close
      "#{open_time.strftime('%l:%M%p')}-#{close_time.strftime('%l:%M%p')}".gsub(/\s+/, "")
    elsif self.closed
      "Closed"
    else
      "TBD"
    end
  end
end
