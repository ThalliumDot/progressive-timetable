require 'base/serializer'

class LessonSerializer < Serializer
  attributes :short_name, :long_name, :lesson_type

  before_collection :group

  respond_with :meta

  def group
    grouped = {}

    date_start, date_end = get_timings_from_request

    (date_start..date_end).step(1.day).each do |date|
      week = Time.at(date).to_datetime.cweek
      lessons = collection.select { |c| c.dates.include?(date) }

      next if lessons.empty?

      grouped[week] ||= {}
      grouped[week][date] ||= {}

      lessons.each do |l|
        grouped[week][date][l.timing] = l
      end
    end

    self.collection = grouped
  end

  def meta
    {
      server_time: Time.zone.now.to_i
    }
  end

  def get_timings_from_request
    if params[:dates]
      [params[:dates][:from].to_i, params[:dates][:to].to_i]
    else
      [
        TimeHelper.ws(params[:weeks].first).to_i,
        TimeHelper.we(params[:weeks].last).to_i
      ]
    end
  end
end
