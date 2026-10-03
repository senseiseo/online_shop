class Inquiry < ApplicationRecord
  belongs_to :visitor

  enum :status, { new: 0, read: 1, answered: 2, closed: 3 }, default: :new, validate: true, scopes: false

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :contact_present

  private

  def contact_present
    errors.add(:base, "phone or email is required") if phone.blank? && email.blank?
  end
end
