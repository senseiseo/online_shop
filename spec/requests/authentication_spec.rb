# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Staff authentication", type: :request do
  let(:user) { create(:user, password: "password123") }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end

  it "redirects guests from admin to sign in" do
    get admin_path

    expect(response).to redirect_to(new_session_path)
  end

  it "signs staff in" do
    sign_in(user)

    expect(response).to redirect_to(root_url)
  end

  it "lets authenticated staff visit admin" do
    sign_in(user)
    get admin_path

    expect(response).to have_http_status(:success)
  end

  it "signs staff out" do
    sign_in(user)
    delete session_path

    expect(response).to redirect_to(new_session_path)
  end

  it "allows every staff role into the protected admin entry point" do
    user = create(:user, :editor, password: "password123")
    sign_in(user)
    get admin_path

    expect(response).to have_http_status(:success)
  end

  it "keeps Rails CSRF protection enabled outside the test environment" do
    expect(ApplicationController.forgery_protection_strategy).to eq(ActionController::RequestForgeryProtection::ProtectionMethods::Exception)
  end
end
