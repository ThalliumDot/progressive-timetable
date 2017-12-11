class RenameParsedLessonToPlannedLesson < ActiveRecord::Migration[5.1]
  def up
    rename_table :parsed_lessons, :planned_lessons
  end

  def down
    rename_table :planned_lessons, :parsed_lessons
  end
end
