class AdminAuthorizationAdapter < ActiveAdmin::AuthorizationAdapter
  CONTENT = [ Category, Product, Post ].freeze
  MANAGEMENT = [ Order, Inquiry ].freeze

  def authorized?(action, subject = nil)
    return false unless user
    return true if user.admin?

    model = subject.is_a?(Class) ? subject : subject.class
    return model == ActiveAdmin::Page || CONTENT.include?(model) if user.editor?
    return manager_allowed?(action, model) if user.manager?

    model == ActiveAdmin::Page
  end

  private

  def manager_allowed?(action, model)
    return true if model == ActiveAdmin::Page
    return false unless MANAGEMENT.include?(model)

    %i[read edit update set_status set_payment_status].include?(action)
  end
end
