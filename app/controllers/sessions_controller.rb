class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by_email(params[:session][:email])
    if @user
    else
      flash[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end
end
