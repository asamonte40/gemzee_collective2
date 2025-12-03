class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :customizations, through: :order_items

  # required fields
  validates :status, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :calculate_totals_before_save

  # calculate totals before order is saved
  def calculate_totals_before_save
    return if order_items.empty? || user.blank? || user.province.blank?
    calculate_totals(user.province)
  end

  # central tax and total calculation
  def calculate_totals(province)
    # bubtotal
    self.subtotal = order_items.sum(&:line_total)

    # save the tax rates at time of purchase
    self.gst_rate = province.gst
    self.pst_rate = province.pst
    self.hst_rate = province.hst

    # tax amounts
    self.gst_amount = subtotal * (gst_rate / 100.0)
    self.pst_amount = subtotal * (pst_rate / 100.0)
    self.hst_amount = subtotal * (hst_rate / 100.0)

    # final total
    self.total_price = subtotal + gst_amount + pst_amount + hst_amount
  end

  # stripe: mark paid
  def mark_as_paid!(stripe_payment_id, stripe_customer_id)
    update!(
      status: "paid",
      stripe_payment_id: stripe_payment_id,
      stripe_customer_id: stripe_customer_id,
      paid_at: Time.current
    )
  end

  def mark_as_shipped!
    update!(status: "shipped")
  end

  # activeadmin searchable fields
  def self.ransackable_associations(_auth = nil)
    %w[order_items user]
  end

  def self.ransackable_attributes(_auth = nil)
    %w[id status subtotal gst_amount pst_amount hst_amount total_price created_at paid_at]
  end
end
