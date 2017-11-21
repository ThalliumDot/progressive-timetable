class ChangeTypeToLessonType < ActiveRecord::Migration[5.1]
  def change
    rename_column :lessons, :type, :lesson_type
  end
end
