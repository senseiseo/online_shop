class StorefrontController < ApplicationController
  allow_unauthenticated_access

  def show
    @categories = Category.published.limit(6)
    @products = Product.visible.where(featured: true).includes(:category, images_attachments: :blob).order(:position, :name).limit(6)
    @posts = Post.published.limit(3)
  end
end
