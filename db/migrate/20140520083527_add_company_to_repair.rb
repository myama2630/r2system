class AddCompanyToRepair < ActiveRecord::Migration
  def change
    add_reference :repairs, :company, index: true
    Repair.update_all("company_id = 2")
  end
end
