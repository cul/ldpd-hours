class Admin::UsersController < ApplicationController
  load_and_authorize_resource

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    @user.provider = "saml"
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

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |f|
      f.html {
        flash[:success] = "User successfully deleted"
        redirect_to admin_users_path
      }
      f.json { render json: { message: "removed" }, status: :ok }
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      respond_to do |f|
        f.html {
          flash[:success] = "User successfully updated"
          redirect_to admin_users_path
        }
        f.json { render json: { message: "updated" }, status: :ok }
      end
    else
      error = @user.errors.full_messages.to_sentence
      respond_to do |f|
        f.html {
          flash[:error] = error
          render :edit
        }
        f.json { render json: { message:  error }, status: :internal_server_error }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :provider, :uid, :role)
  end
end
