class BugReportsController < ApplicationController
  # to resolve error: ActionController::InvalidAuthenticityToken
  # skip_before_action :verify_authenticity_token

  def create
    return head 403 if ENV['ACCEPT_BUG_REPORTS'] == 'false'

    bug_report = BugReport.new(report_params)
    if bug_report.save
      render json: { success: true }
    else
      render json: { errors: bug_report.errors.full_messages }, status: 422
    end
  end


  private


  def report_params
    params.permit(:full_name, :browser, :device, :os, :problem)
  end

end
