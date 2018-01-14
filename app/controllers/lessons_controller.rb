class LessonsController < ApplicationController
  include SerializerCallback
  extend  SerializerControllerMethods

  serialization only: [:show]

  def show
    if lesson_params[:weeks].present? && lesson_params[:dates].present?
      render json: { errors: "Invalid request: both 'weeks' and 'dates' keys detected. You must choose only one of them" }, status: 403
      return
    end

    time_start, time_end = get_timings_from_request

    lessons = PlannedLesson.for_group_and_period(params[:group_name], time_start, time_end)

    render json: lessons
  end


  private


  def lesson_params
    params.permit(:group_name, :group_by_weeks, dates: [:from, :to], weeks: [])
  end

  def get_timings_from_request
    if lesson_params[:dates]
      [lesson_params[:dates][:from].to_i, lesson_params[:dates][:to].to_i]
    else
      [
        TimeHelper.ws(lesson_params[:weeks].first).to_i,
        TimeHelper.we(lesson_params[:weeks].last).to_i
      ]
    end
  end

end
