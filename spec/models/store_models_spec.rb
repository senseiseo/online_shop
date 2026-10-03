require "rails_helper"

# rubocop:disable RSpec/DescribeClass, RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe "store models" do
  it "enforces a single active cart per visitor" do
    visitor = create(:visitor)
    create(:cart, visitor: visitor)

    expect(build(:cart, visitor: visitor)).to be_valid
    expect { create(:cart, visitor: visitor) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "allows a new active cart after conversion" do
    cart = create(:cart)
    cart.converted!

    expect(create(:cart, visitor: cart.visitor)).to be_active
  end

  it "finds or creates one active cart for a visitor" do
    visitor = create(:visitor)

    expect { visitor.find_or_create_active_cart }.to change(Cart, :count).by(1)
    expect(visitor.find_or_create_active_cart).to eq(visitor.active_cart)
  end

  it "creates a new active cart after the current cart is converted" do
    visitor = create(:visitor)
    converted_cart = visitor.find_or_create_active_cart
    converted_cart.converted!

    expect { visitor.find_or_create_active_cart }.to change(Cart, :count).by(1)
    expect(visitor.find_or_create_active_cart).to be_active
    expect(visitor.carts.converted).to contain_exactly(converted_cart)
  end

  it "recovers when another request creates the active cart first" do
    visitor = create(:visitor)
    racing_visitor = Visitor.find(visitor.id)
    expect(racing_visitor.active_cart).to be_nil
    cart = visitor.carts.create!

    expect(racing_visitor.find_or_create_active_cart).to eq(cart)
  end

  it "persists cart items while allowing quantity changes and removal" do
    item = create(:cart_item, quantity: 1)

    item.update!(quantity: 2)
    expect(item.reload.quantity).to eq(2)

    expect { item.destroy! }.to change(CartItem, :count).by(-1)
  end

  it "requires positive cart item quantities and one item per product" do
    item = build(:cart_item, quantity: 0)

    expect(item).not_to be_valid
    expect(item.errors[:quantity]).to be_present

    existing = create(:cart_item)
    duplicate = build(:cart_item, cart: existing.cart, product: existing.product)
    expect(duplicate).not_to be_valid
  end

  it "uses integer cents and rejects negative amounts" do
    expect(build(:product, price_cents: -1)).not_to be_valid
    expect(build(:order_item, unit_price_cents: -1)).not_to be_valid
    expect(build(:order, total_price_cents: -1)).not_to be_valid
  end

  it "keeps order item snapshots when the product changes" do
    product = create(:product, name: "Table", price_cents: 100_000)
    item = create(:order_item, product: product, product_name: product.name, unit_price_cents: product.price_cents,
      total_price_cents: product.price_cents)

    product.update!(name: "New table", price_cents: 200_000)
    item.reload

    expect(item).to have_attributes(product_name: "Table", unit_price_cents: 100_000, total_price_cents: 100_000)
  end

  it "requires an order name and usable contact" do
    order = build(:order, name: nil, phone: nil, email: nil)

    expect(order).not_to be_valid
    expect(order.errors[:name]).to be_present
    expect(order.errors[:base]).to include("phone or email is required")
  end

  it "defines order payment and lifecycle enums" do
    expect(Order.statuses).to eq("new" => 0, "confirmed" => 1, "processing" => 2, "ready" => 3, "completed" => 4, "cancelled" => 5)
    expect(Order.payment_methods).to eq("cash" => 0, "card_on_pickup" => 1, "transfer" => 2)
    expect(Order.payment_statuses).to eq("unpaid" => 0, "paid" => 1)
  end

  it "requires inquiry contact and message" do
    inquiry = build(:inquiry, phone: nil, email: nil, message: nil)

    expect(inquiry).not_to be_valid
    expect(inquiry.errors[:message]).to be_present
    expect(inquiry.errors[:base]).to include("phone or email is required")
  end

  it "normalizes contact emails" do
    expect(build(:visitor, email: " CUSTOMER@EXAMPLE.COM ").email).to eq("customer@example.com")
    expect(build(:order, phone: nil, email: " CUSTOMER@EXAMPLE.COM ").email).to eq("customer@example.com")
  end
end
# rubocop:enable RSpec/DescribeClass, RSpec/ExampleLength, RSpec/MultipleExpectations
