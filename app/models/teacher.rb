class Teacher < ApplicationRecord
  has_many :parsed_lessons

  def full_name
    return "#{self.last_name} #{self.first_name} #{self.middle_name}"
  end

  def surname_initials
    return "#{self.last_name} #{self.first_name.first}. #{self.middle_name.first}."
  end
end
