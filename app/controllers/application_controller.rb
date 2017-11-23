class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :render_layout

  def render_layout
    if request.format.symbol == :html
      render :html => '', :layout => true
      return
    end
  end

  def respond_with_meta(resource, **args)
    render json: resource, meta: { server_time: Time.zone.now.to_i }.merge(args)
  end
end
