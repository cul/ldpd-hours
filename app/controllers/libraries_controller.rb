class LibrariesController < ApplicationController

	def index
		@libraries = Library.all
	end

	def new
		@library = Library.new
	end

	def create
		@library = Library.new(library_params)
		if @library.save
			flash[:success] = "Library successfully created"
			redirect_to libraries_url
		else
			render :new
		end
	end

	def show
		@library = Library.find(params[:id])
	end

	private

	def library_params
		params.require(:library).permit(:name, :code, :comment, :comment_two, :url, :summary)
	end

end