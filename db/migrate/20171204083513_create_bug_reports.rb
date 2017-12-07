class CreateBugReports < ActiveRecord::Migration[5.1]
  def change
    create_table :bug_reports do |t|
      t.string :full_name
      t.string :browser
      t.string :device
      t.string :os
      t.text :problem

      t.timestamps
    end
  end
end
