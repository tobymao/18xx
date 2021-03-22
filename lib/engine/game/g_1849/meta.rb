# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1849
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'The Game of Sicilian Railways'
        GAME_DESIGNER = 'Federico Vellani'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849'
        GAME_LOCATION = 'Sicily'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/206628/1849-rules'

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :delay_ift,
            short_name: 'Delay IFT',
            desc: 'IFT may not be one of the first three corporations (recommended for newer players)',
          },
        ].freeze
      end
    end
  end
end
