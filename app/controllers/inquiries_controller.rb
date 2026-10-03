class InquiriesController < ApplicationController
  allow_unauthenticated_access

  def new
    @inquiry = current_visitor.inquiries.build(contact_attributes)
  end

  def create
    @inquiry = current_visitor.inquiries.build(inquiry_params)
    if @inquiry.save
      current_visitor.update!(inquiry_params.slice(:name, :phone, :email).compact_blank)
      redirect_to root_path, notice: "Спасибо, мы свяжемся с вами."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def contact_attributes
    current_visitor.slice(:name, :phone, :email)
  end

  def inquiry_params
    params.expect(inquiry: %i[name phone email message])
  end
end
