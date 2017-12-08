require 'base/serializer'

class LessonSerializer < Serializer
  attributes :name

  before_collection :group

  def group
    binding.pry
  end
end
