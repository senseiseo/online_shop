class CheckoutsController < ApplicationController
  allow_unauthenticated_access

  def new
    @cart = current_cart
    @order = current_visitor.orders.build(current_visitor.slice(:name, :phone, :email))
  end

  def create
    @cart = checkout_cart
    checkout = Checkout.new(cart: @cart, visitor: current_visitor, attributes: checkout_params)
    if checkout.call
      redirect_to success_checkout_path(checkout.order.number)
    else
      @order = checkout.order
      render :new, status: :unprocessable_content
    end
  end

  def success
    @order = current_visitor.orders.find_by!(number: params[:number])
  end

  private

  def checkout_params
    params.expect(order: %i[name phone email comment payment_method])
  end

  def checkout_cart
    current_visitor.carts.find_by(id: params.dig(:order, :cart_id)) || current_cart
  end
end
