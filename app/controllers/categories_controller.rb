class CategoriesController < ApplicationController
  include Pagy::Method

  allow_unauthenticated_access

  def show
    @category = Category.published.friendly.find(params[:slug])
    @pagy, @products = pagy(:offset, @category.products.visible.includes(images_attachments: :blob).order(:position, :name))
  end
end
