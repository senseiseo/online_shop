ActiveAdmin.register Category do
  permit_params :name, :slug, :description, :position, :published
  actions :all, except: :destroy
  filter :name
  filter :published

  member_action :remove, method: :delete do
    resource.destroy!
    redirect_to collection_path, notice: I18n.t("admin.categories.deleted")
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to resource_path, alert: I18n.t("admin.categories.cannot_delete")
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :position
    column :published
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
      f.input :description
      f.input :position
      f.input :published
    end
    f.actions
  end

  action_item :remove, only: :show do
    text_node button_to(I18n.t("admin.categories.delete"), remove_admin_category_path(resource), method: :delete, form: { class: "inline" })
  end
end
