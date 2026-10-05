ActiveAdmin.register User do
  permit_params :email_address, :password, :password_confirmation, :role
  actions :all, except: :destroy
  filter :email_address
  filter :role

  member_action :remove, method: :delete do
    resource.destroy!
    redirect_to collection_path, notice: I18n.t("admin.users.deleted")
  end

  controller do
    respond_to :html
  end

  index do
    id_column
    column :email_address
    column :role
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email_address
      row :role
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :email_address
      f.input :role
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  action_item :remove, only: :show do
    text_node button_to(I18n.t("admin.users.delete"), remove_admin_user_path(resource), method: :delete, form: { class: "inline" })
  end
end
