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

  belongs_to :group

end
