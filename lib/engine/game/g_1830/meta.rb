# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1830
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Railways & Robber Barons'
        GAME_DESIGNER = 'Francis Tresham'
        GAME_LOCATION = 'Northeastern USA and Southeastern Canada'
        GAME_PUBLISHER = :lookout
        GAME_RULES_URL = 'https://lookout-spiele.de/upload/en_1830re.html_Rules_1830-RE_EN.pdf'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1830'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :multiple_brown_from_ipo,
            short_name: 'Buy Multiple Brown Shares From IPO',
            desc: 'Multiple brown shares may be bought from IPO as well as from pool',
          },
        ].freeze
      end
    end
  end
end
