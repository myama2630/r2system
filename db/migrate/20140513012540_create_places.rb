class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.string :category
      t.string :postcode
      t.string :address
      t.string :phone_no
      t.string :destination_name

      t.timestamps
    end
  end
end
