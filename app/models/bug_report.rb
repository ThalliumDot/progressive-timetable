# == Schema Information
#
# Table name: bug_reports
#
#  id         :integer          not null, primary key
#  full_name  :string
#  browser    :string
#  device     :integer
#  os         :string
#  problem    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BugReport < ApplicationRecord
  enum device: [:mobile, :tablet, :pc]

	validates :browser, :device, :presence => true
  validate_enum_attributes :device
end
