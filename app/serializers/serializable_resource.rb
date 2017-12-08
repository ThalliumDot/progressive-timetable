class SerializableResource
  # TODO: (initialize) do something with unacceptable resources
  # TODO: check namespaces and modules when search model class

  require 'base/serializable_object_decorator.rb'
  require 'base/serializer.rb'

  # internal
  attr_accessor :serializable_resource
  attr_reader   :resource_hash, :key, :klass, :is_collection
  # external
  attr_reader   :collection_callbacks, :resource_callbacks


  def initialize(resource)
    @resource_hash = SecureRandom.hex(10)
    @is_collection = false
    @collection_callbacks = []
    @resource_callbacks = []

    if resource.respond_to?(:each)
      # then it is a multiple resources
      @klass = get_collection_class(resource)

      if klass
        @serializable_resource = SerializableObjectDecorator.wrap(resource, resource_hash)
        @key = klass.downcase.pluralize
        @is_collection = true
      end
    else
      # then it is a single resource
      @klass = get_single_resource_class(resource)
      if klass
        @serializable_resource = SerializableObjectDecorator.new(resource, resource_hash)
        @key = klass.downcase
      end
    end
  end


  def serialize
    serializer_class = "#{klass}Serializer".constantize

    if is_collection
      serializer = serializer_class.new(:collection, serializable_resource)
    else
      serializer = serializer_class.new(:object, serializable_resource)
    end

    if is_collection && serializer._before_collection.present?
      serializer._before_collection.each do |method|
        serializer.send(method)
      end
    end

    if is_collection
      serializer.collection.map do |ser_res|
        child_serializer = serializer_class.new(:object, ser_res)

        if child_serializer._before_resource.present?
          child_serializer._before_collection.each do |method|
            child_serializer.send(method)
          end
        end

        child_serializer._attributes.each do |attr|
          child_serializer.object.try(:attr)
        end

        if child_serializer._after_resource.present?
          child_serializer._after_resource.each do |method|
            child_serializer.send(method)
          end
        end

        child_serializer
      end
    end

    if is_collection && serializer._after_collection.present?
      serializer._after_collection.each do |method|
        serializer.send(method)
      end
    end

    self
  end


  def get_single_resource_class(resource)
    if ActiveRecord::Base.descendants.map(&:name).include?(resource.class.name)
      resource.class.name
    else
      # its seems to be not model, but maybe its a decorator?
      nil
    end
  end


  def get_collection_class(resource)
    return nil unless resource.first

    resource_ancestors = resource.ancestors.map(&:name)
    return nil unless resource_ancestors.include?('ActiveRecord::Base')

    if resource.first.class.name == resource_ancestors.first
      return resource.first.class.name
    end
  end
end
