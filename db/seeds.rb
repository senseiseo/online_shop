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

  product_images = %w[side-table.jpg table-lamp.jpg ceramic-vase.jpg].map do |filename|
    Rails.root.join("db", "seed_assets", "products", filename)
  end

  10.times do |index|
    category = categories[index % categories.size]
    product = Product.find_or_create_by!(slug: "sample-product-#{index + 1}") do |item|
      item.category = category
      item.name = "Sample product #{index + 1}"
      item.short_description = "Development catalog product #{index + 1}"
      item.price_cents = (index + 1) * 10_000
      item.published = true
      item.featured = index < 3
      item.position = index
    end

    unless product.images.attached?
      image_path = product_images[index % product_images.length]
      File.open(image_path, "rb") do |file|
        product.images.attach(io: file, filename: image_path.basename.to_s, content_type: "image/jpeg")
      end
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
