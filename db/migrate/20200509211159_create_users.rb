class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name_ciphertext
      t.string :name_bidx
      t.string :email_ciphertext
      t.string :email_bidx
      t.string :site_role, default: "user"

      t.timestamps
    end

    add_index :users, :email_bidx, unique: true
  end
end
