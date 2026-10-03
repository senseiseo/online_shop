class Cart < ApplicationRecord
  belongs_to :visitor
  has_many :cart_items, dependent: :destroy
  has_one :order, dependent: :restrict_with_exception

  enum :status, { active: 0, converted: 1, abandoned: 2 }, default: :active, validate: true
end
