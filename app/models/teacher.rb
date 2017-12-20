# == Schema Information
#
# Table name: teachers
#
#  id              :integer          not null, primary key
#  first_name      :string
#  last_name       :string
#  middle_name     :string
#  academic_degree :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Teacher < ApplicationRecord
  has_many :planned_lessons

  def full_name
    return "#{self.last_name} #{self.first_name} #{self.middle_name}"
  end

  def surname_initials
    return "#{self.last_name} #{self.first_name.first}. #{self.middle_name.first}."
  end
end
