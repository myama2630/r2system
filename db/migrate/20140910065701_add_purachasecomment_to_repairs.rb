class AddPurachasecommentToRepairs < ActiveRecord::Migration
  def change
    add_column :repairs, :purachase_comment, :text
  end
end
