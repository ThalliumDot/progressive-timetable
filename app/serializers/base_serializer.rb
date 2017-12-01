class BaseSerializer
  # TODO: (initialize) do something with unacceptable resources
  # TODO: check namespaces and modules when search model

  require 'base/serializable_object_decorator.rb'

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
      # then it is a single resource
      @klass = get_collection_class(resource)

      if klass
        @serializable_resource = SerializableObjectDecorator.new(resource, resource_hash)
        @key = klass.downcase
      end
    else
      # then it is a multiple resources
      @klass = get_single_resource_class(resource)
      if klass
        @is_collection = true
        @serializable_resource = SerializableObjectDecorator.wrap(resource, resource_hash)
        @key = klass.downcase.pluralize
      end
    end
  end


  def serialize
    if is_collection
      collection_callbacks.each do |method|
        "#{klass}Serializer".constantize.send(method)
      end
    else
      # find each resource and send them
    end
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


  def self.attributes(*attrs)

  end


  def self.before_collection(*callbacks)
    @collection_callbacks = callbacks
  end

  def self.before_resource(*callbacks)
    @resource_callbacks = callbacks
  end
end
