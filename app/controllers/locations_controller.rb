class LocationsController < ApplicationController

  def index
    @locations = Location.all
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      flash[:success] = "Location successfully created"
      redirect_to locations_url
    else
      render :new
    end
  end

  def show
    @location = Location.find(params[:id])
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
  end

  def open_now
    @now = Time.current
    @open = Timetable.where(date: Date.current)
                     .where.not(open: nil, close: nil)
                     .select { |t| t.open_at?(@now) }
                     .sort_by { |t| t.location.name }
  end

  private

  def location_params
    params.require(:location).permit(:name, :code, :comment, :comment_two, :url, :summary)
  end
end
