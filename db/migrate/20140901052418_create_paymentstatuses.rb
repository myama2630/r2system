class CreatePaymentstatuses < ActiveRecord::Migration
  def change
    create_table :paymentstatuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
