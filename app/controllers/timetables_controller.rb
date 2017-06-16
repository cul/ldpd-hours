class TimetablesController < ApplicationController
  load_and_authorize_resource

  def batch_edit
		@library = Library.find(params["library_id"])
		@date = params[:date] ? Date.parse(params[:date]) : Date.today
		@timetable = Timetable.new
  end

  def batch_update
    @library = Library.find(params["library_id"])
  	@open = "#{params['timetable']['open(4i)']}:#{params['timetable']['open(5i)']}"
  	@close = "#{params['timetable']['close(4i)']}:#{params['timetable']['close(5i)']}"
    closed, tbd = params["timetable"]["closed"], params["timetable"]["tbd"]

    opens_before_close(@open,@close,closed,tbd)
    dates = format_dates(params["timetable"]["dates"])
		adjust_times_if_closed(@open,@close,closed,tbd)

    Timetable.batch_update_or_create(@library.id, dates, @open, @close, closed, tbd, params["timetable"]["note"])
		render json: {message: "success"}, status: :ok
	rescue ArgumentError, MySql::Error, StandardError
		render json: {message: "error"}, status: :error
  end

  private

  def format_dates(dates)
		dates.map!{|selected_date| Date.parse(selected_date) }
  end

  def opens_before_close(open,close, closed, tbd)
    return true if (closed == "1" || tbd == "1")
		if !(Time.parse(open, Time.now) < Time.parse(close, Time.now))  
			raise StandardError
		else
			return true
		end
  end

  def adjust_times_if_closed(open,close,closed,tbd)
    if (closed == "1" || tbd == "1")
      @open, @close = nil, nil
    end
  end
  
end
