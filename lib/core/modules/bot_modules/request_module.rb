require "uri"
require "net/http"

module RequestModule

AI_URL = ENV["SPACEPAL_AISERVICE_URL"] or 'http://localhost:3131'
CALLBACK_URL = ENV.fetch("SPACEPAL_CALLBACK_URL") { "http://localhost:3000" }

  def get_bot_names
    response_string = Net::HTTP.get(URI.parse(AI_URL + '/ai/names'), nil)
    response = JSON.parse response_string
    response["all"]
  end

  def post_info_to_bot
    game = Game[@game_id]
    ai_players = game.bots.map do |bot|
      unless bot.end_turn? or bot.game_over?
      {
        "playerID" => bot.id.to_i,
        "aiName" => bot.ai_name
      }
      end
    end
    ai_players.compact!
    if ai_players.count > 0
      
      data = {
        "callback" => "#{CALLBACK_URL}/api/games/#{game.id}/steps/#{game.step}",
        "aiPlayers" => ai_players,
        "map" => game.map_size,
        "planets" => game.planets_info
      }
      response_string = Net::HTTP.post(URI.parse(AI_URL + '/ai/do'), data.to_json)
      response_string.body.bg(:yellow).color(:black).out
    end
  end

end
