class AdminsController < ApplicationController
  # authorize_resource :class => false

  def show
    @locations = Location.all
  end
end
