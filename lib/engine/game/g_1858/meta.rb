# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1858
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Ian D Wilson'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1858'
        GAME_LOCATION = 'Iberian Peninsula'
        GAME_PUBLISHER = [:all_aboard_games].freeze
        GAME_RULES_URL = 'https://docs.google.com/viewer?a=v&pid=sites&srcid=YWxsLWFib2FyZGdhbWVzLmNvbXxhYWdsbGN8Z3g6NGJmNDUwZjAyOTYwZDJhMg'
        GAME_SUBTITLE = 'The Railways of Iberia'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
