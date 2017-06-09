require "rails_helper"

RSpec.describe TimeTable, :type => :model do

	describe "batch_update_or_create" do
		it "should add records to the time_tables table" do
			code, dates, open, close = "butler", [Date.today], "07:00AM", "08:00PM"
			TimeTable.batch_update_or_create(code,dates,open,close)
			expect(TimeTable.last.date).to eq(Date.today)
		end

		it "should add multiple dates" do
			code, dates, open, close = "lehman", [Date.today, Date.today + 1.month], "07:00AM", "08:00PM"
			TimeTable.batch_update_or_create(code,dates,open,close)
			expect(TimeTable.count).to eq(2)
		end
	end

  
end