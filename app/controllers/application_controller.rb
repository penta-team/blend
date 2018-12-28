class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_categories

  def set_categories
    @categories = Category.with_site
  end
end
