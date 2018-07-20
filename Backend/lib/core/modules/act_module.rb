module Actable

  def start_playing
    game = Game[@game_id]
    game.get_planets_to_players
    game.set_players_colors
    game.make_planets_not_capitals
    game.start_game
  end

  def shuffle_map
    game = Game[@game_id]
    game.shuffle_map
  end

  def create_bot
    game = Game[@game_id]
    names = get_bot_names
    game.add_player_bot names.sample
  end

  def player_ends_turn array_fleets_hash = []
    player = Player[@player_id]
    save_fleets(array_fleets_hash) unless array_fleets_hash.empty? 
    set_player_ends_turn
  end

  def everybody_ends_turn?
    Game[@game_id].everybody_ends_turn?
  end

private

  def save_fleets array_fleets_hash
    Creation.create_fleets @player_id, array_fleets_hash
  end

  def set_player_ends_turn
    Player[@player_id].end_turn
  end

end