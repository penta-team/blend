class SharingsController < ApplicationController
  def index
    @category = Category.find_by name: params[:category]
  end

  def search
  end

end