class LessonSerializer < BaseSerializer
  before_collection :group

  def group
    binding.pry
  end
end