# frozen_string_literal: true

require_relative 'g_1817'
require_relative '../config/game/g_1817_na'

module Engine
  module Game
    class G1817NA < G1817
      load_from_json(Config::Game::G1817NA::JSON)

      DEV_STAGE = :production
      GAME_PUBLISHER = nil
      PITTSBURGH_PRIVATE_NAME = 'DTC'
      PITTSBURGH_PRIVATE_HEX = 'F14'

      GAME_LOCATION = 'North America'
      SEED_MONEY = 150
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1817NA'
      GAME_RULES_URL = {
        '1817NA' => 'https://docs.google.com/document/d/1b1qmHoyLnzBo8SRV8Ff17iDWnB7UWNbIsOyDADT0-zY/view',
        '1817 Rules' => 'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
      }.freeze
      GAME_DESIGNER = 'Mark Voyer'
      LOANS_PER_INCREMENT = 4

      def self.title
        '1817NA'
      end
    end
  end
end
