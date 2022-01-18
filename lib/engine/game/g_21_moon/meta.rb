# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G21Moon
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_SUBTITLE = nil
        GAME_DESIGNER = 'Jonas Jones'
        GAME_LOCATION = 'The Moon'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1830re.html_Rules_1830-RE_EN.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/21Moon'

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [].freeze
      end
    end
  end
end
