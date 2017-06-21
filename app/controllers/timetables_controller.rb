class TimetablesController < ApplicationController
  # load_and_authorize_resource

  def batch_edit
    @location = Location.find(params["location_id"])
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @timetable = Timetable.new
  end

  def batch_update
    @open = "#{params['timetable']['open(4i)']}:#{params['timetable']['open(5i)']}"
    @close = "#{params['timetable']['close(4i)']}:#{params['timetable']['close(5i)']}"

    opens_before_close(timetable_params)
    format_dates(timetable_params)
    adjust_times_if_closed(timetable_params)

    Timetable.batch_update_or_create(timetable_params, @open, @close)
    render json: {message: "success"}, status: :ok
  rescue ArgumentError, MySql::Error, ArgumentError, StandardError
    render json: {message: "error"}, status: :error
  end

  private

  def timetable_params
    params.require(:timetable).permit("open(4i)", "open(5i)", "close(4i)", "close(5i)", :closed, :tbd, :note, :location_id, dates: [])
  end

  def format_dates(params)
    params["dates"].map!{|selected_date| Date.parse(selected_date) }
  end

  def opens_before_close(params)
    if (params["closed"] == "1" || params["tbd"] == "1")
      return true
    elsif !(Time.parse(@open, Time.now) < Time.parse(@close, Time.now))
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

end
