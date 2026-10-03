class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { admin: 0, editor: 1, manager: 2 }, default: :admin, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
