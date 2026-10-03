class Visitor < ApplicationRecord
  has_many :carts, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception
  has_many :inquiries, dependent: :restrict_with_exception

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :token, presence: true, uniqueness: true
  validates :first_seen_at, :last_seen_at, presence: true
end
