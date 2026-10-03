module VisitorIdentification
  extend ActiveSupport::Concern

  included do
    before_action :identify_visitor
    helper_method :current_visitor, :current_cart
  end

  private

  def current_visitor
    @current_visitor
  end

  def current_cart
    current_visitor.find_or_create_active_cart
  end

  def identify_visitor
    @current_visitor = Visitor.find_by(token: cookies.signed[:visitor_token])
    if current_visitor
      current_visitor.touch(:last_seen_at)
    else
      @current_visitor = Visitor.create_with_token!
      cookies.signed.permanent[:visitor_token] = {
        value: current_visitor.token, httponly: true, same_site: :lax
      }
    end
  end
end
