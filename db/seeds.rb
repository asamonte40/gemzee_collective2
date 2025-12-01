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
Province.destroy_all

provinces_data = [
  { name: 'Alberta', code: 'AB', gst: 5.0, pst: 0.0, hst: 0.0 },
  { name: 'British Columbia', code: 'BC', gst: 5.0, pst: 7.0, hst: 0.0 },
  { name: 'Manitoba', code: 'MB', gst: 5.0, pst: 7.0, hst: 0.0 },
  { name: 'New Brunswick', code: 'NB', gst: 0.0, pst: 0.0, hst: 15.0 },
  { name: 'Newfoundland and Labrador', code: 'NL', gst: 0.0, pst: 0.0, hst: 15.0 },
  { name: 'Northwest Territories', code: 'NT', gst: 5.0, pst: 0.0, hst: 0.0 },
  { name: 'Nova Scotia', code: 'NS', gst: 0.0, pst: 0.0, hst: 15.0 },
  { name: 'Nunavut', code: 'NU', gst: 5.0, pst: 0.0, hst: 0.0 },
  { name: 'Ontario', code: 'ON', gst: 0.0, pst: 0.0, hst: 13.0 },
  { name: 'Prince Edward Island', code: 'PE', gst: 0.0, pst: 0.0, hst: 15.0 },
  { name: 'Quebec', code: 'QC', gst: 5.0, pst: 9.975, hst: 0.0 },
  { name: 'Saskatchewan', code: 'SK', gst: 5.0, pst: 6.0, hst: 0.0 },
  { name: 'Yukon', code: 'YT', gst: 5.0, pst: 0.0, hst: 0.0 }
]

provinces_data.each { |p| Province.create!(p) }
puts "Created #{Province.count} provinces"

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

Page.find_or_create_by!(slug: "about") do |p|
  p.title = "About Gemzee Collective"
  p.content = <<~HTML
    <p>Welcome to <strong>Gemzee Collective</strong>, your destination for curated, high-quality products online.</p>
    <p>Our mission is to connect you with unique, artisan-crafted items that brighten your day and enrich your lifestyle.</p>
    <p>From jewelry to home decor, every product is carefully selected for its quality, design, and story.</p>
  HTML
end

Page.find_or_create_by!(slug: "contact") do |p|
  p.title = "Contact Gemzee Collective"
  p.content = <<~HTML
    <p>We’d love to hear from you! Please reach out to us with any questions, comments, or feedback.</p>
    <ul>
      <li>Email: <a href="">gemzeecollective@gmail.com</a></li>
      <li>Phone: (204) 555-1234</li>
      <li>Address: 123 Artisan Lane, Winnipeg, MB</li>
    </ul>
    <p>Our team is committed to responding within 24-48 hours during business days.</p>
  HTML
end


# CSV import
csv_file_path = Rails.root.join("db/data/cartier_catalog.csv")

CSV.foreach(csv_file_path, headers: true) do |row|
  # FIXED: use CSV column "categorie"
  category = Category.find_or_create_by!(
    name: row["categorie"].presence || "Uncategorized"
  )

  product = Product.create!(
    name: row["title"].presence || "Unnamed Product",
    description: row["description"].presence || "No description available",
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
    puts "Failed attaching image for #{product.name}: #{e.message}"
  end
end
