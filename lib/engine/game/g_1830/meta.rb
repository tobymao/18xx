# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1830
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_DESIGNER = 'Francis Tresham'
        GAME_LOCATION = 'Northeastern USA and Southeastern Canada'
        GAME_PUBLISHER = :lookout
        GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1830re.html_Rules_1830-RE_EN.pdf'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
