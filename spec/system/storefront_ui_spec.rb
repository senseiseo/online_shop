require "rails_helper"
require "base64"

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe "Storefront UI", :js, type: :system do
  let!(:category) { create(:category, published: true) }
  let!(:product) { create(:product, category:, published: true, name: "Стол", slug: "stol") }

  before do
    2.times do |index|
      product.images.attach(io: StringIO.new(Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLh0QAAAABJRU5ErkJggg==")), filename: "product-#{index}.png", content_type: "image/png")
    end
  end

  it "keeps Turbo cart targets for repeated add, update, and removal before checkout" do
    visit product_path(product)
    click_button "В корзину"
    expect(page).to have_css("#cart_counter", text: "1")

    click_button "В корзину"
    expect(page).to have_css("#cart_counter", text: "2")

    visit cart_path
    quantity = find_field("Количество")
    quantity.fill_in with: "3"
    quantity.send_keys(:tab)
    expect(page).to have_css("#cart_counter", text: "3")

    click_button "Удалить"
    expect(page).to have_css("#cart_counter", text: "0")
    expect(page).to have_text("Корзина пуста")

    visit product_path(product)
    click_button "В корзину"
    find("a[href='#{cart_path}']").click
    click_link "Оформить заказ"
    fill_in "Имя", with: "Анна"
    fill_in "Телефон", with: "+79990000000"
    click_button "Создать заказ"

    expect(page).to have_text("Спасибо за заказ!")
    order = Order.find_by!(name: "Анна")
    expect(order.cart).to be_converted
    expect(order.order_items.first).to have_attributes(product_name: "Стол", quantity: 1)
  end

  it "works at mobile and desktop widths with accessible navigation and gallery" do
    page.current_window.resize_to(375, 800)
    visit product_path(product)

    click_button "В корзину"
    expect(page).to have_css("#cart_counter", text: "1", visible: :visible)

    expect(page).to have_css("html[lang='ru']")
    expect(page).to have_css("main")
    expect(page).to have_css("nav[aria-label='Основная навигация']")
    expect(page).to have_css("img[alt='Стол']", count: 2, visible: :all)
    images = all("[data-gallery-target='image']", visible: :all)
    expect(images.first).to be_visible
    expect(images.last).not_to be_visible
    find("button[data-gallery-index-param='1']").click
    expect(images.first).not_to be_visible
    expect(images.last).to be_visible

    expect(page).to have_css("[data-menu-target='links'].hidden", visible: :all)
    click_button "Меню"
    expect(page).to have_css("[data-menu-target='links']:not(.hidden)")
    expect(page).to have_css("button[aria-expanded='true']", text: "Меню")
    click_button "Меню"
    expect(page).to have_css("[data-menu-target='links'].hidden", visible: :all)
    expect(page).to have_css("button[aria-expanded='false']", text: "Меню")

    page.current_window.resize_to(1440, 900)
    expect(page).to have_css(".md\\:flex", visible: :visible)
  end

  it "keeps cart and checkout within each supported viewport" do
    visit product_path(product)
    click_button "В корзину"

    [ 320, 375, 768, 1024, 1440 ].each do |width|
      page.current_window.resize_to(width, 900)
      visit cart_path
      expect(page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")).to be(true), "cart overflows at #{width}px"
      visit new_checkout_path
      expect(page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")).to be(true), "checkout overflows at #{width}px"
    end
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
