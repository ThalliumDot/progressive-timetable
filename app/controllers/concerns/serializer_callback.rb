module SerializerCallback
  extend ActiveSupport::Concern

  included do
    # make our module included before ActionController to define render
    ActionController.prepend(SerializerCallback)
  end

  def render(**args)
    # TODO: SerializerControllerMethods.allowed_actions
    if args.keys.include?(:json)
      sr = SerializableResource.new(args[:json], params)
      if sr.have_serializer?
        to_render = {}
        to_render[:json] = sr.serialize.as_json

        if args.keys.include?(:meta)
          to_render[:json].merge!({ meta: args[:meta] })
        end

        args = to_render
      end
    end

    super(args)
  end
end
