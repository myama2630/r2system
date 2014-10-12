class AddChargedateToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :charge_date, :date
  end
end
