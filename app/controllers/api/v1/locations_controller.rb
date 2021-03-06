class Api::V1::LocationsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:open_hours, :open_now]
  skip_load_and_authorize_resource only: [:open_hours, :open_now]
  before_action :add_cors_header, only: [:open_hours, :open_now]

  def open_hours
    begin
      location = Location.find_by! code: params[:code]
      if params[:date].eql? 'today' 
        start_date = Date.current
        end_date = Date.current
      elsif params[:date]
        start_date = Date.parse(params[:date])
        end_date = Date.parse(params[:date])
      else
        # Date#parse will raise an ArgumentError if problem with its argument
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        raise RangeError, "start_date greater than end_date" if start_date > end_date
      end
      data_value = { location.code => location.build_api_response(start_date, end_date) }
      render json: { data: data_value }
    rescue ArgumentError => e
      render json: { error: { "msg" => "400: #{e.message}" }, data: nil } , status: 400
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: { "msg" => "404: location not found" }, data: nil } , status: 404
    rescue RangeError => e
      render json: { error: { "msg" => "400: #{e.message}" }, data: nil } , status: 400
    end
  end

  def open_now
    @now = Time.current
    open_locations_hash = {}
    timetables_open_now.each do |t|
      open_locations_hash[t.location.code] = t.open_now_hash
    end
    data_value = open_locations_hash.empty?  ? nil :  open_locations_hash
    render json: { data: data_value }
  end

  # fcd1, 10/25/17: Following functionality is almost verbatim
  # the same code as found in all_open#LocationsController
  # Therefore, for now, this functionality was removed from #open_now
  # above and put in it's own method. This should help refactor in the
  # future if we decide to merge this method and all_open#LocationsController
  def timetables_open_now
    open_now = Timetable.where("open < ?" , @now)
      .where("close > ?" , @now)
      .where(closed: false)
      .where(tbd: false)
      .includes(:location)
    open_now.select do |t|
      pli = t.location.primary_location_id
      pli ? open_now.detect { |t2| t2.location_id == pli } : true
    end
  end

  def add_cors_header
    headers['Access-Control-Allow-Origin'] = '*'
  end
end
