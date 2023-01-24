# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1858
      module Meta
        include Game::Meta
        DEV_STAGE = :prealpha

        GAME_TITLE = '1858'
        GAME_SUBTITLE = 'The Railways of Iberia'
        GAME_DESIGNER = 'Ian D Wilson'
        GAME_LOCATION = 'Iberia'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://docs.google.com/viewer?a=v&pid=sites&srcid=YWxsLWFib2FyZGdhbWVzLmNvbXxhYWdsbGN8Z3g6NGJmNDUwZjAyOTYwZDJhMg'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
