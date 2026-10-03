class Post < ApplicationRecord
  has_rich_text :content
  has_one_attached :cover

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true
end
