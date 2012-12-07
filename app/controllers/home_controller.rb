class HomeController < ApplicationController
  def index
    @users = User.all
  end

  def leaderboard
    @users = User.all(:limit => 20, :order => "score desc")
  end

  def stats
  end
end
