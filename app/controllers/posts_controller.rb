class PostsController < ApplicationController
  include Pagy::Method

  allow_unauthenticated_access

  def index
    @pagy, @posts = pagy(:offset, Post.published.includes(cover_attachment: :blob))
  end

  def show
    @post = Post.published.includes(cover_attachment: :blob).friendly.find(params[:slug])
  end
end
