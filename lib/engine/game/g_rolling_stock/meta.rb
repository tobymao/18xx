# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module GRollingStock
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_TITLE = 'Rolling Stock'
        GAME_ISSUE_LABEL = 'RollingStock'

        GAME_DESIGNER = 'Björn Rabenstein'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'http://rabenste.in/rollingstock/rules.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/Rolling-Stock'
        AUTOROUTE = false

        PLAYER_RANGE = [2, 6].freeze

        GAME_VARIANTS = [
          sym: :stars,
          name: 'Rolling Stock Stars',
          title: 'Rolling Stock Stars',
          desc: 'Latest version of Rolling Stock',
          default: true,
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
