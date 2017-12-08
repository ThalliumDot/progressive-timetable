# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  name       :string
#  course     :integer
#  faculty_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Group < ApplicationRecord

  belongs_to :faculty
  has_many   :parsed_lessons

end
