class Admin::UsersController < ApplicationController
	load_and_authorize_resource

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			flash[:success] = "User successfully added"
			redirect_to admin_users_path
		else
			flash[:error] = @user.errors.full_messages.to_sentence
			render :new
		end
	end

	def index
		@users = User.all
	end

	private

	def user_params
		params.require(:user).permit(:email, :provider, :uid, :role)
	end

end