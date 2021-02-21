# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18EU
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'David Hecht'
        GAME_IMPLEMENTER = 'R. Ryan Driskel'
        GAME_LOCATION = 'Europe'
        GAME_RULES_URL = 'http://www.deepthoughtgames.com/games/18EU/Rules.pdf'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :extra_three_train,
            short_name: 'Extra 3 Train',
            desc: 'Players wishing to try the optional trains might add a single 3'\
                  ' train in the four-player game, and either two 3 trains or a 3 train'\
                  ' and the 4 train in the five or six-player game.',
          },
          {
            sym: :second_extra_three_train,
            short_name: 'Another Extra 3 Train',
            desc: 'See Extra 3 Train',
          },
          {
            sym: :extra_four_train,
            short_name: 'Extra 4 Train',
            desc: 'See Extra 3 Train',
          },
        ].freeze
      end
    end
  end
end
