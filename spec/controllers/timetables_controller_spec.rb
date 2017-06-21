require 'rails_helper'

RSpec.describe TimetablesController, type: :controller do

  describe "#format_dates" do
    it "returns an array of date objects" do
      dates = ["2017-05-05", "2017-06-08"]
      expect(controller.send(:format_dates, {"dates" => dates}).first.class).to eql(Date)
    end
  end

  describe "#opens_before_close" do
    it "returns true if the open time is before close time" do
      controller.instance_variable_set(:@close, "2:30PM")
      controller.instance_variable_set(:@open, "1:30PM")
      expect(controller.send(:opens_before_close, {closed: false, tbd: false})).to eql(true)
    end

    it "rasies and error if the open time is not before close time" do
      controller.instance_variable_set(:@open, "2:30PM")
      controller.instance_variable_set(:@close, "1:30PM")
      expect{controller.send(:opens_before_close, {closed: false, tbd: false})}.to raise_error(ArgumentError)
    end
  end

end