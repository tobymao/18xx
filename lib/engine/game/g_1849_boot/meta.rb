# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1849Boot
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true
        DEPENDS_ON = '1849'

        GAME_DESIGNER = 'Scott Petersen (Based on 1849 by Federico Vellani)'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849#variants-and-optional-rules'
        GAME_LOCATION = 'Southern Italy'
        GAME_RULES_URL = {
          '1849 Rules' => 'https://boardgamegeek.com/filepage/206628/1849-rules',
          '1849: Kingdom of the Two Sicilies Rules Differences' => 'https://docs.google.com/document/d/1gNn2RmtcPWh0KpNduv3p0Lraa3iWIAV3cWcHpCu8X-E/edit',
          'Playtest Forum (BoardGameGeek)' => 'https://boardgamegeek.com/thread/2582803/1849-kingdom-two-sicilies-playtest-feedback',
          'Submit Direct Feedback (AAG Contact Form)' => 'https://all-aboardgames.com/pages/order-questions',
        }.freeze
        GAME_TITLE = '1849: Kingdom of the Two Sicilies'
        GAME_ISSUE_LABEL = '1849'
        GAME_ALIASES = ['1849K2S'].freeze

        PLAYER_RANGE = [4, 6].freeze
      end
    end
  end
end
