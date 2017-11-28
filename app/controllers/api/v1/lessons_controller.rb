module Api
  module V1
    class LessonsController < ApplicationController

      def show
        if lesson_params[:weeks].present? && lesson_params[:dates].present?
          render json: { errors: "Forbidden, select weeks or dates" }, status: 403
          return
        end
        group = Group.find_by(name: params[:group_name])
        if group.blank?
          render json: { errors: "Group #{params[:group_name]} Not Found" }, status: 404
          return
        end
        lessons = group.lessons
      end


      private


      def lesson_params
        params.permit(:group_by_weeks, dates: [:from, :to], weeks: [])
      end

    end
  end
end
