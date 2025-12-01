class Page < ApplicationRecord
  validates :title, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers, and dashes" }
  validates :content, presence: true

  # CALLBACK
  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug = title.parameterize if slug.blank? && title.present?
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id title content slug created_at updated_at]
  end
end
