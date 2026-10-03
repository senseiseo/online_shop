ActiveAdmin.register_page "Dashboard" do
  content do
    if current_user.admin? || current_user.manager?
      columns do
        column do
        panel "Orders" do
          para "New: #{Order.where(status: :new).count}"
          para "Today: #{Order.where(created_at: Time.zone.today.all_day).count}"
          revenue = Order.where(status: :completed, payment_status: :paid).sum(:total_price_cents)
          para "Completed paid revenue: #{number_to_currency(revenue / 100.0, unit: "₽")}".strip
        end
        end
        column do
        panel "Inquiries" do
          para "New: #{Inquiry.where(status: :new).count}"
          para "Active carts: #{Cart.active.count}" if current_user.admin?
        end
        end
      end

      panel "Latest orders" do
        table_for Order.order(created_at: :desc).limit(10) do
          column(:number) { |order| link_to order.number, admin_order_path(order) }
          column :name
          column :status
          column :total_price_cents
        end
      end
    end
  end
end
