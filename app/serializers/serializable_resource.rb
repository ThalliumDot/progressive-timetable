class SerializableResource
  # TODO: (initialize) do something with unacceptable resources
  # TODO: check namespaces and modules when search model class

  require 'base/serializable_object_decorator.rb'
  require 'base/serializer.rb'

  # internal
  attr_accessor :serializable_resource
  attr_reader   :resource_hash, :key, :klass, :is_collection, :params


  def initialize(resource, params = nil)
    @resource_hash = SecureRandom.hex(10)
    @is_collection = false
    @klass = nil
    @params = params

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
    unless have_serializer?
      return
    end

    serializer_class = "#{klass}Serializer".constantize

    if is_collection
      serializer = serializer_class.new(:collection, serializable_resource, params)

      if serializer._before_collection.present?
        serializer._before_collection.each do |method|
          serializer.send(method)
        end
      end
    end

    if is_collection
      SerializableObjectDecorator.each_of(resource_hash) do |ser_res|
        instance_serialization(ser_res)
      end
    else
      SerializableObjectDecorator.each_of(resource_hash) do |ser_res|
        serializer = instance_serialization(ser_res)
      end
    end

    if is_collection && serializer._after_collection.present?
      serializer._after_collection.each do |method|
        serializer.send(method)
      end
    end

    self.serializable_resource = serializer

    self
  end

  def instance_serialization(resource)
    instance_serializer = "#{klass}Serializer".constantize.new(:object, resource, params)

    if instance_serializer._before_resource.present?
      instance_serializer._before_resource.each do |method|
        instance_serializer.send(method)
      end
    end

    resource_hash = {}

    instance_serializer._attributes.each do |attr|
      if instance_serializer.try(attr)
        resource_hash[attr] = instance_serializer.try(attr)
      else
        resource_hash[attr] = instance_serializer.object.try(attr)
      end
    end

    instance_serializer.object.replace_with_hash(resource_hash)

    if instance_serializer._after_resource.present?
      instance_serializer._after_resource.each do |method|
        instance_serializer.send(method)
      end
    end

    instance_serializer
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

  def as_json
    hash = { key => serializable_resource.get_resource }

    if serializable_resource._respond_with.present?
      serializable_resource._respond_with.each do |method|
        hash.merge!({ method => serializable_resource.send(method) })
      end
    end

    hash.as_json
  end

  # def serializer
  #   "#{klass}Serializer"
  # end

  def have_serializer?
    return false unless klass.present?
    eval("#{klass}Serializer")
    true
  rescue NameError;
    return false
  end
end
