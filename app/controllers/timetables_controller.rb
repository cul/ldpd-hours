class TimetablesController < ApplicationController
  def exceptional_edit
    @location = Location.find(params["location_id"])
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @timetable = Timetable.new
  end

  def batch_edit
    @location = Location.find(params["location_id"])
    @timetable = Timetable.new
  end

  def batch_update
    params = timetable_params.to_hash
    if params["start_date"] && params["end_date"]
      params["dates"] = get_dates(params)
    end

    @open = "#{params['open(4i)']}:#{params['open(5i)']}"
    @close = "#{params['close(4i)']}:#{params['close(5i)']}"

    opens_before_close(params)
    format_dates(params)
    adjust_times_if_closed(params)

    Timetable.batch_update_or_create(params, @open, @close)
    render json: {message: "success"}, status: :ok
  rescue ArgumentError, MySql::Error, ArgumentError, StandardError
    render json: {message: "error"}, status: :error
  end

  private

  def timetable_params
    params.require(:timetable).permit("open(4i)", "open(5i)", "close(4i)", "close(5i)", :closed, :tbd, :note, :location_id, :start_date, :end_date, :days, dates: [])
  end

  def format_dates(params)
    params["dates"].map!{|selected_date| Date.parse(selected_date) }
  end

  def opens_before_close(params)
    if (params["closed"] == "1" || params["tbd"] == "1")
      return true
    elsif !(Time.parse(@open, Time.current) < Time.parse(@close, Time.current))
      raise ArgumentError, "End time cannot be before start time"
    else
      return true
    end
  end

  def adjust_times_if_closed(params)
    if (params["closed"] == "1" || params["tbd"] == "1")
      @open, @close = nil, nil
    end
  end

  def get_dates(params)
    *keys = if params["days"] == "Friday"
              5
            elsif params["days"] == "Saturday"
              6
            elsif params["days"] == "Sunday"
              0
            else
              [1,2,3,4]
            end
    start_day, end_day = Date.strptime(params["start_date"], "%m/%d/%Y"), Date.strptime(params["end_date"], "%m/%d/%Y")
    dates_by_weekday = (start_day..end_day).group_by(&:wday)
    dates_by_weekday.fetch_values(*keys).flatten.map(&:to_s)
  end
end
