require "rails_helper"

RSpec.describe Timetable, :type => :model do
  before(:each) do
    Library.create(name: "Butler", code: "butler")
  end
	describe "batch_update_or_create" do
		it "should add records to the time_tables table" do
			code, dates, open, close = Library.first.id, [Date.today], "07:00AM", "08:00PM"
			Timetable.batch_update_or_create(code,dates,open,close)
			expect(Timetable.last.date).to eq(Date.today)
		end

		it "should add multiple dates" do
			code, dates, open, close = Library.first.id, [Date.today, Date.today + 1.month], "07:00AM", "08:00PM"
			Timetable.batch_update_or_create(code,dates,open,close)
			expect(Timetable.count).to eq(2)
		end
	end

  
end