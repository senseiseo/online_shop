class ProductsController < ApplicationController
  allow_unauthenticated_access

  def show
    @product = Product.visible.includes(:category, images_attachments: :blob).friendly.find(params[:slug])
  end
end
