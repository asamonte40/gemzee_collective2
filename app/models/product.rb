class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :order_items

  # ActiveStorage attachments
  has_one_attached :image

  # Validations
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Ransack (ActiveAdmin search)
  def self.ransackable_attributes(auth_object = nil)
    %w[name price created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category]
  end
end
