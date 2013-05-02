class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @micropost = Micropost.new()
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
