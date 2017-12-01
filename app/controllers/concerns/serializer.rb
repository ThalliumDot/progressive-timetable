module Serializer
  extend ActiveSupport::Concern

  included do
    # make our module included before ActionController to define render
    ActionController.prepend(Serializer)
  end

  def render(**args)
    # TODO: SerializerControllerMethods.allowed_actions

    if args.include?(:json)
      args[:json] = BaseSerializer.new(args[:json]).serialize
    end

    # TODO: super action
    # binding.pry
  end
end
