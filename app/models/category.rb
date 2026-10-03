class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_exception

  extend FriendlyId
  friendly_id :name, use: :slugged

  scope :published, -> { where(published: true).order(:position, :name) }

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
