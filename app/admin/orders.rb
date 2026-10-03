ActiveAdmin.register Order do
  permit_params :status, :payment_method, :payment_status
  actions :index, :show, :edit, :update
  filter :number
  filter :status
  filter :payment_status
  filter :payment_method
  filter :created_at

  member_action :set_status, method: :patch do
    authorize! :set_status, resource
    resource.update!(status: params.require(:status)) if Order.statuses.key?(params[:status])
    redirect_to resource_path, notice: "Order status updated."
  end

  member_action :set_payment_status, method: :patch do
    authorize! :set_payment_status, resource
    resource.update!(payment_status: params.require(:payment_status)) if Order.payment_statuses.key?(params[:payment_status])
    redirect_to resource_path, notice: "Payment status updated."
  end

  index do
    id_column
    column :number
    column :name
    column :phone
    column :email
    column :status
    column :payment_status
    column :total_price_cents
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :number
      row :created_at
      row :visitor
      row :name
      row :phone
      row :email
      row :comment
      row :status
      row :payment_method
      row :payment_status
      row :total_price_cents
    end

    panel "Items" do
      table_for order.order_items do
        column :product_name
        column :quantity
        column :unit_price_cents
        column :total_price_cents
      end
    end
  end

  action_item :status, only: :show do
    div do
      Order.statuses.each_key do |status|
        next if resource.status == status

        text_node button_to(status.humanize, set_status_admin_order_path(resource), method: :patch, params: { status: status }, form: { class: "inline" })
      end
      nil
    end
  end

  action_item :payment, only: :show do
    div do
      Order.payment_statuses.each_key do |status|
        next if resource.payment_status == status

        text_node button_to("Mark #{status}", set_payment_status_admin_order_path(resource), method: :patch, params: { payment_status: status }, form: { class: "inline" })
      end
      nil
    end
  end
end
