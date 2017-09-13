class Api::V1::LocationsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:open_hours]
  skip_load_and_authorize_resource only: [:open_hours]

  def open_hours
    begin
      location = Location.find_by! code: params[:code]
      if params[:date].eql? 'today' 
        start_date = Date.today
        end_date = Date.today
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
end
