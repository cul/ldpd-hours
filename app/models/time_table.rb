class TimeTable < ApplicationRecord
	def self.batch_update_or_create(code, dates, open, close)
		vals = dates.map!{|day| "('#{code}', '#{day}', '#{open}', '#{close}', NOW(), NOW())"}.join(", ")
		sql = "INSERT INTO time_tables (code,date,open,close,created_at,updated_at) VALUES #{vals} ON DUPLICATE KEY UPDATE open = '#{open}', close = '#{close}', updated_at= NOW();"
		ActiveRecord::Base.connection.exec_query(sql)
	end

end



