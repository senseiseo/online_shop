module ApplicationHelper
  def rubles(cents)
    whole, fractional = cents.divmod(100)
    "#{number_with_delimiter(whole, delimiter: " ")}.#{format("%02d", fractional)} ₽"
  end
end
