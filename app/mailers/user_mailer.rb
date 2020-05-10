class UserMailer < ApplicationMailer
  def invite_to_game(user_id, game_id, invited_by_id)
    @user = User.find(user_id)
    @invited_by = User.find(invited_by_id)
    @game = Game.find(game_id)

    mail(to: @user.email, subject: "You've been invited to play a new game!")
  end
end
