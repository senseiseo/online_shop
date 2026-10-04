class SeoController < ApplicationController
  allow_unauthenticated_access

  def robots
    render plain: "User-agent: *\nAllow: /\nSitemap: #{request.base_url}/sitemap.xml\n", content_type: "text/plain"
  end

  def sitemap
    @records = [ [ root_url, nil ], [ catalog_url, nil ], [ posts_url, nil ] ] +
      Category.published.map { |category| [ category_url(category), category.updated_at ] } +
      Product.visible.map { |product| [ product_url(product), product.updated_at ] } +
      Post.published.map { |post| [ post_url(post), post.updated_at ] }
    render formats: :xml
  end
end
