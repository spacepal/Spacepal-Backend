class Api::GameController < ApplicationController
  def index
    arr = Game.get_all :offset => params[:offset], :limit => params[:limit]
    render :json => { games: arr, :count => $redis.zcard("game:ids") }
  end

  def create
    data = self.game_params
    player = Creation.create_player data[:username]
    if !player.errors.empty?
      render :json => { errors: player.errors.messages }
    end
    flags = {}
    flags[:has_pin_code] = data[:flags][:hasPinCode]
    flags[:buffs] = data[:flags][:buffs]
    flags[:production_after_capture] = data[:flags][:productionAfterCapture]
    flags[:pirates] = data[:flags][:pirates]
    flags[:accumulative] = data[:flags][:accumulative]
    game = Creation.create_game player, data[:gamename],
      data[:map], data[:playersLimit], data[:planetsCount],
      data[:pinCode], flags
    game.players.all.to_s.color(:green).out
    if !game.errors.empty?
      render :json => { errors: game.errors.messages }
    else
      render :json => { errors: nil, gameID: game.id }
    end
  end

  def join
    game_id = params[:id]
    data = self.game_params
    game = Game.find game_id
    if !game
      render :json => { errors: ("can't find game with id " + game.id.to_s) }
    end
    if game.is_room?
      if game.pin_code
        if data[:pinCode] != game.pin_code
          render :json => { errors: "the pin code is wrong"}
        end
      end
      if game.add_player data[:username]
        render :json => { errors: nil }
      else
        render :json => { errors: game.errors.messages }
      end
    else
      render :json => { errors: "the game was started"}
    end
  end

  def game_params
    params.require(:data).permit!
  end
end
