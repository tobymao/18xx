# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1870
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Railroading across the Trans Mississippi'
        GAME_DESIGNER = 'Bill Dixon'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1870'
        GAME_LOCATION = 'Mississippi, USA'
        GAME_RULES_URL = 'http://www.hexagonia.com/rules/MFG_1870.pdf'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :diesels,
            short_name: 'Diesels variant (Alpha)',
            desc: 'Diesel trains replace 8, 10, and 12 trains. Uses all 1830 Diesel rules.',
          },
          {
            sym: :finish_on_400,
            short_name: '$400 Finish',
            desc: 'Game ends as soon as a corporation hits 400 on the stock market. No further operations.',
          },
          {
            sym: :station_wars,
            short_name: 'Station Marker Wars',
            desc: 'Destination tokens on non-offboard hexes now use up a token space. A new space is created if '\
                  'no space is available, but if the tile is later upgraded and a new token space would be opened, the '\
                  'destination token will fill that space.',
          },
          {
            sym: :can_protect_if_sold,
            short_name: 'Price protection allowed even if president has sold shares',
            desc: 'Allows the president of a corporation to price protect shares of their company, even if the president has '\
                  'sold shares of the corporation this SR.',
          },
        ].freeze
      end
    end
  end
end
