class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    if signed_in?
      @user = User.find(params[:id])
    else
      flash[:error] = "Please sign in to access this page."
      redirect_to signin_path
    end
  end

  def update
    if signed_in?
      @user = User.find(params[:id])
      if @user.update_attributes(params[:user])
        flash[:success] = "Profile successfully changed."
        sign_in @user
        redirect_to @user
      else
        render 'edit'
      end
    else
      flash[:error] = "Please sign in to access this page."
      redirect_to signin_path
    end
  end
end
