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
    if home_page
      @locations = Location.where(front_page: true).where.not(code: 'all', suppress_display: true).includes(:access_points)
    else
      @locations = Location.where.not(code: 'all', suppress_display: true).includes(:access_points)
    end
    @locations = @locations.order(:name)
    @now = Time.current
    @open = all_open(home_page)
    @closed_location_ids_to_tomorrow_open_timetables = closed_location_ids_to_tomorrow_open_timetables(@open, home_page)
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
    clean_params = update_params
    clean_params.dig(:access_points)&.map! do |ap|
      ap.present? ? AccessPoint.find_or_create_by(id: ap.to_i) : nil
    end
    clean_params.dig(:access_points)&.compact!
    if @location.update(clean_params)
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
    unless @location && (current_user || !@location.suppress_display)
      respond_to do |format|
        format.html { render "errors/not_found", status: 404, layout: "public" }
        format.json { render json: {}, status: 404 }
      end
      return
    end
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
    all_open = all_open.order('locations.name')
    all_open = all_open.where.not(locations: { code: 'all' })
    all_open = all_open.load
    all_open.select do |t|
      pli = t.location.primary_location_id
      pli ? all_open.detect { |t2| t2.location_id == pli } : true
    end
  end

  def closed_location_ids_to_tomorrow_open_timetables(open_location_timetables = all_open, home_page = false)
    open_location_ids = all_open.map { |timetable| timetable.location_id }
    closed_locations = Location.where.not(id: open_location_ids)

    tomorrow_open_timetables_for_closed = Timetable.where(location_id: closed_locations)
                    .where("open > ?" , @now)
                    .where("open < ?" , @now + 1.day)
                    .where(closed: false)
                    .where(tbd: false)
                    .order(:date) # make sure that next day appears first in sort order, in case we get two calendar dates in results
                    .includes(:location)
    tomorrow_open_timetables_for_closed = tomorrow_open_timetables_for_closed.where(locations: {front_page: true}) if home_page
    tomorrow_open_timetables_for_closed = tomorrow_open_timetables_for_closed.where.not(locations: {code: 'all'})
    closed_loc_ids_to_tomorrow_open_timetables = {}
    tomorrow_open_timetables_for_closed.each do |timetable|
      next if closed_loc_ids_to_tomorrow_open_timetables.key?(timetable.location_id)
      closed_loc_ids_to_tomorrow_open_timetables[timetable.location_id] = timetable
    end
    closed_loc_ids_to_tomorrow_open_timetables
  end

  private

  def create_params
    params.require(:location).permit(:name, :code, :comment, :comment_two, :url, :summary, :primary, :primary_location_id, :short_note, :short_note_url)
  end

  def update_params
    if current_user.administrator?
      params.require(:location).permit(:name, :code, :comment, :comment_two, :url, :summary, :primary, :primary_location_id, :front_page, :short_note, :short_note_url, :suppress_display, :wifi_connections_baseline, access_points: [])
    else
      params.require(:location).permit(:comment, :comment_two, :url, :summary, :short_note, :short_note_url)
    end
  end
end
