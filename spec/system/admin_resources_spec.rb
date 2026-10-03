require "rails_helper"

# The native-form flow must cover all previously JavaScript-only actions.
# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations

RSpec.describe "Admin resource actions", type: :system do
  let(:admin) { create(:user, password: "password123") }

  def sign_in
    visit new_session_path
    fill_in "Enter your email address", with: admin.email_address
    fill_in "Enter your password", with: "password123"
    click_button "Sign in"
  end

  it "submits native forms for logout, order updates, and deletion" do
    order = create(:order)
    product = create(:product)
    sign_in

    visit admin_order_path(order)
    click_button "Confirmed"
    expect(order.reload).to be_confirmed
    click_button "Mark paid"
    expect(order.reload).to be_paid

    visit admin_product_path(product)
    click_button "Delete product"
    expect(Product.where(id: product.id)).to be_empty

    visit admin_root_path
    click_button "Logout"
    expect(page).to have_text("Sign in")
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
