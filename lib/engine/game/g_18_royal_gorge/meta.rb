# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18RoyalGorge
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        PROTOTYPE = true

        GAME_SUBTITLE = 'The Rails of Fremont County and the Royal Gorge Wars'
        GAME_DESIGNER = 'Kayla Ross & Denman Scofield'
        GAME_LOCATION = 'Colorado, USA'
        GAME_PUBLISHER = :wood_18
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/284918/graphic-rulebook-preliminary'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18RoyalGorge'

        PLAYER_RANGE = [2, 4].freeze

        OPTIONAL_RULES = [
          {
            sym: :shorter_game_end,
            short_name: 'Shorter Game End',
            desc: "When the first 6x2-train triggers the game end, don't play an additional set of ORs.",
          },
        ].freeze
      end
    end
  end
end
