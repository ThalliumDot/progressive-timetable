class LessonsController < ApplicationController
  include SerializerCallback
  extend  SerializerControllerMethods

  serialization only: [:show]

  def show
    if lesson_params[:weeks].present? && lesson_params[:dates].present?
      render json: { errors: "Invalid request: both 'weeks' and 'dates' keys detected. You must choose only one of them" }, status: 403
      return
    end

    lessons = Lesson.for_group_and_period(params[:group_name],
                                          lesson_params[:dates][:from],
                                          lesson_params[:dates][:to])

    render json: lessons
  end


  private


  def lesson_params
    params.permit(:group_by_weeks, dates: [:from, :to], weeks: [])
  end

end
