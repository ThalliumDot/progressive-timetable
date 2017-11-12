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
    self.where(dates:[]).delete_all
  end

  def self.compare_parse_lessons_and_db_lessons(db_lessons, timetable)
    parse_lessons = rebuild_timetable(timetable)
    parse_lessons.each do |parse_lesson|
      db_lesson = find_exact_match(db_lessons, parse_lesson)
      if db_lesson.blank?
        find_enough_match_and_update_dates(db_lessons, parse_lesson)
        db_lessons.create!(
          short_name: parse_lesson[:short_name],
          long_name: parse_lesson[:long_name],
          lesson_type: parse_lesson[:lesson_type],
          teacher: parse_lesson[:teacher],
          dates: parse_lesson[:dates],
          timing: parse_lesson[:timing],
          classroom: parse_lesson[:classroom]
        )
        next
      end
      if (db_lesson.dates <=> parse_lesson[:dates]) != 0
        db_lesson.update(dates: parse_lesson[:dates])
      end
    end
  end


  private


  def self.rebuild_timetable(timetable)
    parse_lessons = []

    timetable.each_value do |dates|
      dates.each do |date, timings|
        # made Unix time
        date = Time.zone.parse(date).to_i
        timings.each do |timing, lesson_information|
          next if (lesson_information.nil?)

          index = check_parse_lessons(parse_lessons, lesson_information, timing)
          if index.blank?
            new_parse_lesson = new_lesson(lesson_information, timing, date)
            parse_lessons << new_parse_lesson
            next
          end
          if parse_lessons[index][:dates].exclude?(date)
            parse_lessons[index][:dates] << date
          end
        end
      end
    end
    parse_lessons
  end

  def self.check_parse_lessons(parse_lessons, lesson_information, timing)
    parse_lessons.each_with_index do |lesson, index|
      if (lesson[:timing] == timing &&
          lesson[:lesson_type] == lesson_information[:lesson_type] &&
          lesson[:short_name] == lesson_information[:short_name] &&
          lesson[:teacher] == lesson_information[:teacher] &&
          lesson[:classroom] == lesson_information[:classroom])
        return index
      end
    end

    return nil
  end

  def self.new_lesson(lesson_information, timing, date)
    new_lesson = {timing: timing, dates: [date]}
    new_lesson.merge!(lesson_information)
    new_lesson
  end

  def self.find_exact_match(db_lessons, parse_lesson)
    db_lessons.each do |db_lesson|
      if (db_lesson.timing == parse_lesson[:timing] &&
          db_lesson.lesson_type == parse_lesson[:lesson_type] &&
          db_lesson.short_name == parse_lesson[:short_name] &&
          db_lesson.teacher == parse_lesson[:teacher] &&
          db_lesson.classroom == parse_lesson[:classroom])
        return db_lesson
      end
    end

    return nil
  end

  def self.find_enough_match_and_update_dates(db_lessons, parse_lesson)
    db_lessons.each do |db_lesson|
      if (db_lesson.lesson_type == parse_lesson[:lesson_type] &&
          db_lesson.short_name == parse_lesson[:short_name]) &&
          (db_lesson.timing == parse_lesson[:timing] ||
          (db_lesson.dates <=> parse_lesson[:dates]) == 0)
        dates = db_lesson.dates.reject { |date| parse_lesson[:dates].include?(date) }
        db_lesson.update(dates: dates)
      end
    end
  end
end
