# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1864
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1861'

        GAME_TITLE = '1864: Forty-Niner'
        GAME_ISSUE_LABEL = '1864'
        GAME_DESIGNER = 'TraXX'
        GAME_LOCATION = 'Western USA'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://boardgamegeek.com/boardgame/382235/1864-forty-niner'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1864:-Forty-Niner'

        PLAYER_RANGE = [2, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :deregulation,
            short_name: 'Deregulation',
            desc: 'During the final three Operating Rounds there is no train limit',
          },
          {
            sym: :train_trade_in,
            short_name: 'Train Trade-in',
            desc: 'In Phase 8, Major Companies may exchange a train to get a 50% discount of its face value '\
                  'on another train',
          },
          {
            sym: :no_starting_locations,
            short_name: 'No Pre-determined Starting Locations',
            desc: 'Minor Companies have no home locations; the player starting the auction for a Minor Company '\
                  'chooses its location',
          },
          {
            sym: :open_consists,
            short_name: 'Open UP consists',
            desc: 'All five Union Pacific train consist cards are revealed at the start of the game, '\
                  'rather than at the start of each phase',
          },
        ].freeze
      end
    end
  end
end
