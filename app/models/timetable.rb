class Timetable < ApplicationRecord
	belongs_to :library

	def self.batch_update_or_create(library_id, dates, open, close, closed, tbd, note)
		vals = dates.map!{|day| "('#{library_id}', '#{day}', '#{open}', '#{close}', #{closed}, #{tbd}, '#{note}', NOW(), NOW())"}.join(", ")
		sql = "INSERT INTO timetables (library_id,date,open,close,closed,tbd,note,created_at,updated_at) VALUES #{vals} ON DUPLICATE KEY UPDATE open = '#{open}', close = '#{close}', updated_at= NOW();"
		ActiveRecord::Base.connection.exec_query(sql)
	end

end



