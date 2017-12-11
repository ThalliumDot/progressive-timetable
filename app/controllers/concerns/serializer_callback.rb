module SerializerCallback
  extend ActiveSupport::Concern

  included do
    # make our module included before ActionController to define render
    ActionController.prepend(SerializerCallback)
  end

  def render(**args)
    # TODO: SerializerControllerMethods.allowed_actions

    if args.include?(:json)
      sr = SerializableResource.new(args[:json], params)
      if sr.have_serializer?
        args[:json] = sr.serialize.as_json
      end
    end

    super(args)
  end
end
