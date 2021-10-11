# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18MS
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'The Railroads Come to Mississippi'
        GAME_DESIGNER = 'Mark Derrick'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18MS'
        GAME_LOCATION = 'Mississippi, USA'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/209791'

        PLAYER_RANGE = [2, 4].freeze
        OPTIONAL_RULES = [
          {
            sym: :or_11,
            short_name: '11 ORs',
            desc: 'There is an extra, final, OR, directly after OR 10',
          },
          {
            sym: :allow_buy_rusting,
            short_name: 'Allow buy rusting',
            desc: 'A corporation is allowed to buy trains that are to be rusted, even if they have already run this OR',
          },
        ].freeze
      end
    end
  end
end
