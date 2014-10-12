class AddSalesamountToEngineorders < ActiveRecord::Migration
  def change
    add_column :engineorders, :sales_amount, :integer
  end
end
