class CreateUsersGamesJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_table :user_games do |t|
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.references :game, null: false, foreign_key: {on_delete: :cascade}
      t.string :role, default: "player"
      t.integer :order

      t.timestamps
    end

    add_index :user_games, [:user_id, :game_id], unique: true
  end
end
