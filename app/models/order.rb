class Order < ApplicationRecord
  self.primary_key = "order_id"  # Use your custom PK

  belongs_to :user, foreign_key: "user_id"
  has_many :order_items, foreign_key: "order_id", dependent: :destroy
  has_many :customizations, through: :order_items

  validates :status, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :calculate_totals_before_save

  def calculate_totals_before_save
    return if order_items.empty? || user.blank? || user.province.blank?

    calculate_totals(user.province)
  end

  def calculate_totals(province)
    self.subtotal = order_items.sum(&:line_total)

    # Store tax rates at time of order
    self.gst_rate = province.gst
    self.pst_rate = province.pst
    self.hst_rate = province.hst

    # Calculate tax amounts
    self.gst_amount = subtotal * (gst_rate / 100)
    self.pst_amount = subtotal * (pst_rate / 100)
    self.hst_amount = subtotal * (hst_rate / 100)

    self.total_price = subtotal + gst_amount + pst_amount + hst_amount
  end

  # 3.2.2 - Mark order as paid
  def mark_as_paid!(stripe_payment_id, stripe_customer_id)
    update!(
      status: "paid",
      stripe_payment_id: stripe_payment_id,
      stripe_customer_id: stripe_customer_id,
      paid_at: Time.current
    )
  end

  # 3.2.2 - Mark order as shipped
  def mark_as_shipped!
    update!(status: "shipped")
  end
end
