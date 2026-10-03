class Visitor < ApplicationRecord
  has_many :carts, dependent: :restrict_with_exception
  has_one :active_cart, -> { active }, class_name: "Cart"
  has_many :orders, dependent: :restrict_with_exception
  has_many :inquiries, dependent: :restrict_with_exception

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :token, presence: true, uniqueness: true
  validates :first_seen_at, :last_seen_at, presence: true

  def self.create_with_token!
    loop do
      now = Time.current
      visitor = new(token: SecureRandom.urlsafe_base64(32), first_seen_at: now, last_seen_at: now)
      visitor.save!
      return visitor
    rescue ActiveRecord::RecordNotUnique
      # A token collision is safe to retry; the unique index remains authoritative.
    end
  end

  def find_or_create_active_cart
    carts.active.first || carts.create!
  rescue ActiveRecord::RecordNotUnique
    carts.active.first!
  end
end
