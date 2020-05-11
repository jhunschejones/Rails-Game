class ApplicationController < ActionController::Base
  add_flash_types :success
  before_action :authenticate_user!

  def authorize_user_game_access
    redirect_to(games_path, notice: "You do not have access to that game") unless current_user.can_access_game?(params[:game_id] || params[:id])
  end

  def authorize_user_game_edit
    redirect_to(games_path, notice: "You are not allowed to modify that game") unless current_user.can_edit_game?(params[:game_id] || params[:id])
  end

  # Overwriting the sign_out redirect path method in devise
  # https://github.com/heartcombo/devise/wiki/How-To:-Change-the-redirect-path-after-destroying-a-session-i.e.-signing-out
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
