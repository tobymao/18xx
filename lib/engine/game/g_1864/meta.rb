# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1864
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1861'

        GAME_SUBTITLE = 'Railroading in the Western United States'
        GAME_DESIGNER = 'TraXX'
        GAME_LOCATION = 'Western USA'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://boardgamegeek.com/boardgame/389016/1864-forty-niner'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1864'

        PLAYER_RANGE = [2, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :deregulation,
            short_name: 'Deregulation',
            desc: 'During the final three Operating Rounds there is no train limit, '\
                  'and the 2+2 and 5+5E trains are unlimited',
          },
        ].freeze
      end
    end
  end
end
