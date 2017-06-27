class AdminsController < ApplicationController
  authorize_resource :class => false

  def show
    @libraries = Library.all
  end
end
