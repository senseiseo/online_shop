ActiveAdmin.register Visitor do
  actions :index, :show
  filter :name
  filter :phone
  filter :email
  filter :first_seen_at
  filter :last_seen_at

  controller do
    respond_to :html
  end

  index do
    id_column
    column("Token") { |visitor| visitor.token.first(12) }
    column :name
    column :phone
    column :email
    column :first_seen_at
    column :last_seen_at
    actions
  end

  show do
    attributes_table do
      row :id
      row("Token") { |visitor| visitor.token.first(12) }
      row :name
      row :phone
      row :email
      row :first_seen_at
      row :last_seen_at
      row("Active cart") { |visitor| link_to(visitor.active_cart&.id, admin_cart_path(visitor.active_cart)) if visitor.active_cart }
    end

    panel "Carts" do
      table_for visitor.carts.order(created_at: :desc) do
        column(:id) { |cart| link_to cart.id, admin_cart_path(cart) }
        column :status
        column :created_at
      end
    end
    panel "Orders" do
      table_for visitor.orders.order(created_at: :desc) do
        column(:number) { |order| link_to order.number, admin_order_path(order) }
        column :status
        column :total_price_cents
      end
    end
    panel "Inquiries" do
      table_for visitor.inquiries.order(created_at: :desc) do
        column(:id) { |inquiry| link_to inquiry.id, admin_inquiry_path(inquiry) }
        column :status
        column :message
      end
    end
  end
end
