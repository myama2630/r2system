class AddPurachaspriceToRepairs < ActiveRecord::Migration
  def change
    add_column :repairs, :purachase_price, :integer
  end
end
