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

        PLAYER_RANGE = [2, 7].freeze
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
            sym: :original_rules,
            short_name: "Bill Dixon's original rules",
            desc: "Selecting this option will enable all of the options below, to play by Dixon's original rules for the game.",
          },
          {
            sym: :station_wars,
            short_name: 'Station Marker Wars',
            desc: 'Destination tokens on non-offboard hexes now use up a token space. A new space is created if '\
                  'no space is available, but if the tile is later upgraded and a new token space would be opened, the '\
                  'destination token will fill that space.',
          },
          {
            sym: :original_tiles,
            short_name: 'Original, more restrictive tile set',
            desc: "This is the tile set included in Bill Dixon's original rules for the game.",
          },
          {
            sym: :max_reissue_200,
            short_name: 'Maximum reissue $200',
            desc: 'Limits the maximum price that a corporation can reissue shares at to $200.',
          },
          {
            sym: :can_protect_if_sold,
            short_name: 'Original price protection rules',
            desc: 'Allows a player to price protect a corporation even if they sold shares of that corporation '\
                  'during the current SR.',
          },
          {
            sym: :original_market,
            short_name: 'Original market',
            desc: 'The stock market is as originally designed by Bill Dixon, identical to the market in 1832 and 1850.',
          },
        ].freeze
      end
    end
  end
end
