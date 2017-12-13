module SerializerControllerMethods
  extend ActiveSupport::Concern

  class << self
    attr_accessor :allowed_actions
    attr_accessor :not_allowed_actions
  end

  def serialization(**actions_h)
    SerializerControllerMethods.allowed_actions = actions_h
  end

  def skip_serialization_for(*actions)
    SerializerControllerMethods.not_allowed_actions = actions
  end
end