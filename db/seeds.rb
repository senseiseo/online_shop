# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development?
  User.find_or_initialize_by(email_address: "admin@example.test").tap do |user|
    user.password = "password123"
    user.role = :admin
    user.save!
  end

  categories = [ "Furniture", "Lighting", "Decor" ].map.with_index do |name, position|
    Category.find_or_create_by!(slug: name.parameterize) do |category|
      category.name = name
      category.position = position
      category.published = true
    end
  end

  10.times do |index|
    category = categories[index % categories.size]
    Product.find_or_create_by!(slug: "sample-product-#{index + 1}") do |product|
      product.category = category
      product.name = "Sample product #{index + 1}"
      product.short_description = "Development catalog product #{index + 1}"
      product.price_cents = (index + 1) * 10_000
      product.published = true
      product.featured = index < 3
      product.position = index
    end
  end

  3.times do |index|
    Post.find_or_create_by!(slug: "sample-post-#{index + 1}") do |post|
      post.title = "Sample post #{index + 1}"
      post.excerpt = "Development post #{index + 1}"
      post.published = true
      post.published_at = Time.current
    end
  end
end
