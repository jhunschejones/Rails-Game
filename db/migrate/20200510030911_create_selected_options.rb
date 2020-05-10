class CreateSelectedOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :selected_options do |t|
      t.references :turn, null: false, foreign_key: {on_delete: :cascade}
      t.references :option, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
