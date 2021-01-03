# frozen_string_literal: true

require_relative 'g_1817'
require_relative '../config/game/g_18_usa'

module Engine
  module Game
    class G18USA < G1817
      load_from_json(Config::Game::G18USA::JSON)

      DEV_STAGE = :prealpha
      GAME_PUBLISHER = :all_aboard_games
      PITTSBURGH_PRIVATE_NAME = 'DTC'
      PITTSBURGH_PRIVATE_HEX = 'F14'

      GAME_LOCATION = 'United States'
      SEED_MONEY = 200
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18USA'
      GAME_RULES_URL = {
        '18USA' => 'https://boardgamegeek.com/filepage/145024/18usa-rules',
        '1817 Rules' => 'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
      }.freeze
      # Alphabetized. Not sure what official ordering is
      GAME_DESIGNER = 'Edward Reece, Mark Hendrickson, and Shawn Fox'

      def self.title
        '18USA'
      end
    end
  end
end
