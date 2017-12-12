require 'base/serializer'

class LessonSerializer < Serializer
  attributes :short_name, :long_name

  before_collection :group

  respond_with :meta

  def group
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

  def meta
    {
      server_time: Time.zone.now.to_i
    }
  end
end
