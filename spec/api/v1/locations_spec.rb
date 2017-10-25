require 'rails_helper'

# NOTE: TO (hopefully) facilitate navigation through this file,
# long describe blocks have surrounding START and END comments

# START of describe covering the locations API
describe "locations API", :type => :request do
  # START of describe covering open_hours
  describe 'open_hours' do
    # START of describe covering bad location code
    describe "non-existent location" do
      describe "with date=today" do
        it "returns an error" do
          api_url = "/api/v1/locations/supercalifragilisticexpialidocious?date=today"
          get api_url
          expect(response).not_to be_success
          actual_json_as_hash = JSON.parse response.body
          expect(actual_json_as_hash).to eq({"error" => "404: location not found", "data" => nil })
        end
      end
      describe "with date set to specific date" do
        it "returns an error" do
          the_date = Date.today.strftime("%F")
          api_url = "/api/v1/locations/supercalifragilisticexpialidocious?date=the_date"
          get api_url
          expect(response).not_to be_success
          actual_json_as_hash = JSON.parse response.body
          expect(actual_json_as_hash).to eq({"error" => "404: location not found", "data" => nil })
        end
      end
      describe "with date range" do
        it "returns an error" do
          api_url = "/api/v1/locations/supercalifragilisticexpialidocious?start_date=1969-07-21&end_date=1969-07-21"
          get api_url
          expect(response).not_to be_success
          actual_json_as_hash = JSON.parse response.body
          expect(actual_json_as_hash).to eq({"error" => "404: location not found", "data" => nil })
        end
      end
    end # END of describe covering bad location code
    # START of describve covering test involving location with one timetable
    describe "location with 1 timetable for today" do
      let(:butler_today) { FactoryGirl.create(:butler_today) }
      describe "with date=today" do
        it "retrieves today's hours for given location code" do
          location_code=butler_today.location.code
          api_url = "/api/v1/locations/#{location_code}?date=today"
          get api_url
          expect(response).to be_success
          actual_json_as_hash = JSON.parse response.body
          expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_today.json").read
          # update expected_json_as_hash with today's date
          expected_json_as_hash['data']['butler'].first['date'] = Date.today.strftime("%F")
          expect(actual_json_as_hash).to eq(expected_json_as_hash)
        end
      end
      describe "with date set to a specific date" do
        it "retrieves the dates hours for given location code" do
          location_code=butler_today.location.code
          the_date = Date.today.strftime("%F")
          api_url = "/api/v1/locations/#{location_code}?date=#{the_date}"
          get api_url
          expect(response).to be_success
          actual_json_as_hash = JSON.parse response.body
          expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_today.json").read
          # update expected_json_as_hash with today's date
          expected_json_as_hash['data']['butler'].first['date'] = Date.today.strftime("%F")
          expect(actual_json_as_hash).to eq(expected_json_as_hash)
        end
      end
    end # END of describe covering test involving location with one timetable
    # START of describe covering test involving location with five timetables
    describe "location with 5 consecutive-days timetables" do
      let(:day_after_moon_landing) { Date.parse('1969-07-21') }
      # location represented by butler_five_days contains 5 timetables for dates
      # 1969-07-21 thru 1969-07-25.
      let(:butler_five_days) { FactoryGirl.create(:butler_five_days) }
      # START of describe covering bad date formats
      describe "bad date format" do
        it "in date query parameter returns an error" do
          api_url = "/api/v1/locations/#{butler_five_days.code}?date=iamnotadate"
          get api_url
          expect(response).not_to be_success
          actual_json_as_hash = JSON.parse response.body
          expect(actual_json_as_hash).to eq({"error" => "400: invalid date", "data" => nil })
        end
        it "in start date of date range returns an error" do
          end_date = (day_after_moon_landing).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=iamnotadate&end_date=#{end_date}"
          get api_url
          expect(response).not_to be_success
          actual_json_as_hash = JSON.parse response.body
          expect(actual_json_as_hash).to eq({"error" => "400: invalid date", "data" => nil })
        end
        it "in end of date range returns an error" do
          start_date = (day_after_moon_landing + 1).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=#{start_date}&end_date=iamnotadate"
          get api_url
          expect(response).not_to be_success
          actual_json_as_hash = JSON.parse response.body
          expect(actual_json_as_hash).to eq({"error" => "400: invalid date", "data" => nil })
        end
      end # END of describe covering bad date formats
      describe "with start date larger (later) than end date" do
        it "returns an error" do
          # Given the starting and ending date given below, API call should return
          # an error since the start date is later than the end date
          start_date = (day_after_moon_landing + 1).strftime("%F")
          end_date = (day_after_moon_landing).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=#{start_date}&end_date=#{end_date}"
          get api_url
          expect(response).not_to be_success
          actual_json_as_hash = JSON.parse response.body
          expect(actual_json_as_hash).to eq({"error" => "400: start_date greater than end_date", "data" => nil })
        end
      end
      describe "with both a date range (start_date, end_date) and a specific date (date)" do
        it "the specific date query parameter wins out" do
          # Here, the url sent to the API contains three query parameters:
          # starting_date, end_date, and date. So both a range and a specific date
          # are provided. In this case, the specific date wins out, and API call should return
          # the third dates from the location's timetables
          the_date = (day_after_moon_landing + 2).strftime("%F")
          start_date = (day_after_moon_landing + 1).strftime("%F")
          end_date = (day_after_moon_landing + 3).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=#{start_date}&end_date=#{end_date}&date=#{the_date}"
          get api_url
          expect(response).to be_success
          actual_json_as_hash = JSON.parse response.body
          expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_one_day.json").read
          expect(actual_json_as_hash).to eq(expected_json_as_hash)
        end
      end
      # START of describe with date range of 3 consecutive days
      describe "with date range of covering 3 consecutive days" do
        it "with requested range matching middle 3 location timetables" do
          # Given the starting and ending date  below, API call should return
          # the second, third and fourth dates from the location's timetables
          start_date = (day_after_moon_landing + 1).strftime("%F")
          end_date = (day_after_moon_landing + 3).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=#{start_date}&end_date=#{end_date}"
          get api_url
          expect(response).to be_success
          actual_json_as_hash = JSON.parse response.body
          expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_three_days.json").read
          expect(actual_json_as_hash).to eq(expected_json_as_hash)
        end
        it "with requested range matching first two location timetables" do
          # Given the starting and ending date given below, API call should return
          # the first and second dates from the location's timetables;
          # the first date in the requested range has not been set for this location,
          # and the default hash will be returned for that date. Thus, a total of
          # three dates will be returned, with the first date having default values
          start_date = (day_after_moon_landing - 1).strftime("%F")
          end_date = (day_after_moon_landing + 1).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=#{start_date}&end_date=#{end_date}"
          get api_url
          expect(response).to be_success
          actual_json_as_hash = JSON.parse response.body
          expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_three_days_v2.json").read
          expect(actual_json_as_hash).to eq(expected_json_as_hash)
        end
        it "with requested range matching last two location timetables" do
          # Given the starting and ending date given below, API call should return
          # the fourth and fifth dates from the location's timetables;
          # the last date in the requested has not been set for this location,
          # and the default hash will be returned for that date
          start_date = (day_after_moon_landing + 3).strftime("%F")
          end_date = (day_after_moon_landing + 5).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=#{start_date}&end_date=#{end_date}"
          get api_url
          expect(response).to be_success
          actual_json_as_hash = JSON.parse response.body
          # expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_two_days_v2.json").read
          expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_three_days_v3.json").read
          expect(actual_json_as_hash).to eq(expected_json_as_hash)
        end
      end # END of describe with date range of 3 consecutive days
      # START of describe with date range of 11 consecutive days
      describe "reqested range is 11 days" do
        it "with requested range matching all the location timetables" do
          # Given the starting and ending date given below, API call should return
          # all of the location's timetables
          start_date = (day_after_moon_landing - 5).strftime("%F")
          end_date = (day_after_moon_landing + 5).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=#{start_date}&end_date=#{end_date}"
          get api_url
          expect(response).to be_success
          actual_json_as_hash = JSON.parse response.body
          expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_eleven_days.json").read
          expect(actual_json_as_hash).to eq(expected_json_as_hash)
        end
        it "with requested range matching none the location timetables" do
          # Given the starting and ending date given below, API call should return
          # none of the location's timetables. Therefore, for each date in the range,
          # it will return the default hash
          start_date = (day_after_moon_landing + 5).strftime("%F")
          end_date = (day_after_moon_landing + 10).strftime("%F")
          api_url = "/api/v1/locations/#{butler_five_days.code}?start_date=#{start_date}&end_date=#{end_date}"
          get api_url
          expect(response).to be_success
          actual_json_as_hash = JSON.parse response.body
          expected_json_as_hash = JSON.parse file_fixture("api_v1_butler_six_days.json").read
          expect(actual_json_as_hash).to eq(expected_json_as_hash)
        end
      end  # END of describe with date range of 11 consecutive days
    end # END of describe covering test involving location with five timetables
  end # END of describe covering open_hours
  # START of describe covering open_now
  describe 'open_now' do
    let(:butler_open_now) { FactoryGirl.create(:butler_open_now) }
    let(:butler_closed_now) { FactoryGirl.create(:butler_closed_now) }
    let(:lehman_closed_now) { FactoryGirl.create(:lehman_closed_now) }
    let(:miskatonic_open_now) { FactoryGirl.create(:miskatonic_open_now) }
    let(:miskatonic_closed_now) { FactoryGirl.create(:miskatonic_closed_now) }
    # two_hours_from_now_floor is equal to two hours in the future, with
    # the minutes and seconds zeroed out. So, it is currently 10:14 AM,
    # two_hours_from_now_floor would be equal to the string "12:00"
    let(:two_hours_from_now_floor) { Time.zone.local(Time.now.year,
                                                     Time.now.month,
                                                     Time.now.day,
                                                     Time.now.hour + 2,
                                                     0,
                                                     0)
    }
    # similar to the above, except two hours in the past
    let(:two_hours_in_the_past_floor) { Time.zone.local(Time.now.year,
                                                        Time.now.month,
                                                        Time.now.day,
                                                        Time.now.hour - 2,
                                                        0,
                                                        0)
    }
    describe 'returns' do
      it "butler and miskatonic, but not lehman" do
        butler_open_now
        lehman_closed_now
        miskatonic_open_now
        api_url = "/api/v1/locations/open_now"
        get api_url
        expected_json_as_hash = JSON.parse file_fixture("api_v1_open_now.json").read
        # update the expected json since we are using time deltas based off the current time
        expected_json_as_hash['data']['butler']['open_time'] = two_hours_in_the_past_floor.strftime('%H:%M')
        expected_json_as_hash['data']['butler']['close_time'] = two_hours_from_now_floor.strftime('%H:%M')
        expected_json_as_hash['data']['butler']['formatted_date'] = 
          "Until #{two_hours_from_now_floor.strftime('%I:%M%p')}"
        expected_json_as_hash['data']['miskat']['open_time'] = two_hours_in_the_past_floor.strftime('%H:%M')
        expected_json_as_hash['data']['miskat']['close_time'] = two_hours_from_now_floor.strftime('%H:%M')
        expected_json_as_hash['data']['miskat']['formatted_date'] = 
          "Until #{two_hours_from_now_floor.strftime('%I:%M%p')}"
        actual_json_as_hash = JSON.parse response.body
        expect(actual_json_as_hash).to eq(expected_json_as_hash)
      end
      it "no libraries" do
        butler_closed_now
        lehman_closed_now
        miskatonic_closed_now
        api_url = "/api/v1/locations/open_now"
        get api_url
        expected_json_as_hash = JSON.parse file_fixture("api_v1_open_now_none.json").read
        actual_json_as_hash = JSON.parse response.body
        expect(actual_json_as_hash).to eq(expected_json_as_hash)
      end
    end
  end # END of describe covering open_now
end # END of describe covering the locations API
