class TimeTablesController < ApplicationController
  # load_and_authorize_resource

  def batch_edit
	@library = Library.find_by(params[:code])
	@date = params[:date] ? Date.parse(params[:date]) : Date.today
	@time_table = TimeTable.new
  end

  def batch_update
  	open = "#{params['time_table']['open(4i)']}:#{params['time_table']['open(5i)']}"
  	close = "#{params['time_table']['close(4i)']}:#{params['time_table']['close(5i)']}"
  	return if !opens_before_close(open,close)

  	code = Library.find(params["id"]).code
  	dates = format_dates(params["time_table"]["dates"])
  	TimeTable.batch_update_or_create(code, dates, open, close)
  	render json: { message: "updated" }, status: :ok
  end

  private

  def time_table_params
  	params.require(:time_table).permit(:open, :close, :dates)
  end

  def format_dates(dates)
	dates.map{|selected_date| Date.strptime(selected_date, '%m/%d/%Y') }
  end

  def opens_before_close(open,close)
    Time.parse(open, Time.now) < Time.parse(close, Time.now)
  end
  
end
