class LocationsController < ApplicationController
  before_action :load_location
  skip_before_action :load_location, only: [:index, :open_now, :new, :create]
  skip_before_action :authenticate_user!, only: [:index, :show, :open_now]
  skip_before_action :verify_authenticity_token, only: :show
  def index
    home_page = begin
      path = request.original_fullpath.split('?')[0]
      path.blank? or path == '/'
    end
    @locations = (home_page ? Location.where(front_page: true) : Location.all).order(:name)
    @now = Time.current
    @open = all_open(home_page)
    render layout: "public"
  end

  def new
    authorize! :new, Location
    @location = Location.new
  end

  def edit
    authorize! :edit, @location
  end

  def create
    @location = Location.new(create_params)
    authorize! :create, @location
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
    authorize! :update, @location
    if @location.update(update_params)
      flash[:success] = "Location successfully updated"
      redirect_to admin_url
    else
      error = @location.errors.full_messages.to_sentence
      flash[:error] = error
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @location
  end

  def show
    @secondary_locations = Location.where(primary_location: @location).load
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    respond_to do |format|
      format.html { render layout: "public" }
      format.json { render json: @location.to_json }
      format.js do
        # this is support for a legacy API to be retired before v2
        schedule = Timetable.find_by(date: @date, location_id: @location.id)
        hours = schedule ? schedule.display_str : "TBD"
        hours.sub!('-','&mdash;')
        render js: "#{params[:callback]}({\"hours\":\"#{hours}\"})"
      end
    end
  end

  def open_now
    @now = Time.current
    @open = all_open
    render layout: "public"
  end

  def load_location
    @location = Location.find_by!(code: params['code'])
  end

  def all_open(home_page = false)
    all_open = Timetable.where("open < ?" , @now)
                     .where("close > ?" , @now)
                     .where(closed: false)
                     .where(tbd: false)
                     .includes(:location)
    all_open = all_open.where(locations: {front_page: true}) if home_page
    all_open = all_open.order('locations.name').load
    all_open.select do |t|
      pli = t.location.primary_location_id
      pli ? all_open.detect { |t2| t2.location_id == pli } : true
    end
  end

  private

  def create_params
    params.require(:location).permit(:name, :code, :comment, :comment_two, :url, :summary, :primary, :primary_location_id)
  end

  def update_params
    if current_user.administrator?
      params.require(:location).permit(:name, :code, :comment, :comment_two, :url, :summary, :primary, :primary_location_id, :front_page)
    else
      params.require(:location).permit(:comment, :comment_two, :url, :summary)
    end
  end
end
