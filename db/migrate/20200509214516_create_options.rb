class CreateOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :options do |t|
      t.references :category, null: false, foreign_key: {on_delete: :cascade}
      t.text :description

      t.timestamps
    end
  end
end
