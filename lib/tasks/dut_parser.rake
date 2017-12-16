require 'open-uri'
require 'optparse'

namespace :parse do
  desc ">> Parse timetable from http://e-rozklad.dut.edu.ua/, [-h, --help] - show usage, [-s, --semester-beginning] - allow start parsing from semester beginning"
  task dut: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    options = get_options
    url = "http://e-rozklad.dut.edu.ua/timeTable/group"
    faculties = find_faculties(url)

    faculties.each do |faculty_name, faculty_id|
      faculty = Faculty.find_or_create_by(name: faculty_name)
      url_with_faculty = url + "?TimeTableForm[faculty]=#{faculty_id}"
      courses = find_courses(url_with_faculty)

      courses.each do |course_name, course_id|
        url_with_faculty_and_course = url_with_faculty + "&TimeTableForm[course]=#{course_id}"
        groups = find_groups(url_with_faculty_and_course)
        save_groups(faculty, groups, course_name)

        groups.each do |group_name, group_id|
          log_information("parsing started for faculty: '#{faculty_name}' course: #{course_name} group: '#{group_name}'")

          timetable_url = url_with_faculty_and_course + "&TimeTableForm[group]=#{group_id}"
          group = faculty.groups.find_or_create_by(name: group_name, course: course_name)
          parse_group_timetable(group, timetable_url, options)
        end
      end
    end


    # test timetable for group КСД-31
    #
    # timetable_url = "#{url}?TimeTableForm[faculty]=1&TimeTableForm[course]=3&TimeTableForm[group]=1071"
    # faculty = Faculty.find_or_create_by(name: "Факультет Інформаційних технологій")
    # group = faculty.groups.find_or_create_by(name: "КСД-31", course: 3)
    # parse_group_timetable(group, timetable_url, options)
  end
end

def get_options
  current_time = TimeHelper.c
  year = current_time.year
  start_first_semester = TimeHelper.p("1.09.#{year}")
  start_second_semester = TimeHelper.p("1.01.#{year}")
  options = { start_parsing_date: current_time }

  if ARGV[1] == 'semester_beginning'
    if start_first_semester.past?
      options[:start_parsing_date] = start_first_semester
    else
      options[:start_parsing_date] = start_second_semester
    end
  end

  options
end

def find_faculties(url)
  html = Nokogiri::HTML(open(url))
  faculty_options_tag = html.css('select#TimeTableForm_faculty option')
  faculty_ids = find_ids(faculty_options_tag)
  faculty_names = names(faculty_options_tag)
  Hash[faculty_names.zip(faculty_ids)]
end

def find_courses(url)
  html = Nokogiri::HTML(open(url))
  course_options_tag = html.css('select#TimeTableForm_course option')
  course_ids = find_ids(course_options_tag)
  course_names = names(course_options_tag)
  Hash[course_names.zip(course_ids)]
end

def find_groups(url)
  html = Nokogiri::HTML(open(url))
  group_options_tag = html.css('select#TimeTableForm_group option')
  group_ids = find_ids(group_options_tag)
  group_names = names(group_options_tag)
  Hash[group_names.zip(group_ids)]
end

def find_ids(options_tag)
  ids = options_tag.map { |option| option.values[0] }
  ids.reject! { |s| s.nil? || s.strip.empty? }
end

# Searching for names of faculties, courses and groups to store in db
def names(options_tag)
  names = options_tag.map { |option| option.text }
  names.reject! { |s| s.nil? || s.strip.empty? || s == '\n' || s == "\u00A0"}
end

def save_groups(faculty, groups, course_name)
  groups.each_key do |group_name|
    faculty.groups.find_or_create_by(name: group_name, course: course_name.to_i)
  end
end

def parse_group_timetable(group, timetable_url, options)
  time_intervals = find_time_intervals(options)
  time_intervals.each do |time_interval|
    timetable = {}
    timetable_url += "&TimeTableForm[date1]=#{time_interval[:from]}&TimeTableForm[date2]=#{time_interval[:to]}"

    html = Nokogiri::HTML(open(timetable_url))
    html.css('.timeTable tr').each do |tr|
      dates_and_lessons = {}
      lesson_numbers = tr.css('td')[0].css('.lesson').map { |lesson| lesson.text[/\d/] }
      day = tr.css('td')[0].css('div')[0].text
      tds = tr.css('td')
      tds.each do |td|
        next if td.css('.cell-vertical').any?
        date = td.css('div')[0].text
        lessons_divs = td.css('div')
        lessons_information = find_lessons_information(lessons_divs)
        dates_and_lessons[date] = Hash[lesson_numbers.zip(lessons_information)]
      end
      timetable[day] = dates_and_lessons
    end

    parsed_lessons = rebuild_timetable(timetable)
    next if parsed_lessons.blank?

    planned_lessons = group.planned_lessons
    compare_lessons(planned_lessons, parsed_lessons, time_interval, group.id)
  end
end

def find_time_intervals(options)
  start_parsing_date = options[:start_parsing_date]

  [
    {
      from: start_parsing_date.strftime("%d.%m.%Y"),
      to:   (start_parsing_date + 3.month).strftime("%d.%m.%Y")
    },
    {
      from: (start_parsing_date + 3.month + 1.day).strftime("%d.%m.%Y"),
      to:   (start_parsing_date + 6.month + 1.day).strftime("%d.%m.%Y")
    }
  ]
end

