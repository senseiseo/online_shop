FactoryBot.define do
  factory :visitor do
    sequence(:token) { |n| "visitor-token-#{n}" }
    first_seen_at { Time.current }
    last_seen_at { Time.current }
  end

  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    sequence(:slug) { |n| "category-#{n}" }
  end

  factory :product do
    category
    sequence(:name) { |n| "Product #{n}" }
    sequence(:slug) { |n| "product-#{n}" }
    price_cents { 100_000 }
  end

  factory :cart do
    visitor
  end

  factory :cart_item do
    cart
    product
    quantity { 1 }
  end

  factory :order do
    visitor
    cart { association(:cart, visitor: visitor, status: :converted) }
    sequence(:number) { |n| "20261003-#{n.to_s.rjust(5, '0')}" }
    name { "Customer" }
    phone { "+79990000000" }
    total_price_cents { 100_000 }
  end

  factory :order_item do
    order
    product
    product_name { product.name }
    unit_price_cents { product.price_cents }
    quantity { 1 }
    total_price_cents { unit_price_cents * quantity }
  end

  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    sequence(:slug) { |n| "post-#{n}" }
  end

  factory :inquiry do
    visitor
    name { "Customer" }
    phone { "+79990000000" }
    message { "Please contact me" }
  end
end
