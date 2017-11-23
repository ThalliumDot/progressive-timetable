class GroupsController < ApplicationController

  def index
    faculties = Faculty.all
    groups = Group.all.order(course: :asc)
    faculties_with_courses = faculties.map do |faculty|
      correct_groups = groups.select{ |group| group.faculty_id == faculty.id }
      courses = get_courses(correct_groups)
      faculty.attributes.merge!(courses: courses)
    end

    respond_with_meta({ faculties: faculties_with_courses })
  end


  private


  def get_courses(groups)
    min_course = 1
    max_course = 6
    courses = {}

    (min_course..max_course).each do |course_number|
      course_groups = groups.select{ |group| group.course == course_number }
      courses[course_number] = course_groups
    end
    courses
  end

end
