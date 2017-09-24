# == Schema Information
#
# Table name: lessons
#
#  id         :integer          not null, primary key
#  short_name :string
#  long_name  :string
#  type       :string
#  teacher    :string
#  dates      :integer          default([]), is an Array
#  timing     :jsonb
#  group_id   :integer
#  classroom  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Lesson < ApplicationRecord

  # should live (in future) in Rails config or somewhere...
  LESSONS = {
    "1" => {
      starts_at: "8:00",
      ends_at:   "9:35"
    },
    "2" => {
      starts_at: "9:45",
      ends_at:   "11:20"
    }
  }

  belongs_to :group

  

end
