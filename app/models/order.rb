class Order < ApplicationRecord
  belongs_to :visitor
  belongs_to :cart
  has_many :order_items, dependent: :restrict_with_exception

  enum :status, { new: 0, confirmed: 1, processing: 2, ready: 3, completed: 4, cancelled: 5 }, default: :new, validate: true, scopes: false
  enum :payment_method, { cash: 0, card_on_pickup: 1, transfer: 2 }, default: :cash, validate: true
  enum :payment_status, { unpaid: 0, paid: 1 }, default: :unpaid, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :number, :name, presence: true
  validates :number, uniqueness: true
  validates :total_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :contact_present

  private

  def contact_present
    errors.add(:base, "phone or email is required") if phone.blank? && email.blank?
  end
end
