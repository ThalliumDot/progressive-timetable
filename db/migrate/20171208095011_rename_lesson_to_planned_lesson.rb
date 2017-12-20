class RenameLessonToPlannedLesson < ActiveRecord::Migration[5.1]
  def up
    rename_table :lessons, :parsed_lessons
  end

  def down
    rename_table :parsed_lessons, :lessons
  end
end
