require 'rails_helper'

RSpec.describe TimetablesController, type: :controller do

  describe "#format_dates" do
    it "returns an array of date objects" do
      dates = ["2017-06-06", "2017-05-29"]
      expect(TimetablesController.new.send(:format_dates, dates).first.class).to eql(Date)
    end
  end

  describe "#opens_before_close" do
    it "returns true if the open time is before close time" do
      open, close = "12:30PM", "1:30PM"
      expect(TimetablesController.new.send(:opens_before_close, open,close)).to eql(true)
    end

    it "rasies and error if the open time is not before close time" do
      open, close = "2:30PM", "1:30PM"
      expect{TimetablesController.new.send(:opens_before_close, open,close)}.to raise_error(StandardError)
    end
  end

end