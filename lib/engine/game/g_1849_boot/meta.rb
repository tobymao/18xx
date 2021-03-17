# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1849Boot
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha
        DEPENDS_ON = '1849'

        GAME_DESIGNER = 'Scott Petersen (Based on 1849 by Federico Vellani)'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849#variants-and-optional-rules'
        GAME_LOCATION = 'Southern Italy'
        GAME_RULES_URL = 'https://docs.google.com/document/d/1gNn2RmtcPWh0KpNduv3p0Lraa3iWIAV3cWcHpCu8X-E/edit'
        GAME_TITLE = '1849: Kingdom of the Two Sicilies'
        GAME_ALIASES = ['1849K2S'].freeze

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
