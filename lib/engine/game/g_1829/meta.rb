# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1829
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'Railways in Britain'
        GAME_DESIGNER = 'Francis Tresham'
        GAME_LOCATION = 'South England'
        GAME_PUBLISHER = 'Hartland Trefoil Ltd.'
        GAME_RULES_URL = ''

        PLAYER_RANGE = [3, 9].freeze
      end
    end
  end
end
