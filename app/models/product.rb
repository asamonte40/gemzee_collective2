class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :order_items
  has_many :products_categories, dependent: :destroy
  has_many :categories, through: :products_categories

  has_many :products_tags, dependent: :destroy
  has_many :tags, through: :products_tags

  # ActiveStorage attachments
  has_one_attached :image

  # Validations
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :on_sale, -> { where(on_sale: true) }
  scope :new_products, -> { where(is_new: true) }
  scope :recently_updated, -> { where("updated_at > ?", 7.days.ago) }

  # Ransack (ActiveAdmin search)
  def self.ransackable_attributes(auth_object = nil)
    %w[name price created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[categories tags]
  end

  def thumbnail
    image.variant(resize_to_limit: [ 150, 150 ])
  end

  def medium
    image.variant(resize_to_limit: [ 600, 600 ])
  end

  def large
    image.variant(resize_to_limit: [ 1200, 1200 ])
  end
end
