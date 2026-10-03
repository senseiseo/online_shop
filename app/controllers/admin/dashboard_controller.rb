module Admin
  class DashboardController < ApplicationController
    def show
      render plain: "Admin"
    end
  end
end
