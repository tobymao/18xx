# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1713Menorca
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_SUBTITLE  = 'Menorca under British Rule'
        GAME_DESIGNER  = 'Jordi Salord'
        GAME_IMPLEMENTER  = 'Jordi Salord'
        GAME_LOCATION  = 'Menorca, Spain'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://18xx.cat/1713menorca'
        GAME_INFO_URL = 'https://18xx.cat/1713menorca'

        PLAYER_RANGE = [2, 3].freeze
      end
    end
  end
end
