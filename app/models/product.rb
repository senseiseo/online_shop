class Product < ApplicationRecord
  belongs_to :category
  has_many :cart_items, dependent: :restrict_with_exception
  has_many :order_items, dependent: :restrict_with_exception

  has_rich_text :description
  has_many_attached :images

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :old_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
