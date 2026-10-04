class CartsController < ApplicationController
  allow_unauthenticated_access

  def show
    @cart = current_cart
  end
end
