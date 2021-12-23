# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18NY
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_DESIGNER = 'Pierre LeBoeuf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18NY'
        GAME_LOCATION = 'New York, USA'
        GAME_RULES_URL = 'https://docs.google.com/document/d/1Pz0f1Sr0uhlSpOuuXbu4OaDKIgteIyuGN55XOOLJrb0'
        GAME_TITLE = '18NY'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :fivede,
            short_name: '5DE only scores stations and offboards',
            desc: '5DE trains may only score stationed cities and offboard hexes',
          },
        ].freeze
      end
    end
  end
end
