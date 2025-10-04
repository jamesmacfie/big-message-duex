class FavoritesController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email

  def create
    @channel = Channel.find(params[:channel_id])
    @favorite = current_user.person.favorites.find_or_create_by(channel: @channel)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @channel }
    end
  end

  def destroy
    @favorite = current_user.person.favorites.find(params[:id])
    @channel = @favorite.channel
    @favorite.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @channel }
    end
  end
end
