class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.boolean :charge_flg
      t.integer :charge_price
      t.string :charge_comment
      t.references :repair, index: true
      t.references :engine, index: true

      t.timestamps
    end
  end
end
