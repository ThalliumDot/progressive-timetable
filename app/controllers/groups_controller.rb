class GroupsController < ApplicationController
  include SerializerCallback
  extend  SerializerControllerMethods

  serialization only: [:index]

  def index
    faculties = Faculty.all
    render json: faculties
  end
end
