class OrderItem < ApplicationRecord
  self.primary_key = "orderitem_id"

  belongs_to :order, foreign_key: "order_id"
  belongs_to :product, foreign_key: "product_id"
  has_many :customizations, foreign_key: "orderitem_id", dependent: :destroy

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_at_purchase, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def line_total
    price_at_purchase * quantity
  end
end
