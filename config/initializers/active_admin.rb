ActiveAdmin.setup do |config|
  config.site_title = "Online Shop"
  config.authentication_method = :authenticate_admin!
  config.current_user_method = :current_user
  config.authorization_adapter = "AdminAuthorizationAdapter"
  config.logout_link_path = :session_path
  config.logout_link_method = :delete
  config.comments = false
  config.batch_actions = false
  config.filter_attributes = %i[password password_confirmation password_digest token]
  config.register_stylesheet "trix.css"
  config.register_javascript "trix.js"
  config.register_javascript "actiontext.js"

  config.namespace :admin do |admin|
    admin.download_links = false
  end
end

class ActiveAdmin::Views::Header
  def build(namespace, menu)
    super(id: "header")

    site_title namespace
    global_navigation menu, class: "header-item tabs"
    div id: "utility_nav", class: "header-item tabs" do
      span helpers.current_user.email_address
      text_node helpers.button_to("Logout", helpers.session_path, method: :delete, form: { class: "logout" })
    end
  end
end
