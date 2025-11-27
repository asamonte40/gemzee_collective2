# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'faker'
require 'csv'
require 'open-uri'

# Clear old data
OrderItem.destroy_all
Order.destroy_all
Product.destroy_all
Category.destroy_all
User.destroy_all

# Users
User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  admin: true
)

5.times do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "password",
    password_confirmation: "password",
    admin: false
  )
end

# Categories
categories = [ "Necklaces", "Earrings", "Rings", "Bracelets" ].map do |name|
  Category.find_or_create_by!(name: name)
end

# Faker products
100.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.sentence(word_count: 10),
    price: Faker::Commerce.price(range: 10..500.0),
    stock_quantity: rand(1..50),
    category: categories.sample
  )
end

# CSV import
csv_file_path = Rails.root.join("db/data/cartier_catalog.csv")

CSV.foreach(csv_file_path, headers: true) do |row|
  category = Category.find_or_create_by!(name: row["category"].presence || "Uncategorized")

  product = Product.create!(
    name: row["name"].presence || "Unnamed Product",
    description: row["description"].presence || "No description",
    price: row["price"].to_f,
    stock_quantity: rand(1..50),
    category: category
  )

  next unless row["image"].present?

  begin
    # Build full URL
    image_url = "https://www.cartier.com#{row['image']}"
    file = URI.open(image_url)

    product.image.attach(
      io: file,
      filename: File.basename(image_url)
      # content_type is optional; Rails will usually detect it automatically
    )

    puts "✅ Attached image for #{product.name}"

  rescue => e
    puts "⚠ Failed attaching image for #{product.name}: #{e.message}"
  end
end
