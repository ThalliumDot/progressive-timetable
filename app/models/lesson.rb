# == Schema Information
#
# Table name: lessons
#
#  id         :integer          not null, primary key
#  short_name :string
#  long_name  :string
#  type       :string
#  teacher    :string
#  dates      :integer          default([]), is an Array
#  timing     :jsonb
#  group_id   :integer
#  classroom  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Lesson < ApplicationRecord

  # should live (in future) in Rails config or somewhere...
  LESSONS = {
    "1" => {
      starts_at: "8:00",
      ends_at:   "9:35"
    },
    "2" => {
      starts_at: "9:45",
      ends_at:   "11:20"
    },
    "3" => {
      starts_at: "11:45",
      ends_at:   "13:20"
    },
    "4" => {
      starts_at: "13:30",
      ends_at:   "15:05"
    },
    "5" => {
      starts_at: "15:15",
      ends_at:   "16:50"
    },
    "6" => {
      starts_at: "17:00",
      ends_at:   "18:35"
    }
  }

  belongs_to :group


  def self.delete_empty_dates()
    self.where(dates: []).delete_all
  end

  def self.create_lesson(parsed_lesson)
    self.create!(
      short_name: parsed_lesson[:short_name],
      long_name: parsed_lesson[:long_name],
      lesson_type: parsed_lesson[:lesson_type],
      teacher: parsed_lesson[:teacher],
      dates: parsed_lesson[:dates],
      timing: parsed_lesson[:timing],
      classroom: parsed_lesson[:classroom]
    )
  end

  def reject_and_update_dates(lesson_dates, parsed_dates)
    dates = lesson_dates.reject{ |date| parsed_dates.include?(date) }
    self.update(dates: dates)
  end

  def check_and_update_dates(lesson_dates, parsed_dates)
    if (lesson_dates <=> parsed_dates) != 0
      new_dates = lesson_dates
      parsed_dates.each do |parsed_date|
        new_dates << parsed_date if lesson_dates.exclude?(parsed_date)
      end
      self.update(dates: new_dates)
    end
  end
end
