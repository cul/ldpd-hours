class AdminsController < ApplicationController
  	authorize_resource :class => false
	
	def show

	end

end