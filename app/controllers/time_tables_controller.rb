class TimeTablesController < ApplicationController
  
  def batch_edit
	@library = Library.find_by(params[:code])
	@date = params[:date] ? Date.parse(params[:date]) : Date.today
	@calendar = TimeTable.new
  end

  def batch_update

  end
  
end
