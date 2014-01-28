class AddCols20140124ToRepairs < ActiveRecord::Migration
  def change
    add_column :repairs, :requestpaper, :string
    add_column :repairs, :checkpaper, :string
  end
end
