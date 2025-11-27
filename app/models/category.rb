class Category < ApplicationRecord
  has_many :products, dependent: :nullify

  # Allow Ransack to search/filter on this association
  def self.ransackable_associations(auth_object = nil)
    [ "products" ]
  end

  # Optional: if you want to also allow certain attributes for searching
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "name", "created_at", "updated_at" ]
  end

  validates :name, presence: true, uniqueness: true
end
