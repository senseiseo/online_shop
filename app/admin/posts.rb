ActiveAdmin.register Post do
  permit_params :title, :slug, :excerpt, :published, :published_at, :content, :cover
  actions :all, except: :destroy
  filter :title
  filter :published
  filter :published_at

  member_action :remove, method: :delete do
    resource.destroy!
    redirect_to collection_path, notice: "Post deleted."
  end

  index do
    id_column
    column :title
    column :slug
    column :published
    column :published_at
    actions
  end

  form html: { multipart: true } do |f|
    f.inputs do
      f.input :title
      f.input :slug
      f.input :excerpt
      li do
        text_node f.template.label(:post, :content)
        text_node f.template.rich_text_area(:post, :content)
      end
      f.input :cover, as: :file
      f.input :published
      f.input :published_at
    end
    f.actions
  end

  action_item :remove, only: :show do
    text_node button_to("Delete post", remove_admin_post_path(resource), method: :delete, form: { class: "inline" })
  end
end
