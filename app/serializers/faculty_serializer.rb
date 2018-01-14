require 'base/serializer'

class FacultySerializer < Serializer
  attributes :id, :name

  after_resource :inject_groups

  def inject_groups
    courses = get_courses(Group.where(faculty_id: object[:id]))
    self.object = object.merge!(courses: courses)
  end

  def get_courses(groups)
    return [] if groups.blank?
    min_course = 1
    max_course = groups.maximum('course')
    courses = {}

    (min_course..max_course).each do |course_number|
      groups_by_course = groups.select{ |group| group.course == course_number }
      courses[course_number] = groups_by_course.map do |group|
        group.attributes.select!{ |key| key == 'id' || key == 'name' }
      end
    end
    courses
  end
end
