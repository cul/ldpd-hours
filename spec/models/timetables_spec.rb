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
      ).to eql Time.local(Date.today.year, Date.today.month, Date.today.day, '9')
    end

    it 'creates correct time object with close time' do
      expect(
        butler_today.generate_time(butler_today.close)
      ).to eql Time.local(Date.today.year, Date.today.month, Date.today.day, '17')
    end
  end

  describe "#open_at?" do
    let(:butler_today) {
      FactoryGirl.create(
        :butler_today, open: (Time.now - 1.hour).hour.to_s,
        close: (Time.now + 3.hours).hour.to_s
      )
    }

    it 'returns true when library open' do
      expect(butler_today.open_at?(Time.now)).to be true
    end

    it 'returns false when library closed' do
      butler_today.update(open: (Time.now + 2.hours).hour.to_s)
      expect(butler_today.open_at?(Time.now)).to be false
    end
  end

  describe ".batch_update_or_create" do
    let(:butler) { FactoryGirl.create(:butler) }

    it "should add records to the time_tables table" do
      code, dates, open, close, closed, tbd, note = butler.id, [Date.today], "07:00AM", "08:00PM", false, false, ""
      Timetable.batch_update_or_create({"location_id" => code, "dates" => dates, "closed" => closed, "tbd" => tbd, "note" => note}, open, close)
      expect(Timetable.last.date).to eq(Date.today)
    end

    it "should add multiple dates" do
      code, dates, open, close, closed, tbd, note = butler.id, [Date.today, Date.today + 1.month], "07:00AM", "08:00PM", false, false, ""
      Timetable.batch_update_or_create({"location_id" => code, "dates" => dates, "closed" => closed, "tbd" => tbd, "note" => note}, open, close)
      expect(Timetable.count).to eq(2)
    end

    it "should not have an open or close time for a closed day" do
      code, dates, open, close, closed, tbd, note = butler.id, [Date.today], nil, nil, true, false, ""
      Timetable.batch_update_or_create({"location_id" => code, "dates" => dates, "closed" => closed,"tbd" => tbd,"note" => note}, open, close)
      expect(Timetable.first.open).to eq(nil)
      expect(Timetable.first.close).to eq(nil)
    end
  end
end
