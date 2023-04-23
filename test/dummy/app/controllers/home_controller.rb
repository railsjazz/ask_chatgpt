class HomeController < ApplicationController
  before_action :check_if_admin

  # code for refactoring
  def index
    @users = User.all
    @max = find_max_user
    @time = Time.now
    var = 42
    @last_month = Time.now - 1.month
  end

  private

  def users
    @users = User.where("id > 0")
  end

  def find_max_user
    @users.max_by(&:id)
  end

  def check_if_admin
  end

  def calculate_average_users_age
    @users.sum(&:age) / @users.size
  end
end
