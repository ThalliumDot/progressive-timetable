include ActiveSupport::Configurable

class Serializer

  class_attribute :_attributes

  def self.attributes(*attrs)
    attrs = attrs.first if attrs.first.class == Array
    self._attributes = attrs
  end

  # callbacks
  [:before, :after].each do |cb_type|
    [:collection, :resource].each do |resource_type|
      class_variable = "_#{cb_type}_#{resource_type}"

      class_attribute class_variable.to_sym

      define_singleton_method("#{cb_type}_#{resource_type}", ) do |*callbacks|
        self.send((class_variable << '=').to_sym, callbacks)
      end
    end
  end

  def initialize(type, resource)
    instance_variable_set("@#{type}", resource)
    self.class.send(:attr_reader, type)
  end
end