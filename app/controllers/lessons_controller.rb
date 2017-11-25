class LessonsController < ApplicationController

  def show
    group = Group.find_by(name: params[:group_name])

    if params.key?(:from) && params.key?(:to)
      lessons = { 'custom serialization' => 'between entered \'from\' and entered \'to\' dates' }
    elsif params.key?(:from)
      lessons = { 'custom serialization' => 'between entered \'from\' and default \'to\' dates' }
    elsif params.key?(:to)
      lessons = { 'custom serialization' => 'between default \'from\' and entered \'to\' dates' }
    elsif params.key?(:week)
      if params[:week].count == 1
        lessons = { 'custom serialization' => "should return #{params[:week].first} week" }
      elsif params[:week].count == 2
        lessons = { 'custom serialization' => "should return #{params[:week].first}-#{params[:week].last} week" }
      end
    end
    group_by_weeks(lessons) if params[:group_by_weeks] == "1"

    group_with_lessons = group.attributes.merge!(lessons: lessons)
    respond_with_meta(group_with_lessons)
  end


  private


  def group_by_weeks(lessons)
    lessons['group_by_weeks'] = "should return groups array by week number"
  end

end
