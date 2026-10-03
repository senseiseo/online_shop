ActiveAdmin.register Cart do
  actions :index, :show
  filter :status
  filter :visitor
  filter :updated_at

  index do
    id_column
    column :visitor
    column :status
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :visitor
      row :status
      row :created_at
      row :updated_at
    end
    panel "Items" do
      table_for cart.cart_items do
        column :product
        column :quantity
      end
    end
  end
end
