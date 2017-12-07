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

  validates :browser, :device, :presence => true
  validate_enum_attributes :device

  enum device: [:mobile, :tablet, :pc]

end
