class TimetablesController < ApplicationController
  before_action :load_location
  load_resource

  def exceptional_edit
    @timetable = Timetable.new(location_id: @location.id)
    authorize! :bulk_edit, @timetable
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
  end

  def batch_edit
    @timetable = Timetable.new(location_id: @location.id)
    authorize! :bulk_edit, @timetable
  end

  def batch_update
    @timetable = Timetable.new(location_id: @location.id)
    authorize! :update, @timetable
    params = timetable_params.to_hash
    if params["start_date"] && params["end_date"]
      params["dates"] = get_dates(params)
    end

    if params["dates"].blank?
      render json: { message: "no dates selected" }, status: :error
      return
    end

    @open = "#{params['open(4i)']}:#{params['open(5i)']}"
    @close = "#{params['close(4i)']}:#{params['close(5i)']}"

    format_dates(params)
    adjust_times_if_closed(params)

    Timetable.batch_update_or_create(params.merge('location_id' => @location.id), @open, @close)
    if @open && @open >= @close
      render json: { message: "overnight schedule set", status: :warning }, status: :ok
    else
      render json: { message: "success" }, status: :ok
    end
  rescue ArgumentError, Mysql2::Error => e
    render json: { message: "ERROR #{e.message}" }, status: :error
  end

  def load_location
    @location = Location.find_by!(code: params["location_code"])
  end

  private

  def timetable_params
    params.require(:timetable).permit(
      "open(4i)", "open(5i)", "close(4i)", "close(5i)", :closed, :tbd, :note,
      :location_id, :start_date, :end_date, :days, dates: []
    )
  end

  def format_dates(params)
    params["dates"].map!{|selected_date| Date.parse(selected_date) }
  end

  def adjust_times_if_closed(params)
    if (params["closed"] == "1" || params["tbd"] == "1")
      @open, @close = nil, nil
    end
    params["closed"] = "0" if params["closed"].blank?
    params["tbd"] = "0" if params["tbd"].blank?
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
