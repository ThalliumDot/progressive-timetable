require 'base/serializer'

class LessonSerializer < Serializer
  attributes :short_name, :long_name

  before_collection :group

  def group
    binding.pry
    grouped = {}

    collection.each do |lesson|
      lesson.dates.each do |date|
        week = Time.at(date).to_datetime.cweek

        grouped[week] ||= {}
        grouped[week][date] ||= []
        grouped[week][date] << lesson
      end
    end

    self.collection = grouped
  end
end
