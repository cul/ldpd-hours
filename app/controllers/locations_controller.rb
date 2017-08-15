class LocationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :open_now]
  skip_load_and_authorize_resource only: [:index, :show, :open_now]

  def index
    @locations = Location.all
    render layout: "public"
  end

  def new
    @location = Location.new
  end

  def edit
    @location = Location.find(params[:id])
  end

  def create
    @location = Location.new(create_params)
    if @location.save
      flash[:success] = "Location successfully created"
      redirect_to admin_url
    else
      error = @location.errors.full_messages.to_sentence
      flash[:error] = error
      render :new
    end
  end

  def update
    @location = Location.find(params[:id])

    if @location.update(update_params)
      flash[:success] = "Location successfully updated"
      redirect_to admin_url
    else
      error = @location.errors.full_messages.to_sentence
      flash[:error] = error
      render :edit
    end
  end

  def show
    @location = Location.find(params[:id])
    @secondary_locations = Location.where(primary_location: @location).load
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    render layout: "public"
  end

  def open_now
    @now = Time.current
    open_range = (@now - 1.day)..@now
    close_range = (@now)..(@now + 1.day)
    @open = Timetable.where(open: open_range)
                     .where(close: close_range)
                     .includes(:location)
                     .order('locations.name')
                     .select { |t| t.open_at?(@now) }
    render layout: "public"
  end

  private

  def create_params
    params.require(:location).permit(:name, :code, :comment, :comment_two, :url, :summary, :primary, :primary_location_id)
  end

  def update_params
    if current_user.administrator?
      params.require(:location).permit(:name, :comment, :comment_two, :url, :summary, :primary, :primary_location_id)
    else
      params.require(:location).permit(:comment, :comment_two, :url, :summary)
    end
  end
end
