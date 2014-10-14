class AddCompanyIdToPlace < ActiveRecord::Migration
  def change
    add_column :places, :company_id, :integer
  end
end
