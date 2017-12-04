# == Schema Information
#
# Table name: bug_reports
#
#  id         :integer          not null, primary key
#  full_name  :string
#  browser    :string
#  device     :string
#  os         :string
#  problem    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BugReport < ApplicationRecord
end
