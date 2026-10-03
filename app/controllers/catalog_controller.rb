class CatalogController < ApplicationController
  include Pagy::Method

  allow_unauthenticated_access

  def index
    @categories = Category.published
    @selected_category = @categories.friendly.find(params[:category]) if params[:category].present?
    products = Product.visible.includes(:category, images_attachments: :blob)
    products = products.where(category: @selected_category) if @selected_category
    products = products.where(featured: true) if params[:featured] == "1"
    @pagy, @products = pagy(:offset, products.order(sort_order))
  end

  private

  def sort_order
    case params[:sort]
    when "price_asc" then { price_cents: :asc, id: :asc }
    when "price_desc" then { price_cents: :desc, id: :asc }
    else { position: :asc, name: :asc }
    end
  end
end
