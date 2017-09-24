class Group < ApplicationRecord

  belongs_to :faculty
  has_many   :lessons

end