# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1830/meta'

module Engine
  module Game
    module G1830Plus
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'Railways & Robber Barons'
        GAME_DESIGNER = 'Francis Tresham'
        GAME_LOCATION = 'Northeastern USA and Southeastern Canada'
        GAME_PUBLISHER = :lookout
        GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1830re.html_Rules_1830-RE_EN.pdf'

        PLAYER_RANGE = [2, 7].freeze
        GAME_TITLE = '1830+'
        DEPENDS_ON = '1830'
        GAME_SUBTITLE = nil
        OPTIONAL_RULES = [
          {
            sym: :multiple_brown_from_ipo,
            short_name: 'Buy Multiple Brown Shares From IPO',
            desc: 'Mutiple brown shares may be bought from IPO as well as from pool',
          },
        ].freeze
      end
    end
  end
end
