require "rails_helper"

# The authorization matrix and each export format are one regression scenario.
# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations

RSpec.describe "Admin resources", type: :request do
  let(:admin) { create(:user, password: "password123") }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end

  it "lets a manager edit and update orders and inquiries without create or destroy access" do
    manager = create(:user, :manager, password: "password123")
    order = create(:order)
    inquiry = create(:inquiry)
    sign_in(manager)

    get edit_admin_order_path(order)
    expect(response).to have_http_status(:success)
    patch admin_order_path(order), params: { order: { status: :confirmed } }
    expect(order.reload).to be_confirmed

    get edit_admin_inquiry_path(inquiry)
    expect(response).to have_http_status(:success)
    patch admin_inquiry_path(inquiry), params: { inquiry: { status: :read } }
    expect(inquiry.reload).to be_read

    post admin_orders_path, params: { order: {} }
    expect(response).to have_http_status(:not_found)
  end

  it "never exports visitor tokens or password digests" do
    visitor = create(:visitor, token: "private-visitor-token")
    user = admin
    sign_in(user)

    %w[csv json xml].each do |format|
      get admin_visitors_path(format: format)
      expect(response.body).not_to include(visitor.token)

      get admin_users_path(format: format)
      expect(response.body).not_to include(user.password_digest)
    end

    get admin_user_path(user)
    expect(response.body).not_to include(user.password_digest)
  end

  it "keeps product images when updating ordinary fields and saves its rich text" do
    product = create(:product)
    product.images.attach(io: StringIO.new("image"), filename: "product.jpg", content_type: "image/jpeg")
    sign_in(admin)

    patch admin_product_path(product), params: { product: { name: "Renamed", description: "Full description", images: [ "" ] } }

    expect(response).to redirect_to(admin_product_path(product))
    expect(product.reload.images).to be_attached
    expect(product.description.to_plain_text).to eq("Full description")
  end

  it "renders and saves native Action Text editors for posts" do
    sign_in(admin)

    get new_admin_post_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("trix-editor")

    post admin_posts_path, params: { post: { title: "New post", slug: "new-post", content: "Created post" } }
    post = Post.find_by!(slug: "new-post")
    expect(response).to redirect_to(admin_post_path(post))
    expect(post.content.to_plain_text).to eq("Created post")

    get edit_admin_post_path(post)
    expect(response).to have_http_status(:success)
    expect(response.body).to include("trix-editor")

    patch admin_post_path(post), params: { post: { content: "Updated post" } }
    expect(response).to redirect_to(admin_post_path(post))
    expect(post.reload.content.to_plain_text).to eq("Updated post")
  end

  it "does not show order or inquiry data to an editor on the dashboard" do
    order = create(:order, number: "private-order", name: "Private customer")
    inquiry = create(:inquiry, message: "Private inquiry")
    editor = create(:user, :editor, password: "password123")
    sign_in(editor)

    get admin_root_path

    expect(response).to have_http_status(:success)
    expect(response.body).not_to include(order.number, order.name, inquiry.message, "Выручка по оплаченным заказам", "Активные корзины")
  end

  it "renders the ActiveAdmin interface in Russian" do
    sign_in(admin)

    get admin_products_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Товары", "Фильтровать", "Название", "Интернет-магазин")
  end

  it "deletes empty categories and posts but keeps categories with products" do
    empty_category = create(:category)
    used_category = create(:category)
    create(:product, category: used_category)
    post = create(:post)
    sign_in(admin)

    delete remove_admin_category_path(empty_category)
    expect(Category.where(id: empty_category.id)).to be_empty

    delete remove_admin_category_path(used_category)
    expect(response).to redirect_to(admin_category_path(used_category))
    expect(Category.where(id: used_category.id)).to exist

    delete remove_admin_post_path(post)
    expect(Post.where(id: post.id)).to be_empty
  end

  it "keeps products used in carts or orders" do
    cart_product = create(:product)
    order_product = create(:product)
    create(:cart_item, product: cart_product)
    create(:order_item, product: order_product)
    sign_in(admin)

    [ cart_product, order_product ].each do |product|
      delete remove_admin_product_path(product)
      expect(response).to redirect_to(admin_product_path(product))
      expect(Product.where(id: product.id)).to exist
    end
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
