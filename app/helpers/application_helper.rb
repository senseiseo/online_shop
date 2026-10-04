module ApplicationHelper
  def page_metadata(title: nil, description: nil, image: nil)
    content_for :title, title if title
    content_for :description, description if description
    content_for :image, image if image
  end

  def rubles(cents)
    whole, fractional = cents.divmod(100)
    "#{number_with_delimiter(whole, delimiter: " ")}.#{format("%02d", fractional)} ₽"
  end
end
