class Add20140128colsToRepairs < ActiveRecord::Migration
  def change
    add_column :repairs, :billing_id, :integer
    add_column :repairs, :billing_date, :date
    add_column :repairs, :payment_id, :integer
    add_column :repairs, :payment_date, :date
  end
end
