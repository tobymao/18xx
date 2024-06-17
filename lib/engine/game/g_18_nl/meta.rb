# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18NL
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Helmut Ohley'
        GAME_LOCATION = 'The Netherlands'
        GAME_RULES_URL = 'http://ohley.de/18nl/1830NLSummaryofrules.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18NL'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
