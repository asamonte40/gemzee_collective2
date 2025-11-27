class Order < ApplicationRecord
  self.primary_key = "order_id"  # Use your custom PK

  belongs_to :user, foreign_key: "user_id"
  has_many :order_items, foreign_key: "order_id", dependent: :destroy
  has_many :customizations, through: :order_items

  validates :status, presence: true
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
