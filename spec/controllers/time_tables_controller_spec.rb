require 'rails_helper'

RSpec.describe TimeTablesController, type: :controller do

  describe "#format_dates" do
    it "returns an array of date objects" do
      dates = ["2017-06-06", "2017-05-29"]
      expect(TimeTablesController.new.send(:format_dates, dates).first.class).to eql(Date)
    end
  end

  describe "#opens_before_close" do
    it "returns true if the open time is before close time" do
      open, close = "12:30PM", "1:30PM"
      expect(TimeTablesController.new.send(:opens_before_close, open,close)).to eql(true)
    end

    it "returns false if the open time is not before close time" do
      open, close = "2:30PM", "1:30PM"
      expect(TimeTablesController.new.send(:opens_before_close, open,close)).to eql(false)
    end
  end

end