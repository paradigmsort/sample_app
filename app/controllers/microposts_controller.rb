class MicropostsController < ApplicationController
  before_filter :signed_in_user
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      render 'static_pages/home'
    else
      render 'static_pages/home'
    end
  end
  def destroy
  end
end