class Province < ApplicationRecord
  has_many :users

  validates :name, presence: true
  validates :code, presence: true, length: { is: 2 }
  validates :gst, :pst, :hst, numericality: { greater_than_or_equal_to: 0 }

  # method to get total tax rate
  def total_tax_rate
    gst + pst + hst
  end
end
