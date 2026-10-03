require "rails_helper"

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe "catalog and content" do
  let!(:category) { create(:category, name: "Furniture", slug: "furniture", published: true) }

  it "shows only published products in published categories" do
    visible = create(:product, category: category, name: "Visible table", slug: "visible-table", published: true)
    hidden = create(:product, category: category, name: "Hidden table", slug: "hidden-table")
    hidden_category = create(:category, published: false)
    hidden_by_category = create(:product, category: hidden_category, name: "Hidden chair", slug: "hidden-chair", published: true)

    get catalog_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(visible.name)
    expect(response.body).not_to include(hidden.name, hidden_by_category.name)
  end

  it "filters and sorts the catalog using published category slugs" do
    cheap = create(:product, category: category, name: "Cheap table", slug: "cheap-table", published: true, price_cents: 10_000)
    expensive = create(:product, category: category, name: "Expensive table", slug: "expensive-table", published: true, price_cents: 20_000)

    get catalog_path, params: { category: category.slug, sort: "price_desc" }

    expect(response).to have_http_status(:ok)
    expect(response.body.index(expensive.name)).to be < response.body.index(cheap.name)
  end

  it "sorts prices globally, regardless of category position" do
    first_category = create(:category, name: "First", slug: "first", published: true, position: 0)
    cheap = create(:product, category: category, name: "Cheap table", slug: "cheap-table", published: true, price_cents: 10_000)
    expensive = create(:product, category: first_category, name: "Expensive table", slug: "expensive-table", published: true, price_cents: 20_000)

    get catalog_path, params: { sort: "price_desc" }

    expect(response).to have_http_status(:ok)
    expect(response.body.index(expensive.name)).to be < response.body.index(cheap.name)
  end

  it "paginates the catalog" do
    21.times { |index| create(:product, category: category, name: "Table #{index}", slug: "table-#{index}", published: true) }

    get catalog_path, params: { page: 2 }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Table 9")
    expect(response.body).to include('sm:grid-cols-2', 'lg:grid-cols-3', '<label class="sr-only" for="category">Категория</label>', '<nav class="pagy series-nav" aria-label="Pages">')
  end

  it "uses slugs for product and category routes and excludes unpublished records" do
    product = create(:product, category: category, name: "Oak table", slug: "oak-table", published: true)
    hidden = create(:product, category: category, slug: "draft-table")

    get product_path(product)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Oak table")

    get category_path(category)
    expect(response).to have_http_status(:ok)

    get product_path(hidden)
    expect(response).to have_http_status(:not_found)
  end

  it "renders attached product images and rich text" do
    product = create(:product, category: category, name: "Lamp", slug: "lamp", published: true)
    product.images.attach(io: StringIO.new("image"), filename: "lamp.png", content_type: "image/png")
    product.update!(description: "<p>Handmade lamp</p>")

    get product_path(product)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Handmade lamp", "lamp.png")
  end

  it "shows only published posts and their slug route" do
    post = create(:post, title: "Choosing a table", slug: "choosing-a-table", published: true, published_at: 1.day.ago)
    create(:post, title: "Draft", slug: "draft", published: false, published_at: 1.day.ago)
    create(:post, title: "Future", slug: "future", published: true, published_at: 1.day.from_now)

    get posts_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(post.title)
    expect(response.body).not_to include("Draft", "Future")

    get post_path(post)
    expect(response).to have_http_status(:ok)
  end

  it "creates an inquiry for the anonymous visitor" do
    expect do
      post inquiries_path, params: { inquiry: { name: "Jane", phone: "+79990000000", message: "Please call" } }
    end.to change(Inquiry, :count).by(1)

    expect(response).to redirect_to(root_path)
    expect(Inquiry.last).to have_attributes(name: "Jane", message: "Please call")
    expect(Inquiry.last.visitor).to be_present
    expect(Inquiry.last.visitor).to have_attributes(name: "Jane", phone: "+79990000000")
  end

  it "transliterates Cyrillic names into FriendlyId slugs" do
    russian_category = create(:category, name: "Мебель", slug: nil)
    russian_product = create(:product, category: russian_category, name: "Деревянный стол", slug: nil)
    russian_post = create(:post, title: "Как выбрать стол", slug: nil)

    expect(russian_category.slug).to eq("mebel")
    expect(russian_product.slug).to eq("derevyannyy-stol")
    expect(russian_post.slug).to eq("kak-vybrat-stol")
  end

  it "renders inquiry validation errors" do
    post inquiries_path, params: { inquiry: { name: "Jane", message: "Please call" } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("phone or email is required")
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
