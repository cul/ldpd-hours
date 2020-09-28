class Timetable < ApplicationRecord
  belongs_to :location

  scope :date_range, lambda {|start_date, end_date| where("date >= ? AND date <= ?", start_date, end_date)}

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
    overnight = open && open >= close
    timetable_params["tbd"] = "0" if timetable_params["tbd"].blank?
    timetable_params["closed"] = "0" if timetable_params["closed"].blank?
    timetable_params["dates"].each do |day|
      time = day.to_time.in_time_zone
      if open
        if overnight
          open_time = Time.zone.parse(open, time)
          close_time = Time.zone.parse(close, time).next_day
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

    if timetable_params['location_code'] == 'all'
      Location.all.each do |each_location|
        0.step(by: 9, to: (timetable_params["dates"].count * 9) - 1) { |lidx| values[lidx] = each_location.id }
        bulk_insert_users_sql_arr = ["REPLACE INTO timetables (location_id,date,open,close,closed,tbd,note,created_at,updated_at) VALUES #{params.join(", ")}"] + values
        sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_insert_users_sql_arr)
        ActiveRecord::Base.connection.exec_update(sql)
      end
    else
      bulk_insert_users_sql_arr = ["REPLACE INTO timetables (location_id,date,open,close,closed,tbd,note,created_at,updated_at) VALUES #{params.join(", ")}"] + values
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_insert_users_sql_arr)
      ActiveRecord::Base.connection.exec_update(sql)
    end
  end

  def all_day?
    if self.open and self.close
      return self.close - self.open == 1.day
    end
    false
  end

  def display_str
    if all_day?
      "Open 24 hours on #{open_time.strftime('%m/%d/%Y')}"
    elsif self.open && self.close
      "#{open_time.strftime('%l:%M%p')}-#{close_time.strftime('%l:%M%p')}".gsub(/\s+/, "")
    elsif self.closed
      "Closed"
    else
      "TBD"
    end
  end

  # This method will generate a hash with instance attributes formatted
  # as specfied in the API specs. The returned hash will be turned into JSON by
  # the calling code and inserted into the body of the API response.
  # Any formatting changes to the API response (pertinent to the Timetable info)
  # should be implemented in this method.
  def day_info_hash
    if closed
      formatted_date = "Closed"
    elsif tbd
      formatted_date = "TBD"
    else
      formatted_date = "#{open.strftime('%I:%M%p')}-#{close.strftime('%I:%M%p')}"
    end
    open_time_val = open.nil? ? nil : open.strftime('%H:%M')
    close_time_val = close.nil? ? nil : close.strftime('%H:%M')
    {
      date: date.strftime("%F"),
      open_time: open_time_val,
      close_time: close_time_val,
      closed: closed,
      tbd: tbd,
      note: note.nil? ? "" : note,
      short_note: location.short_note.nil? ? "" : location.short_note,
      short_note_url: location.short_note_url.nil? ? "" : location.short_note_url,
      formatted_date: formatted_date,
    }
  end

  # Default hash to be used for a date that does not have
  # an associated instance Timetable.
  # The returned hash will be turned into JSON by the calling code.
  def self.default_day_info_hash date
    {
      date: date.strftime("%F"),
      open_time: nil,
      close_time: nil,
      closed: false,
      tbd: true,
      note: "",
      short_note: "",
      short_note_url: "",
      formatted_date: "TBD"
    }
  end

  # This method will return a hash with pertinent attributes formatted as specified
  # in the API specs for a call to open_now. The returned hash will be turned
  # into JSON by the calling code and inserted into the body of the API response
  def open_now_hash
    # should never be nil, but gonna keep the sanity check
    open_time_val = open.nil? ? nil : open.strftime('%H:%M')
    close_time_val = close.nil? ? nil : close.strftime('%H:%M')
    {
      open_time: open_time_val,
      close_time: close_time_val,
      formatted_date: "Until #{close.strftime('%I:%M%p')}"
    }
  end
end
