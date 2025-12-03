class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Status values
  STATUSES = %w[pending paid shipped delivered cancelled].freeze

  # Validations
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stripe_payment_id, uniqueness: true, allow_nil: true

  # Callbacks
  before_validation :calculate_totals, if: -> { order_items.any? && user&.province.present? }

  # Calculate subtotal, taxes, and total
  def calculate_totals
    self.subtotal = order_items.sum { |item| item.price_at_purchase * item.quantity }

    self.gst_rate = user.province.gst
    self.pst_rate = user.province.pst
    self.hst_rate = user.province.hst

    self.gst_amount = subtotal * (gst_rate / 100.0)
    self.pst_amount = subtotal * (pst_rate / 100.0)
    self.hst_amount = subtotal * (hst_rate / 100.0)

    self.total = subtotal + gst_amount + pst_amount + hst_amount
  end

  # Stripe: mark paid
  def mark_as_paid!(stripe_payment_id:, stripe_customer_id:)
    update!(
      status: "paid",
      stripe_payment_id: stripe_payment_id,
      stripe_customer_id: stripe_customer_id,
      paid_at: Time.current
    )
  end

  # Mark shipped
  def mark_as_shipped!
    update!(status: "shipped")
  end

  # Helper methods
  STATUSES.each do |s|
    define_method("#{s}?") { status == s }
  end

  # ActiveAdmin / Ransack search
  def self.ransackable_associations(_auth = nil)
    %w[order_items user products]
  end

  def self.ransackable_attributes(_auth = nil)
    %w[id status subtotal gst_amount pst_amount hst_amount total created_at paid_at stripe_payment_id]
  end
end
