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

  describe "#get_dates" do
    it "returns all mon-thurs when selected" do
      params = {"days" => "mon-thurs", "start_date" => "07/03/2017", "end_date" => "07/10/2017"}
      result = controller.send(:get_dates, params)
      expect(result.count).to eql(5)
    end

    it "returns all Sundays when selected" do
      params = {"days" => "Sunday", "start_date" => "07/02/2017", "end_date" => "07/10/2017"}
      result = controller.send(:get_dates, params)
      expect(result.count).to eql(2)
    end

    it "returns all saturdays when selected" do
      params = {"days" => "Saturday", "start_date" => "07/03/2017", "end_date" => "07/10/2017"}
      result = controller.send(:get_dates, params)
      expect(result.count).to eql(1)
    end

    it "returns all fridays when selected" do
      params = {"days" => "Friday", "start_date" => "07/03/2017", "end_date" => "07/10/2017"}
      result = controller.send(:get_dates, params)
      expect(result.count).to eql(1)
    end
  end

end