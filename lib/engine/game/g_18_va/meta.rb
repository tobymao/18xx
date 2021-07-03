# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18VA
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_SUBTITLE = 'The Railroads Come to Virginia'
        GAME_DESIGNER = 'David Hecht'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18VA'
        GAME_LOCATION = 'Virginia, US'
        GAME_RULES_URL = 'https://www.deepthoughtgames.com/games/18VA/Rules.pdf'

        PLAYER_RANGE = [2, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :two_player_share_limit,
            short_name: '(2p only) 70% Corporation Holding Limit',
            desc: 'When enabled, in a 2p game a player can hold up to 70% of a corporation\'s shares',
          },
        ].freeze
      end
    end
  end
end
