module Broadcastable

  END_TURN_TYPE = :turn_ended
  GAME_TYPE = :game
  PLAYER_TYPE = :profile
  PLAYERS_TYPE = :players
  FLEETS_TYPE = :fleets
  PLANETS_TYPE = :planets
  NOTIFICATION_TYPE = :notifications

  def broadcast_all_data
    self.broadcast_game
    self.broadcast_players
    self.broadcast_planets
    if @player_id
      self.broadcast_player
      self.broadcast_fleets
    else
      Game[@game_id].players.each do |player|
        self.broadcast_player
        self.broadcast_fleets
      end
    end
  end

  def broadcast_end_turn
    ActionCable.server.broadcast("games:#{@game_id}", { "type" => "turn_ended" })
  end

  def transmitted_player
    player = Player[@player_id]
    player.is_end_turn
    _hash = {
      id: @player_id.to_i,
      username: player.name,
      isCreator: (player.is_admin or false),
      isEndTurn: (player.is_end_turn or false),
      isGameOver: (player.is_game_over or false)
    }
    return { type: PLAYER_TYPE, data: _hash }
  end

  def broadcast_game
    game = Game[@game_id]
    _hash = {
      id: @game_id.to_i,
      name: game.name,
      creator: game.get_creator.name,
      pinCode: game.pin_code,
      mapWidth: game.width,
      mapHeight: game.height,
      planets: game.planets_count,
      playersLimit: game.players_limit,
      buffs: (game.buffs or false),
      pirates: (game.pirates or false),
      accumulative: (game.accumulative or false),
      productionAfterCapture: (game.production_after_capture or false),
      turnNumber: game.step,
      state: game.get_state # STATE_ROOM = 1; STATE_GAME = 2; STATE_END = 3
    }
    ActionCable.server.broadcast("games:#{@game_id}", { type: GAME_TYPE, data: _hash })
  end  

  def broadcast_player
    player = Player[@player_id]
    _hash = {
      id: @player_id.to_i,
      color: player.color_id.to_i,
      username: player.name,
      isCreator: (player.is_admin or false),
      isEndTurn: (player.is_end_turn or false),
      isGameOver: (player.is_game_over or false)
    }
    ActionCable.server.broadcast("players:#{@player_id}", { type: PLAYER_TYPE, data: _hash })
  end

  def broadcast_players
    players = Game[@game_id].players
    arr = players&.map do |player| 
      {
        id: player.id.to_i,
        color: player.color_id.to_i,
        username: player.name,
        isCreator: (player.is_admin or false),
        isArtificialIntelligence: (player.is_ai or false),
        artificialIntelligenceType:  player.ai_type,
        isEndTurn: (player.is_end_turn or false),
        isGameOver: (player.is_game_over or false)
      }
    end
    #{}"colors: es #{arr.pluck(:attributes)}".color(:brown).out
    ActionCable.server.broadcast("games:#{@game_id}", { type: PLAYERS_TYPE, data: { PLAYERS_TYPE => arr }})
  end

  def broadcast_fleets
    fleets = Player[@player_id].fleets
    arr = fleets&.map do |fleet|
      {
        from: fleet.planet_from_id.to_i, # planetID
        to: fleet.planet_to_id.to_i, # planetID
        count: fleet.ships.to_i,
        stepsLeft: fleet.steps_left.to_i
      }
    end
    ActionCable.server.broadcast("players:#{@player_id}", { type: FLEETS_TYPE, data: { FLEETS_TYPE => arr }})
  end

  def broadcast_planets
    planets = Game[@game_id].planets
    arr = planets&.map do |planet|
      {
        id: planet.id.to_i,
        ownerID: (planet.player_id or -1).to_i, # player ID
        cellID: planet.cell.relative_id.to_i, # 1 ... width * height
        production: (planet.production + planet.experience).to_i,
        killPerc: planet.kill_perc.to_f,
        ships: planet.ships.to_i,
        isCapital: (planet.is_capital or false)
      }
    end
    ActionCable.server.broadcast("games:#{@game_id}", { type: PLANETS_TYPE, data: { PLANETS_TYPE => arr }})
  end

end
