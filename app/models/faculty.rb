# == Schema Information
#
# Table name: faculties
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Faculty < ApplicationRecord

  has_many :groups

  def self.find_by_or_create(faculty_name)
    faculty = self.find_by(name: faculty_name)
    if faculty.blank?
      faculty = self.create!(name: faculty_name)
    end
    return faculty
  end

end
