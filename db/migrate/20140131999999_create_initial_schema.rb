class CreateInitialSchema < ActiveRecord::Migration
  def change
    #drop_table :businessstatuses

    #drop_table :companies

    #drop_table :enginemodels

    #drop_table :engineorders

    #drop_table :engines

    #drop_table :enginestatuses

    #drop_table :repairs

    #drop_table :users
    
    create_table :businessstatuses do |t|
      t.string   :name
      t.timestamps
    end

    create_table :companies do |t|
      t.string   :name
      t.string   :category
      t.string   :postcode
      t.string   :address
      t.string   :phone_no
      t.string   :destination_name
      t.timestamps
    end

    create_table :enginemodels do |t|
      t.string   :modelcode
      t.string   :name
      t.timestamps
    end

    create_table :engineorders do |t|
      t.string   :issue_no
      t.date     :inquiry_date
      t.integer  :registered_user_id
      t.integer  :updated_user_id
      t.integer  :branch_id
      t.integer  :salesman_id
      t.integer  :install_place_id
      t.string   :orderer
      t.string   :machine_no
      t.integer  :time_of_running
      t.text     :change_comment
      t.date     :order_date
      t.integer  :sending_place_id
      t.text     :sending_comment
      t.date     :desirable_delivery_date
      t.integer  :businessstatus_id
      t.integer  :new_engine_id
      t.integer  :old_engine_id
      t.date     :shipped_date
      t.date     :day_of_test
      t.string   :title
      t.date     :returning_date
      t.text     :returning_comment
      t.string   :invoice_no_new
      t.string   :invoice_no_old
      t.integer  :returning_place_id
      t.text     :shipped_comment
      t.date     :allocated_date
      t.timestamps
    end

    create_table :engines do |t|
      t.string   :engine_model_name
      t.string   :sales_model_name
      t.string   :serialno
      t.integer  :enginestatus_id
      t.integer  :company_id
      t.boolean  :suspended
      t.timestamps
    end

    create_table :enginestatuses do |t|
      t.string   :name
      t.timestamps
    end

    create_table :repairs do |t|
      t.string   :issue_no
      t.date     :issue_date
      t.date     :arrive_date
      t.date     :start_date
      t.date     :finish_date
      t.text     :before_comment
      t.text     :after_comment
      t.integer  :time_of_running
      t.date     :day_of_test
      t.text     :arrival_comment
      t.string   :order_no
      t.date     :order_date
      t.string   :construction_no
      t.date     :desirable_finish_date
      t.date     :estimated_finish_date
      t.integer  :engine_id
      t.date     :shipped_date
      t.string   :requestpaper
      t.string   :checkpaper
      t.timestamps
    end

    create_table :users do |t|
      t.string   :email, null: false, default: ""
      t.string   :encrypted_password, null: false, default: ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, null: false, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.string   :userid
      t.string   :name
      t.string   :category
      t.integer  :company_id
      t.timestamps
    end

    add_index :users, [:email], unique: true
    add_index :users, [:reset_password_token], unique: true
    add_index :users, [:userid], unique: true
  end
end
