require "rails_helper"

describe CalendarHelper do
  let(:now) { Time.current }
  let(:today) { now.to_date }
  let(:open) { now - 1.hour }
  let(:still_open) { now + 1.hour }
  let(:closed) { now - 30.minutes }
  let(:subject_class) { s = Class.new { include CalendarHelper } }

  context "no open libraries" do
    subject { subject_class.new }
    it do
      expect(subject.until_or_closed(Location.new(id: 1), [])).to eql("CLOSED")
    end
  end

  context "open library" do
    subject { subject_class.new }
    let(:timetable) { Timetable.new(location_id: 1, date: today, open: open, close: still_open) }
    it do
      expect(subject.until_or_closed(Location.new(id: 1), [timetable])).to match(/\s*\d{1,2}:\d{2} (a|p)m - \s*\d{1,2}:\d{2} (a|p)m/)
    end
  end
  describe "#page_title" do
    subject { subject_class.new.page_title(nil) }
    let(:location) { Location.new(id: 1, name: location_name) }
    context "index page" do
      it { is_expected.to eql("Library Hours and Locations Open Now") }
    end
    context "location name ends in hours" do
      subject { subject_class.new.page_title(location) }
      let(:location_name) { "Miskatonic Hours" }

      it { is_expected.to eql("Miskatonic Hours") }
    end
    context "location name does not end in hours" do
      subject { subject_class.new.page_title(location) }
      let(:location_name) { "Miskatonic" }

      it { is_expected.to eql("Miskatonic Hours") }
    end
  end
end
