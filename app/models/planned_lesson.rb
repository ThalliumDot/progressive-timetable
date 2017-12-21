# == Schema Information
#
# Table name: planned_lessons
#
#  id          :integer          not null, primary key
#  lesson_type :string
#  dates       :integer          default([]), is an Array
#  timing      :string
#  group_id    :integer          not null
#  classroom   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  lesson_id   :integer          not null
#  teacher_id  :integer          not null
#

class PlannedLesson < ApplicationRecord

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

  after_commit :delete_empty_dates

  belongs_to :group
  belongs_to :lesson
  belongs_to :teacher

  delegate :short_name, :long_name, to: :lesson

  def self.for_period(period_start, period_end)
    times = (period_start..period_end).step(1.day).to_a
    where('dates && ?::int[]', "{#{times.join(',')}}")
  end

  def self.for_group_and_period(group_name, period_start, period_end)
    joins(:group).where('groups.name = ?', group_name).for_period(period_start, period_end)
  end

  def self.create_with_linked(parsed_lesson)
    lesson = Lesson.find_or_create_by(
      short_name: parsed_lesson[:short_name],
      long_name: parsed_lesson[:long_name]
    )
    last_name, first_name, middle_name = parsed_lesson[:teacher].strip.split(/\s+/)
    teacher = Teacher.find_or_create_by(
      first_name: first_name,
      last_name: last_name,
      middle_name: middle_name
    )
    self.create(parsed_lesson.except(:short_name, :long_name, :teacher)) do |planned_lesson|
      planned_lesson.lesson_id = lesson.id
      planned_lesson.teacher_id = teacher.id
    end
  end

  def delete_empty_dates
    self.delete if dates.length == 0
  end

  def reject_and_update_dates(lesson_dates, parsed_dates)
    dates = lesson_dates.reject{ |date| parsed_dates.include?(date) }
    self.update(dates: dates) unless destroyed?
  end

  def check_and_update_dates(lesson_dates, parsed_dates)
    if (lesson_dates <=> parsed_dates) != 0
      new_dates = lesson_dates
      parsed_dates.each do |parsed_date|
        new_dates << parsed_date if lesson_dates.exclude?(parsed_date)
      end
      self.update(dates: new_dates) unless destroyed?
    end
  end

end
