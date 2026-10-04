require "rails_helper"
require "base64"

RSpec.describe "Storefront UI and SEO", type: :request do
  let!(:category) { create(:category, published: true) }
  let!(:product) { create(:product, category:, published: true) }

  it "renders page metadata with an absolute OpenGraph image URL" do
    product.images.attach(io: StringIO.new(Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLh0QAAAABJRU5ErkJggg==")), filename: "product.png", content_type: "image/png")

    get product_path(product)
    expect(response.body).to include('<meta name="description"', '<link rel="canonical"', 'property="og:title"').and match(%r{property="og:image" content="https?://[^\"]+"})
  end

  it "renders an absolute OpenGraph image URL for a post cover" do
    post = create(:post, published: true, published_at: Time.current)
    post.cover.attach(io: StringIO.new(Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLh0QAAAABJRU5ErkJggg==")), filename: "cover.png", content_type: "image/png")

    get post_path(post)

    expect(response.body).to match(%r{property="og:image" content="https?://[^\"]+"})
  end

  it "publishes robots" do
    get "/robots.txt"
    expect(response.body).to include("Sitemap:")
  end

  it "publishes public sitemap entries" do
    get "/sitemap.xml"
    expect(response.body).to include(product_url(product), catalog_url)
  end
end
