class CreateLessons < ActiveRecord::Migration[5.1]
  def change
    create_table :lessons do |t|
      t.string :short_name
      t.string :long_name

      t.timestamps
    end
  end
end
