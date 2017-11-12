require 'open-uri'

namespace :parse do
  desc ">> Parse timetable from http://e-rozklad.dut.edu.ua/"
  task dut: :environment do
    parse_timetable()
  end
end

def parse_timetable
  url = "http://e-rozklad.dut.edu.ua/timeTable/group"
  university = find_university(url)
  # FileUtils::mkdir_p "#{university}"

  faculties = find_faculties(url)

      # change + to "#{}"
  # faculties.each do |faculty_name, faculty_id|
  #   # FileUtils::mkdir_p "#{university}/#{faculty_name}"
  #   faculty = Faculty.find_by_or_create(faculty_name)
  #   url_with_faculty = url + "?TimeTableForm[faculty]=#{faculty_id}"
  #   courses = find_courses(url_with_faculty)

  #   courses.each do |course_name, course_id|
  #   #   FileUtils::mkdir_p "#{university}/#{faculty_name}/#{course_name}"
  #     url_with_faculty_and_course = url_with_faculty + "&TimeTableForm[course]=#{course_id}"
  #     groups = find_groups(url_with_faculty_and_course)
  #     save_groups(faculty, groups, course_name)

  #     groups.each do |group_name, group_id|
  #       # dir = "#{university}/#{faculty_name}/#{course_name}/#{group_name}"
  #       # FileUtils::mkdir_p dir
  #       timetable_url = url_with_faculty_and_course + "&TimeTableForm[group]=#{group_id}"

  #       parse_group_timetable(faculty, group_name, timetable_url)
  #     end
  #   end
  # end

  #
  # test timetable for group КСД-31
  #
  timetable_url = "#{url}?TimeTableForm[faculty]=1&TimeTableForm[course]=3&TimeTableForm[group]=1071"
  faculty = Faculty.find_by_or_create("Факультет Інформаційних технологій")
  group = faculty.groups.find_by_or_create("КСД-31", 3)
  parse_group_timetable(group, timetable_url)

  # deleting all records with empty dates
  Lesson.delete_empty_dates();
end

def find_university(url)
  html = Nokogiri::HTML(open(url))
  html.at_css('div#top2 h2 strong span a span').text
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
    faculty.groups.find_by_or_create(group_name, course_name.to_i)
  end
end

def parse_group_timetable(group, timetable_url)
  timetable = {}

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

  db_lessons = group.lessons
  Lesson.compare_parse_lessons_and_db_lessons(db_lessons, timetable)
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
  if (type.nil? && short_name.nil? && click_information.blank?)
    return nil
  end
  lesson_information = {
    lesson_type: type,
    short_name: short_name,
    long_name: click_information[0],
    classroom: click_information[1],
    teacher: click_information[2],
    other: [click_information[3], click_information[4]]
  }
end
