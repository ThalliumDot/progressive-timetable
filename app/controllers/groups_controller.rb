class GroupsController < ApplicationController

  def index
    respond_with_meta({'man': 'hi'})
  end

end
