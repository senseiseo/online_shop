ActiveAdmin.register Inquiry do
  permit_params :status
  actions :index, :show, :edit, :update
  filter :status
  filter :name
  filter :email
  filter :created_at

  index do
    id_column
    column :status
    column :name
    column :phone
    column :email
    column :visitor
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :status
    end
    f.actions
  end
end
