class StorefrontController < ApplicationController
  allow_unauthenticated_access

  def show
    head :no_content
  end
end
