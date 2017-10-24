class Api::V1::LocationsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:open_hours, :open_now]
  skip_load_and_authorize_resource only: [:open_hours, :open_now]

  def open_hours
    begin
      location = Location.find_by! code: params[:code]
      if params[:date].eql? 'today' 
        start_date = Date.today
        end_date = Date.today
      elsif params[:date]
        start_date = Date.parse(params[:date])
        end_date = Date.parse(params[:date])
      else
        # Date#parse will raise an ArgumentError if problem with its argument
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        raise RangeError, "start_date greater than end_date" if start_date > end_date
      end
      render json: { location.code => location.build_api_response(start_date, end_date) }
    rescue ArgumentError => e
      render json: { error: "400: #{e.message}"} , status: 400
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "404: location not found"} , status: 404
    rescue RangeError => e
      render json: { error: "400: #{e.message}"} , status: 400
    end
  end

  def open_now
    now = Time.current
    all_open = timetables_open_now
#    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#    puts all_open.all.inspect
#    puts all_open.count
#    puts Timetable.all.inspect
#    puts Timetable.count
#    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    render plain: "Getting the open_new results..."
  end

  def timetables_open_now
    now = Time.current
 #   puts now
    open_now = Timetable.where("open < ?" , now)
      .where("close > ?" , now)
      .where(closed: false)
      .where(tbd: false)
      .includes(:location)
    # open_now
    open_now.select do |t|
      pli = t.location.primary_location_id
      pli ? open_now.detect { |t2| t2.location_id == pli } : true
    end
    open_now
  end
end
