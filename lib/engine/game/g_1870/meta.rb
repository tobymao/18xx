# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1870
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Railroading across the Trans Mississippi'
        GAME_DESIGNER = 'Bill Dixon'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1870'
        GAME_LOCATION = 'Mississippi, USA'
        GAME_RULES_URL = 'http://www.hexagonia.com/rules/MFG_1870.pdf'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :diesels,
            short_name: 'Diesels variant (Alpha)',
            desc: 'Diesel trains replace 8, 10, and 12 trains. Uses all 1830 Diesel rules.',
          },
        ].freeze
      end
    end
  end
end
