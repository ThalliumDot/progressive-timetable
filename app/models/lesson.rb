# == Schema Information
#
# Table name: lessons
#
#  id         :integer          not null, primary key
#  short_name :string
#  long_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Lesson < ApplicationRecord
  has_many :planned_lessons
end
