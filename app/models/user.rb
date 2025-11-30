class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, foreign_key: "user_id", dependent: :destroy
  belongs_to :province, optional: true

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def full_address
    return nil unless address.present?
    "#{address}, #{city}, #{province&.code} #{postal_code}"
  end
end
