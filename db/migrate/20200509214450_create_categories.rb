class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.references :game, null: false, foreign_key: {on_delete: :cascade}
      t.string :title
      t.integer :order

      t.timestamps
    end
  end
end
