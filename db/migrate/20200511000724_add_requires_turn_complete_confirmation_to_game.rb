class AddRequiresTurnCompleteConfirmationToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :requires_turn_complete_confirmation, :boolean, default: false
  end
end
