ActiveAdmin.register Product do
  permit_params :category_id, :name, :slug, :short_description, :description, :price_cents, :old_price_cents, :published, :featured, :position, images: []
  actions :all, except: :destroy
  filter :category
  filter :name
  filter :published
  filter :featured

  member_action :remove, method: :delete do
    resource.destroy!
    redirect_to collection_path, notice: I18n.t("admin.products.deleted")
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to resource_path, alert: I18n.t("admin.products.cannot_delete")
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def update
      params[:product]&.delete(:images) if params.dig(:product, :images)&.all?(&:blank?)
      super
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price_cents
    column :published
    column :featured
    actions
  end

  form html: { multipart: true } do |f|
    f.inputs do
      f.input :category
      f.input :name
      f.input :slug
      f.input :short_description
      li do
        text_node f.template.label(:product, :description)
        text_node f.template.rich_text_area(:product, :description)
      end
      f.input :price_cents
      f.input :old_price_cents
      f.input :position
      f.input :published
      f.input :featured
      f.input :images, as: :file, input_html: { multiple: true }
    end
    f.actions
  end

  show do
    attributes_table do
      row :category
      row :name
      row :slug
      row :short_description
      row :price_cents
      row :old_price_cents
      row :published
      row :featured
      row :position
      row :images do |product|
        ul { product.images.each { |image| li image.filename.to_s } }
      end
    end
    panel I18n.t("admin.products.description") do
      product.description
    end
  end

  action_item :remove, only: :show do
    text_node button_to(I18n.t("admin.products.delete"), remove_admin_product_path(resource), method: :delete, form: { class: "inline" })
  end
end
