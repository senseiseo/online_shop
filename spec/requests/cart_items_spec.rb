# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe "Cart items", type: :request do
  let!(:product) { create(:product, category: create(:category, published: true), published: true) }
  let(:turbo_headers) { { "ACCEPT" => Mime[:turbo_stream].to_s } }

  it "adds a product and increments its existing item" do
    post cart_items_path, params: { cart_item: { product_id: product.id } }, headers: turbo_headers

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('target="cart_counter"', 'target="cart"')
    expect(Visitor.last.active_cart.cart_items.find_by!(product:).quantity).to eq(1)

    post cart_items_path, params: { cart_item: { product_id: product.id } }, headers: turbo_headers

    expect(Visitor.last.active_cart.cart_items.find_by!(product:).quantity).to eq(2)
  end

  it "updates, removes at zero, and destroys cart items" do
    post cart_items_path, params: { cart_item: { product_id: product.id } }, headers: turbo_headers
    item = Visitor.last.active_cart.cart_items.find_by!(product:)

    patch cart_item_path(item), params: { cart_item: { quantity: "3" } }, headers: turbo_headers

    expect([ response, item.reload.quantity ]).to match([ have_http_status(:ok), 3 ])

    patch cart_item_path(item), params: { cart_item: { quantity: "0" } }, headers: turbo_headers

    expect([ response, CartItem.exists?(item.id) ]).to match([ have_http_status(:ok), false ])

    post cart_items_path, params: { cart_item: { product_id: product.id } }, headers: turbo_headers
    item = Visitor.last.active_cart.cart_items.find_by!(product:)
    delete cart_item_path(item), headers: turbo_headers

    expect([ response, CartItem.exists?(item.id) ]).to match([ have_http_status(:ok), false ])
  end

  it "rejects invalid quantities without changing the item" do
    post cart_items_path, params: { cart_item: { product_id: product.id } }, headers: turbo_headers
    item = Visitor.last.active_cart.cart_items.find_by!(product:)

    [ "1.5", "abc", "-1" ].each do |quantity|
      patch cart_item_path(item), params: { cart_item: { quantity: } }

      expect([ response.status, item.reload.quantity ]).to eq([ 422, 1 ])
    end
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
