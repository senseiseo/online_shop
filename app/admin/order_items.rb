ActiveAdmin.register OrderItem do
  actions :index, :show
  filter :order
  filter :product
  filter :product_name

  index do
    id_column
    column :order
    column :product_name
    column :quantity
    column :unit_price_cents
    column :total_price_cents
    actions
  end
end
