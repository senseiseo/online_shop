class Post < ApplicationRecord
  has_rich_text :content
  has_one_attached :cover

  extend FriendlyId
  friendly_id :title, use: :slugged

  scope :published, -> { where(published: true).where("published_at IS NULL OR published_at <= ?", Time.current).order(published_at: :desc, created_at: :desc) }

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true
end
