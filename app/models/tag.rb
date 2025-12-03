class Tag < ApplicationRecord
  has_many :products_tags, dependent: :destroy
  has_many :products, through: :products_tags

  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at]
  end

  # Optionally, allowlist associations if you want nested searches
  def self.ransackable_associations(auth_object = nil)
    %w[products]
  end
end
