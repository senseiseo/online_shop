require "rails_helper"

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe "Checkout", type: :request do
  let!(:category) { create(:category, published: true) }
  let!(:product) { create(:product, category: category, published: true, price_cents: 100_000) }

  def cart
    get root_path
    Visitor.last.find_or_create_active_cart
  end

  it "creates a server-priced order, snapshots it, converts its cart, and updates the visitor" do
    create(:cart_item, cart: cart, product: product, quantity: 2)

    expect do
      post checkout_path, params: { order: { name: "Jane", phone: "+79990000000", payment_method: "transfer", price: 1, total: 1 } }
    end.to change(Order, :count).by(1).and change(OrderItem, :count).by(1)

    order = Order.last
    expect(response).to redirect_to(success_checkout_path(order.number))
    expect(order).to have_attributes(total_price_cents: 200_000, name: "Jane", payment_method: "transfer")
    expect(order.order_items.first).to have_attributes(product_name: product.name, unit_price_cents: 100_000, quantity: 2, total_price_cents: 200_000)
    expect(order.cart).to be_converted
    expect(order.visitor).to have_attributes(name: "Jane", phone: "+79990000000")

    product.update!(name: "Changed", price_cents: 200_000)
    expect(order.order_items.first.reload).to have_attributes(product_name: product.name_before_last_save, unit_price_cents: 100_000)
    expect(order.visitor.find_or_create_active_cart).to be_active

    expect do
      post checkout_path, params: { order: { cart_id: order.cart_id, name: "Jane", phone: "+79990000000", payment_method: "transfer" } }
    end.not_to change(Order, :count)
    expect(response).to redirect_to(success_checkout_path(order.number))
  end

  it "does not create a partial order for an empty or unavailable cart" do
    cart

    expect { post checkout_path, params: { order: { name: "Jane", email: "jane@example.com" } } }.not_to change(Order, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Your cart is empty.")

    create(:cart_item, cart: Visitor.last.find_or_create_active_cart, product: product)
    product.update!(published: false)

    expect { post checkout_path, params: { order: { name: "Jane", email: "jane@example.com" } } }.not_to change(Order, :count)
    expect(Visitor.last.find_or_create_active_cart).to be_active
    expect(response.body).to include("Some items are no longer available.")
  end

  it "rejects invalid contact details and only lets its visitor view the success page" do
    create(:cart_item, cart: cart, product: product)

    expect { post checkout_path, params: { order: { name: "Jane" } } }.not_to change(Order, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("phone or email is required")
    expect(Visitor.last.find_or_create_active_cart).to be_active

    post checkout_path, params: { order: { name: "Jane", email: "jane@example.com" } }
    order = Order.last
    get success_checkout_path(order.number)
    expect(response).to have_http_status(:ok)

    reset!
    get success_checkout_path(order.number)
    expect(response).to have_http_status(:not_found)
  end

  it "rolls back the order, items, cart, and visitor contacts when checkout fails after item creation" do
    create(:cart_item, cart: cart, product: product)
    visitor = Visitor.last
    allow(Visitor).to receive(:find_by).with(token: visitor.token).and_return(visitor)
    allow(visitor).to receive(:update!).and_raise(ActiveRecord::StatementInvalid, "forced failure")
    order_count = Order.count
    item_count = OrderItem.count

    expect do
      post checkout_path, params: { order: { cart_id: cart.id, name: "Jane", email: "jane@example.com" } }
    end.to raise_error(ActiveRecord::StatementInvalid, "forced failure")

    expect(visitor).to have_received(:update!)
    expect(Order.count).to eq(order_count)
    expect(OrderItem.count).to eq(item_count)
    expect(cart.reload).to be_active
    expect(visitor.reload).to have_attributes(name: nil, email: nil)
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
