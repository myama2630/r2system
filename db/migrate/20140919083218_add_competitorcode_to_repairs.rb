class AddCompetitorcodeToRepairs < ActiveRecord::Migration
  def change
    add_column :repairs, :competitor_code, :string
  end
end
