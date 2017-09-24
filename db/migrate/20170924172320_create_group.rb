class CreateGroup < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string  :name
      t.integer :course
      t.integer :faculty_id, null: false

      t.timestamps
    end
  end
end
