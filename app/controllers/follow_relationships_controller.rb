class FollowRelationshipsController < ApplicationController
  before_filter :signed_in_user
  def create
    @user = User.find(params[:follow_relationship][:followed_id])
    current_user.follow!(@user)
    redirect_to @user
  end

  def destroy
    @user = FollowRelationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    redirect_to @user
  end
end