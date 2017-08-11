require "rails_helper"

RSpec.describe Timetable, type: :model do
  describe "#generate_time" do
    let(:butler_today) { FactoryGirl.create(:butler_today) }

    it 'returns nil when date blank' do
      butler_today.update(date: nil)
      expect(butler_today.generate_time(butler_today.open)).to be nil
    end

    it 'returns nil when open_or_close is blank' do
      butler_today.update(open: nil)
      expect(butler_today.generate_time(butler_today.open)).to be nil
    end

    it 'creates correct time object with open time' do
      expect(
        butler_today.generate_time(butler_today.open)
      ).to eql Time.zone.local(Date.current.year, Date.current.month, Date.current.day, '9')
    end

    it 'creates correct time object with close time' do
      expect(
        butler_today.generate_time(butler_today.close)
      ).to eql Time.zone.local(Date.current.year, Date.current.month, Date.current.day, '17')
    end
  end

  describe "#open_at?" do
    let(:butler_today) {
      FactoryGirl.create(
        :butler_today, open: (Time.current - 1.hour),
        close: (Time.current + 3.hours)
      )
    }

    it 'returns true when library open' do
      expect(butler_today.open_at?(Time.current)).to be true
    end

    it 'returns false when library closed' do
      butler_today.update(open: (Time.current + 2.hours).hour.to_s)
      expect(butler_today.open_at?(Time.current)).to be false
    end
  end

  describe ".batch_update_or_create" do
    let(:butler) { FactoryGirl.create(:butler) }

    it "should add records to the time_tables table" do
      code, dates, open, close, closed, tbd, note = butler.id, [Date.current], "07:00AM", "08:00PM", false, false, ""
      Timetable.batch_update_or_create({"location_id" => code, "dates" => dates, "closed" => closed, "tbd" => tbd, "note" => note}, open, close)
      expect(Timetable.last.date).to eq(Date.current)
    end

    it "should add multiple dates" do
      code, dates, open, close, closed, tbd, note = butler.id, [Date.current, Date.current + 1.month], "07:00AM", "08:00PM", false, false, ""
      Timetable.batch_update_or_create({"location_id" => code, "dates" => dates, "closed" => closed, "tbd" => tbd, "note" => note}, open, close)
      expect(Timetable.count).to eq(2)
    end

    it "should not have an open or close time for a closed day" do
      code, dates, open, close, closed, tbd, note = butler.id, [Date.current], nil, nil, true, false, ""
      Timetable.batch_update_or_create({"location_id" => code, "dates" => dates, "closed" => closed,"tbd" => tbd,"note" => note}, open, close)
      expect(Timetable.first.open).to eq(nil)
      expect(Timetable.first.close).to eq(nil)
    end
  end

  describe "display_str" do
    let(:butler) { FactoryGirl.create(:butler) }

    it "should display closed if closed" do
      t = Timetable.create(location_id: butler.id, date: Date.today, closed: true)
      expect(t.display_str).to eq("Closed")
    end

    it "should display tbd if status is tbd" do
      t = Timetable.create(location_id: butler.id, date: Date.today, tbd: true)
      expect(t.display_str).to eq("TBD")
    end
  end

end
