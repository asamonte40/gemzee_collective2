class OrderItem < ApplicationRecord
  self.primary_key = "orderitem_id"

  # Associations
  belongs_to :order, foreign_key: "order_id"
  belongs_to :product, foreign_key: "product_id"
  has_many :customizations, foreign_key: "orderitem_id", dependent: :destroy

  # Validations
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_at_purchase, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_name, presence: true
  validates :product_description, presence: true

  # Callbacks
  before_validation :set_denormalized_data

  # Denormalize product info for historical record
  def set_denormalized_data
    return unless product.present?

    self.price_at_purchase ||= product.price
    self.product_name ||= product.name
    self.product_description ||= product.description
  end

  # Convenience method for subtotal of this item
  def line_total
    price_at_purchase * quantity
  end
end
