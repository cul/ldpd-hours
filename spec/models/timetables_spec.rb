require "rails_helper"

RSpec.describe :Timetable, type: :model do
  before(:each) do
    Library.create(name: "Butler", code: "butler")
  end
	describe "batch_update_or_create" do
		it "should add records to the time_tables table" do
			code, dates, open, close, closed, tbd, note = Library.first.id, [Date.today], "07:00AM", "08:00PM", false, false, ""
			Timetable.batch_update_or_create({"library_id" => code, "dates" => dates, "closed" => closed, "tbd" => tbd, "note" => note}, open, close)
			expect(Timetable.last.date).to eq(Date.today)
		end

		it "should add multiple dates" do
			code, dates, open, close, closed, tbd, note = Library.first.id, [Date.today, Date.today + 1.month], "07:00AM", "08:00PM", false, false, ""
			Timetable.batch_update_or_create({"library_id" => code, "dates" => dates, "closed" => closed, "tbd" => tbd, "note" => note}, open, close)
			expect(Timetable.count).to eq(2)
		end

		it "should not have an open or close time for a closed day" do
			code, dates, open, close, closed, tbd, note = Library.first.id, [Date.today], nil, nil, true, false, ""
			Timetable.batch_update_or_create({"library_id" => code, "dates" => dates, "closed" => closed,"tbd" => tbd,"note" => note}, open, close)
			expect(Timetable.first.open).to eq(nil)
			expect(Timetable.first.close).to eq(nil)
		end
	end

  
end