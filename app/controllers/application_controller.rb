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
    resource_class = resource.class.name.split('::')
    if resource_class[1] == "ActiveRecord_Relation"
      resource = { resource_class[0].downcase.pluralize => resource }
    else
      resource = { resource_class[0].downcase => resource }
    end

    render json: resource.merge(meta: { server_time: Time.zone.now.to_i }.merge(args))
  end
end
