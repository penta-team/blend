class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_categories

  def set_categories
    @categories = Category.all
  end
end
