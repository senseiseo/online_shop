ActiveAdmin.register_page "Dashboard" do
  menu label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    if current_user.admin? || current_user.manager?
      columns do
        column do
        panel I18n.t("admin.dashboard.orders") do
          para "#{I18n.t("admin.dashboard.new")}: #{Order.where(status: :new).count}"
          para "#{I18n.t("admin.dashboard.today")}: #{Order.where(created_at: Time.zone.today.all_day).count}"
          revenue = Order.where(status: :completed, payment_status: :paid).sum(:total_price_cents)
          para "#{I18n.t("admin.dashboard.completed_paid_revenue")}: #{number_to_currency(revenue / 100.0, unit: "₽")}".strip
        end
        end
        column do
        panel I18n.t("admin.dashboard.inquiries") do
          para "#{I18n.t("admin.dashboard.new")}: #{Inquiry.where(status: :new).count}"
          para "#{I18n.t("admin.dashboard.active_carts")}: #{Cart.active.count}" if current_user.admin?
        end
        end
      end

      panel I18n.t("admin.dashboard.latest_orders") do
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
