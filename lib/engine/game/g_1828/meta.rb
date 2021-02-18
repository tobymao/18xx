# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1828
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_IMPLEMENTER = 'Chris Rericha based on 1828 by J C Lawrence'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1828.Games'
        GAME_LOCATION = 'North East, USA'
        GAME_RULES_URL = 'https://kanga.nu/~claw/1828/1828-Rules.pdf'
        GAME_TITLE = '1828.Games'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
