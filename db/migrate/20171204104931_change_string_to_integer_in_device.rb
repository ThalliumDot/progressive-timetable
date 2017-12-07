class ChangeStringToIntegerInDevice < ActiveRecord::Migration[5.1]
  def change
  	change_column :bug_reports, :device, 'integer USING CAST(device AS integer)'
  end
end
