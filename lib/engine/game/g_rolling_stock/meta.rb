# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module GRollingStock
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_TITLE = 'Rolling Stock'
        GAME_SUBTITLE = ''
        GAME_DESIGNER = 'Björn Rabenstein'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'http://rabenste.in/rollingstock/rules.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/RollingStock'

        PLAYER_RANGE = [3, 5].freeze

        GAME_VARIANTS = [
          sym: :stars,
          name: 'Rolling Stock Stars',
          title: 'Rolling Stock Stars',
          desc: 'Latest version of Rolling Stock',
        ].freeze

        OPTIONAL_RULES = [
          {
            sym: :short,
            short_name: 'Short Game',
            desc: 'Shorter game with reduced company deck',
          },
        ].freeze
      end
    end
  end
end
