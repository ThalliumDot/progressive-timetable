class SeparateFildsInParsedLessons < ActiveRecord::Migration[5.1]
  def up
    add_column :parsed_lessons, :lesson_id, :integer, {null: false}
    add_column :parsed_lessons, :teacher_id, :integer, {null: false}
    remove_column :parsed_lessons, :short_name
    remove_column :parsed_lessons, :long_name
    remove_column :parsed_lessons, :teacher
  end

  def down
    remove_column :parsed_lessons, :lesson_id
    remove_column :parsed_lessons, :teacher_id
    add_column :parsed_lessons, :short_name, :string
    add_column :parsed_lessons, :long_name, :string
    add_column :parsed_lessons, :teacher, :string
  end
end
