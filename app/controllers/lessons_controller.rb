class LessonsController < ApplicationController

  def show
    group = Group.find_by(name: params[:group_name])
    if group.blank?
      render json: { errors: "Group #{params[:group_name]} Not Found" }, status: 404
      return
    end
    lessons = group.lessons
    is_group_by_weeks = params[:group_by_weeks] == "true"

    if params.key?(:from) && params.key?(:to)
      custom_serialization(lessons, is_group_by_weeks, "accept \'from\' and \'to\' params")
    elsif params.key?(:from)
      custom_serialization(lessons, is_group_by_weeks, "accept only \'from\' param")
    elsif params.key?(:to)
      custom_serialization(lessons, is_group_by_weeks, "accept only \'to\' param")
    elsif params.key?(:week)
      if params[:week].count == 1
        custom_serialization(lessons, is_group_by_weeks, "accept #{params[:week].first} week")
      elsif params[:week].count == 2
        custom_serialization(lessons, is_group_by_weeks, "accept #{params[:week].first}-#{params[:week].last} week")
      end
    end
  end


  private


  def custom_serialization(lessons, is_group_by_weeks, accept_method)
    render json: { group_by_weeks: is_group_by_weeks, custom_serialization: accept_method, lessons: lessons }
  end

end
