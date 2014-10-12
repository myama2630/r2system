class CreateContactinfos < ActiveRecord::Migration
  def change
    create_table :contactinfos do |t|
      t.string :mailaddr
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
