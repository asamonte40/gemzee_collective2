class PagesController < ApplicationController
  def show
    @page = Page.find_by(slug: params[:slug])
    unless @page
      redirect_to root_path, alert: "Page not found"
    end
  end
end
