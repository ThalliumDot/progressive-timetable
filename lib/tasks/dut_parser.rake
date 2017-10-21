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
  # puts faculties
  faculties.each do |faculty_name, faculty_number|
    # FileUtils::mkdir_p "#{university}/#{faculty_name}"
    faculty = Faculty.find_by_or_create(faculty_name)
    url_with_faculty = url + "?TimeTableForm[faculty]=#{faculty_number}"
    courses = find_courses(url_with_faculty)

    courses.each do |course_name, course_number|
    #   FileUtils::mkdir_p "#{university}/#{faculty_name}/#{course_name}"
      url_with_faculty_and_course = url_with_faculty + "&TimeTableForm[course]=#{course_number}"
      groups = find_groups(url_with_faculty_and_course)
      save_groups(faculty, groups, course_name)

      groups.each do |group_name, group_number|
        # dir = "#{university}/#{faculty_name}/#{course_name}/#{group_name}"
        # FileUtils::mkdir_p dir
        timetable_url = url_with_faculty_and_course + "&TimeTableForm[group]=#{group_number}"

        parse_group_timetable(faculty, group_name, timetable_url)
      end
    end
  end
end

def find_university(url)
  html = Nokogiri::HTML(open(url))
  html.at_css('div#top2 h2 strong span a span').text
end

def find_faculties(url)
  html = Nokogiri::HTML(open(url))
  faculty_options_tag = html.css('select#TimeTableForm_faculty option')
  faculty_numbers = numbers(faculty_options_tag)
  faculty_names = names(faculty_options_tag)
  Hash[faculty_names.zip(faculty_numbers)]
end

def find_courses(url)
  html = Nokogiri::HTML(open(url))
  course_options_tag = html.css('select#TimeTableForm_course option')
  course_numbers = numbers(course_options_tag)
  course_names = names(course_options_tag)
  Hash[course_names.zip(course_numbers)]
end

def find_groups(url)
  html = Nokogiri::HTML(open(url))
  group_options_tag = html.css('select#TimeTableForm_group option')
  group_numbers = numbers(group_options_tag)
  group_names = names(group_options_tag)
  Hash[group_names.zip(group_numbers)]
end

def numbers(options_tag)
  numbers = options_tag.map { |option| option.values[0] }
  numbers.reject! { |s| s.nil? || s.strip.empty? }
end

def names(options_tag)
  names = options_tag.map { |option| option.text }
  names.reject! { |s| s.nil? || s.strip.empty? || s == '\n' || s == "\u00A0"}
end

def save_groups(faculty, groups, course_name)
  groups.each_key do |group_name|
    faculty.groups.find_by_or_create(group_name, course_name.to_i)
  end
end

def parse_group_timetable(faculty, group_name, timetable_url)
  timetable = {}

  html = Nokogiri::HTML(open(timetable_url))
  html.css('.timeTable tr').each do |tr|
    dates_and_lessons = {}
    lesson_numbers = tr.css('td')[0].css('.lesson').map { |lesson| lesson.text }
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
  save_timetable(faculty, group_name, timetable)

  # File.open("#{dir}/#{group_name}.txt", 'w') { |file|
  #   file.puts "\n---------#{group_name}---------\n\n"
  #   file.puts JSON.pretty_generate(result)
  # }
end

def find_lessons_information(lessons_divs)
  lessons_information = []

  lessons_divs.each do |div|
    next if div['data-content'].nil?
    lesson_shortcut = div.text[/.+\]/]
    lesson_shortcut.strip! unless lesson_shortcut.nil?
    click_information = div['data-content'].split('<br>').map{ |row| row.strip }
    click_information.reject! { |s| s.nil? || s.strip.empty? }
    lessons_information << click_information.unshift(lesson_shortcut)
  end

  lessons_information
end

def save_timetable(faculty, group_name, timetable)
  puts timetable
end
