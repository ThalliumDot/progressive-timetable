class LessonsController < ApplicationController
  include Callback
  extend  SerializerControllerMethods

  serialization only: [:show]

  def show
    if lesson_params[:weeks].present? && lesson_params[:dates].present?
      render json: { errors: "Invalid request: both 'weeks' and 'dates' keys detected. You must choose only onw of them" }, status: 403
      return
    end
    group = Group.find_by(name: params[:group_name])
    if group.blank?
      render json: { errors: "Group #{params[:group_name]} Not Found" }, status: 404
      return
    end
    render json: group.lessons
  end


  private


  def lesson_params
    params.permit(:group_by_weeks, dates: [:from, :to], weeks: [])
  end

end
