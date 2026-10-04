class Checkout
  class UnavailableCart < StandardError; end

  attr_reader :order

  def initialize(cart:, visitor:, attributes:)
    @cart = cart
    @visitor = visitor
    @attributes = attributes
    @order = Order.new(attributes)
  end

  def call
    Cart.transaction(requires_new: true) do
      @cart.lock!
      return true if existing_order

      items = CartItem.where(cart: @cart).to_a
      raise UnavailableCart, "Your cart is empty." if items.empty?

      products = Product.visible.where(id: items.map(&:product_id)).index_by(&:id)
      raise UnavailableCart, "Some items are no longer available." unless products.size == items.size

      total = items.sum { |item| products.fetch(item.product_id).price_cents * item.quantity }
      @order = @visitor.orders.create!(attributes.merge(cart: @cart, number: Order.next_number, total_price_cents: total))
      items.each do |item|
        product = products.fetch(item.product_id)
        @order.order_items.create!(product: product, product_name: product.name, unit_price_cents: product.price_cents,
          quantity: item.quantity, total_price_cents: product.price_cents * item.quantity)
      end
      @visitor.update!(attributes.slice(:name, :phone, :email).compact_blank)
      @cart.converted!
    end
    true
  rescue ActiveRecord::RecordInvalid => error
    @order = error.record
    false
  rescue UnavailableCart => error
    @order.errors.add(:base, error.message)
    false
  rescue ActiveRecord::RecordNotUnique
    existing_order || raise
  end

  private

  attr_reader :attributes

  def existing_order
    existing_order = @cart.reload.order
    @order = existing_order if existing_order
    existing_order.present?
  end
end
