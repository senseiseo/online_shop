class CartItemsController < ApplicationController
  allow_unauthenticated_access

  def create
    product = Product.visible.find(cart_item_params[:product_id])
    item = current_cart.cart_items.find_or_initialize_by(product: product)
    item.quantity = item.persisted? ? item.quantity + 1 : 1
    item.save!
    respond
  end

  def update
    item = current_cart.cart_items.find(params[:id])
    quantity = Integer(cart_item_params[:quantity], 10)
    return invalid_quantity if quantity.negative?

    quantity.positive? ? item.update!(quantity: quantity) : item.destroy!
    respond
  rescue ArgumentError, TypeError
    invalid_quantity
  end

  def destroy
    current_cart.cart_items.find(params[:id]).destroy!
    respond
  end

  private

  def cart_item_params
    params.expect(cart_item: %i[product_id quantity])
  end

  def respond
    respond_to do |format|
      format.html { redirect_to cart_path, notice: "Корзина обновлена." }
      format.turbo_stream { render "respond" }
    end
  end

  def invalid_quantity
    render plain: "Количество должно быть целым неотрицательным числом.", status: :unprocessable_entity
  end
end
