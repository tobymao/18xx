# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1854
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Leonhard "Lonny" Orgler'
        GAME_LOCATION = 'Austria'
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1854_1854.html_Rules_1854_EN.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1854'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
