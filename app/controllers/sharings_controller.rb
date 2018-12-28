class SharingsController < ApplicationController
  before_action :set_category

  def index
    @sharings = Sharing.includes(:sharing_elements).where(site: @category.sites).limit(20)
  end

  private

  def set_category
    @category = Category.find_by name: params[:category]
    raise ActiveRecord::RecordNotFound if @category.blank?
  end
end
