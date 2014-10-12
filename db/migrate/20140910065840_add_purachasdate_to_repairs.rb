class AddPurachasdateToRepairs < ActiveRecord::Migration
  def change
    add_column :repairs, :purachase_date, :date
  end
end
