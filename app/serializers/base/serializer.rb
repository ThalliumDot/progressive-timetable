include ActiveSupport::Configurable

class Serializer

  attr_accessor :params
  class_attribute :_attributes, :_respond_with

  def self.attributes(*attrs)
    attrs = attrs.first if attrs.first.class == Array
    self._attributes = attrs
  end

  def self.respond_with(*attrs)
    attrs = attrs.first if attrs.first.class == Array
    self._respond_with = attrs
  end

  # callbacks
  [:before, :after].each do |cb_type|
    [:collection, :resource].each do |resource_type|
      class_variable = "_#{cb_type}_#{resource_type}"

      class_attribute class_variable.to_sym

      define_singleton_method("#{cb_type}_#{resource_type}") do |*callbacks|
        self.send(("_#{cb_type}_#{resource_type}=").to_sym, callbacks)
      end
    end
  end

  def initialize(type, resource, params)
    instance_variable_set("@#{type}", resource)
    self.class.send(:attr_accessor, type)

    define_singleton_method(:get_resource) { return instance_variable_get("@#{type}".to_sym) }

    @params = params
  end
end