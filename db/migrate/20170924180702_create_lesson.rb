class CreateLesson < ActiveRecord::Migration[5.1]
  def change
    create_table :lessons do |t|
      t.string  :short_name
      t.string  :long_name
      t.string  :type
      t.string  :teacher
      t.integer :dates, array: true, default: []
      t.jsonb   :timing, default: {}
      t.integer :group_id
      t.string  :classroom

      t.timestamps
    end
  end
end
