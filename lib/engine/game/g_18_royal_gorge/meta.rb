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
      end
    end
  end
end
