class ApplicationController < ActionController::Base
  include Authentication
  include VisitorIdentification
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def authenticate_admin!
    require_authentication
  end

  def current_user
    Current.user
  end
  helper_method :current_user
end
