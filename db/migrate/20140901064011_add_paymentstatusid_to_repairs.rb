class AddPaymentstatusidToRepairs < ActiveRecord::Migration
  def change
    add_column :repairs, :paymentstatus_id, :integer
  end
end
