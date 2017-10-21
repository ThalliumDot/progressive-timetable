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
  has_many   :lessons

  def self.find_by_or_create(group_name, course)
    group = self.find_by(name: group_name)
    if group.blank?
      group = self.create!(name: group_name, course: course)
    end
    return group
  end

end
