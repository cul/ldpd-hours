require "rails_helper"

RSpec.describe Timetable, type: :model do
  describe "#generate_time" do
    let(:butler_today) { FactoryBot.create(:butler_today) }

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
    let(:now) { Time.current }
    let(:butler_today) {
      FactoryBot.create(
        :butler_today, open: (now - 1.hour),
        close: (now + 3.hours)
      )
    }

    it 'returns true when library open' do
      expect(butler_today.open_at?(now)).to be true
    end

    it 'returns false when library closed' do
      butler_today.update(open: (now + 2.hours))
      expect(butler_today.open_at?(now)).to be false
    end
  end

  describe ".batch_update_or_create" do
    let(:butler) { FactoryBot.create(:butler) }

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
    let(:butler) { FactoryBot.create(:butler) }

    it "should display 24 hour message if all day" do
      now = Time.current
      t = Timetable.create(location_id: butler.id, date: now.to_date, open: now, close: now + 1.day)
      expect(t.display_str).to match("24 hours")
    end

    it "should display closed if closed" do
      t = Timetable.create(location_id: butler.id, date: Date.today, closed: true)
      expect(t.display_str).to eq("Closed")
    end

    it "should display tbd if status is tbd" do
      t = Timetable.create(location_id: butler.id, date: Date.today, tbd: true)
      expect(t.display_str).to eq("TBD")
    end
  end

  describe "day_info_hash" do
    let(:butler_today) { FactoryBot.create(:butler_today) }
    let(:expected_day_info_hash) do
      {
        date: Date.current.strftime("%F"),
        closed: false,
        tbd: false,
        open_time: "09:00",
        close_time: "17:00",
        note: "Hello!",
        short_note: "This is a short note",
        short_note_url: "https://library.columbia.edu",
        formatted_date: "09:00AM-05:00PM"
      }
      end
    let(:expected_day_info_hash_no_note) do
      {
        date: Date.current.strftime("%F"),
        closed: false,
        tbd: false,
        open_time: "09:00",
        close_time: "17:00",
        note: "",
        short_note: "This is a short note",
        short_note_url: "https://library.columbia.edu",
        formatted_date: "09:00AM-05:00PM"
      }
      end
    describe "should return hash of formatted values for existing timetable" do
      it "that has hours, a note, and closed = tbd = false" do
        # add a nice note
        butler_today.note = "Hello!"
        expect(butler_today.day_info_hash).to eq(expected_day_info_hash)
      end
      it "that has hours, no note, and closed = tbd = false" do
        # add a nice note
        # butler_today.note = "Hello!"
        expect(butler_today.day_info_hash).to eq(expected_day_info_hash_no_note)
      end
      it "that has hours, a note, and closed = false, tbd = true" do
        # add a nice note
        butler_today.note = expected_day_info_hash[:note] = "Still thinking about it..."
        # set tbd to true for timetable, which should be reflected in the generated hash
        butler_today.tbd = expected_day_info_hash[:tbd] = true
        # setting butler_today.tbd to true should entail the following formatted_date
        expected_day_info_hash[:formatted_date] = "TBD"
        expect(butler_today.day_info_hash).to eq(expected_day_info_hash)
      end
      it "that has hours, a note, and closed = true, tbd = false" do
        # add a nice note
        butler_today.note = expected_day_info_hash[:note] = "Sorry, we are closed."
        # set closed to true for timetable, which should be reflected in the generated hash
        butler_today.closed = expected_day_info_hash[:closed] = true
        # setting butler_today.closed to true should entail the following formatted_date
        expected_day_info_hash[:formatted_date] = "Closed"
        expect(butler_today.day_info_hash).to eq(expected_day_info_hash)
      end
      it "that has hours, a note, and closed = tbd = true, closed wins out" do
        # add a nice note
        butler_today.note = expected_day_info_hash[:note] = "So confused..."
        # set closed to true for timetable, which should be reflected in the generated hash
        butler_today.closed = expected_day_info_hash[:closed] = true
        # set tbd to true for timetable, which should be reflected in the generated hash
        butler_today.tbd = expected_day_info_hash[:tbd] = true
        # if both butler_today.closed and butler_today.tbd are set to true
        # the 'closed' attribute takes precedence, which is reflected in the
        # formatted_date
        expected_day_info_hash[:formatted_date] = "Closed"
        expect(butler_today.day_info_hash).to eq(expected_day_info_hash)
      end
    end
  end

  describe "default_day_info_hash" do
    let(:expected_day_info_hash) do
      {
        date: Date.current.strftime("%F"),
        closed: false,
        tbd: true,
        open_time: nil,
        close_time: nil,
        note: '',
        short_note: '',
        short_note_url: '',
        formatted_date: 'TBD'
      }
    end
    it "should return hash of default values for non-existent timetable" do
      day_info_hash = Timetable.default_day_info_hash Date.current
      expect(day_info_hash).to eq(expected_day_info_hash)
    end
  end

  describe "open_now_hash" do
    let(:butler_today) { FactoryBot.create(:butler_today) }
    let(:expected_hash) do
      {
        open_time: "09:00",
        close_time: "17:00",
        formatted_date: "Until 05:00PM"
      }
    end
    it "should return hash with open and close times and until what time the location is open" do
      expect(butler_today.open_now_hash).to eq(expected_hash)
    end
  end
end
