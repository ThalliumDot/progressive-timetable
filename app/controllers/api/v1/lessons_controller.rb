module Api
  module V1
    class LessonsController < ApplicationController

      def show
        group = Group.find_by(name: params[:group_name])
        if group.blank?
          render json: { errors: "Group #{params[:group_name]} Not Found" }, status: 404
          return
        end
        lessons = group.lessons
      end


      private


      def lesson_params
        params.permit(:from, :to, :group_by_weeks, week: [])
      end

    end
  end
end