def find_lessons_information(lessons_divs)
  lessons_information = []

  lessons_divs.each do |div|
    next if div['data-content'].nil?
    lesson_shortcut = div.text[/.+\]/]

    if lesson_shortcut
      lesson_shortcut.strip!
      if lesson_shortcut.include? '['
        short_name = lesson_shortcut.match(/(.+)\[/)[1]
        type = lesson_shortcut.match(/\[(.+)\]/)[1]
      end
    end

    click_information = div['data-content'].split('<br>').map{ |row| row.strip }
    clean(click_information)
    lessons_information << make_lesson_information(type, short_name, click_information)
  end

  lessons_information
end

def clean(click_information)
  click_information.reject! { |s| s.nil? || s.strip.empty? }
  click_information.collect! do |element|
    if element.include? '['
      element.match(/(.+)\[/)[1]
    elsif element.include? 'ауд'
      element.match(/ауд. (.+)/)[1]
    else
      element
    end
  end
end

def make_lesson_information(type, short_name, click_information)
  if type.nil? && short_name.nil? && click_information.blank?
    return nil
  end

  {
    lesson_type: type,
    short_name: short_name,
    long_name: click_information[0],
    classroom: click_information[1],
    teacher: click_information[2],
    other: [click_information[3], click_information[4]]
  }
end

def rebuild_timetable(timetable)
  parsed_lessons = []

  timetable.each_value do |dates|
    dates.each do |date, timings|
      date = TimeHelper.p(date).to_i
      timings.each do |timing, lesson_information|
        next if (lesson_information.nil?)
        index = check_parsed_lessons(parsed_lessons, lesson_information, timing)
        if index.blank?
          new_parsed_lesson = new_lesson(lesson_information, timing, date)
          parsed_lessons << new_parsed_lesson
          next
        end
        if parsed_lessons[index][:dates].exclude?(date)
          parsed_lessons[index][:dates] << date
        end
      end
    end
  end
  parsed_lessons
end

def check_parsed_lessons(parsed_lessons, lesson_information, timing)
  parsed_lessons.each_with_index do |lesson, index|
    if have_match?(lesson, lesson_information, timing)
      return index
    end
  end

  nil
end

def have_match?(lesson, parsed_lesson, timing = nil)
  timing ||= parsed_lesson[:timing]

  lesson[:timing]      == timing &&
  lesson[:lesson_type] == parsed_lesson[:lesson_type] &&
  lesson[:short_name]  == parsed_lesson[:short_name] &&
  lesson[:teacher]     == parsed_lesson[:teacher] &&
  lesson[:classroom]   == parsed_lesson[:classroom]
end

def new_lesson(lesson_information, timing, date)
  new_lesson = {timing: timing, dates: [date]}
  new_lesson.merge!(lesson_information)
  new_lesson
end

def compare_lessons(planned_lessons, parsed_lessons, time_interval, group_id)
  parsed_lessons.each do |parsed_lesson|
    planned_lesson = find_exact_match(planned_lessons, parsed_lesson)
    if planned_lesson.blank?
      planned_lesson = find_enough_match(planned_lessons, parsed_lesson)
      if planned_lesson.present?
        planned_lesson.reject_and_update_dates(planned_lesson.dates, parsed_lesson[:dates])
      end
      PlannedLesson.create_with_linked(parsed_lesson.except(:other).merge(group_id: group_id))
      next
    end
    planned_lesson.check_and_update_dates(planned_lesson.dates, parsed_lesson[:dates])
  end

  planned_lessons.reload
  planned_lessons.each do |planned_lesson|
    new_dates = planned_lesson.dates
    new_dates.reject! do |date|
      next if date_out_of_interval?(date, time_interval)
      absent_in_parsed_lessons?(planned_lesson, date, parsed_lessons)
    end
    planned_lesson.update(dates: new_dates) if (planned_lesson.reload.dates <=> new_dates) != 0
  end
end

def date_out_of_interval?(date, time_interval)
  date < TimeHelper.p(time_interval[:from]).to_i || date > TimeHelper.p(time_interval[:to]).to_i
end

def find_exact_match(planned_lessons, parsed_lesson)
  planned_lessons.each do |planned_lesson|
    return planned_lesson if have_exact_match?(planned_lesson, parsed_lesson)
  end

  nil
end

def have_exact_match?(planned_lesson, parsed_lesson)
  planned_lesson.timing             == parsed_lesson[:timing] &&
  planned_lesson.lesson_type        == parsed_lesson[:lesson_type] &&
  planned_lesson.short_name         == parsed_lesson[:short_name] &&
  planned_lesson.teacher.full_name  == parsed_lesson[:teacher] &&
  planned_lesson.classroom          == parsed_lesson[:classroom]
end

def find_enough_match(planned_lessons, parsed_lesson)
  planned_lessons.each do |planned_lesson|
    return planned_lesson if have_enough_match?(planned_lesson, parsed_lesson)
  end

  nil
end

def have_enough_match?(planned_lesson, parsed_lesson)
  (
    planned_lesson.lesson_type == parsed_lesson[:lesson_type] &&
    planned_lesson.short_name  == parsed_lesson[:short_name]
  ) &&
  (
    planned_lesson.timing  == parsed_lesson[:timing] ||
    (planned_lesson.dates <=> parsed_lesson[:dates]) == 0
  )
end

def absent_in_parsed_lessons?(planned_lesson, date, parsed_lessons)
  parsed_lessons.each do |parsed_lesson|
    parsed_lesson[:dates].each do |parsed_date|
      if parsed_date == date && have_exact_match?(planned_lesson, parsed_lesson)
        return false
      end
    end
  end

  true
end

def log_information(string)
  string = "Parser | " + string

  Rails.logger.info { string }
  puts string
end
