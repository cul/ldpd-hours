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
    Time.local(date.year, date.month, date.day, *open_or_close.split(':'))
  end

  def open_at?(time)
    (open_time < time) && (close_time > time)
  end

  def self.batch_update_or_create(timetable_params, open, close)
    params, values = [],[]
    (timetable_params["dates"].count).times{ params.push("(?,?,?,?,?,?,?,?,?)")}
    timetable_params["dates"].each{|day| values.push(timetable_params['location_id'], day, open, close, timetable_params['closed'], timetable_params['tbd'], timetable_params['note'], Time.now, Time.now)}
    values.push(open,close,timetable_params['closed'],timetable_params['tbd'], timetable_params['note'])
    bulk_insert_users_sql_arr = ["INSERT INTO timetables (location_id,date,open,close,closed,tbd,note,created_at,updated_at) VALUES #{params.join(", ")} ON DUPLICATE KEY UPDATE open = ?, close = ?, closed = ?, tbd = ?, note = ?, updated_at= NOW()"] + values
    sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_insert_users_sql_arr)
    ActiveRecord::Base.connection.exec_query(sql)
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
