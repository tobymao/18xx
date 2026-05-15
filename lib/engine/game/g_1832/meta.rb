# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1832
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1850'

        GAME_SUBTITLE = 'The South'
        GAME_DESIGNER = 'W. R. Dixon'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1832'
        GAME_LOCATION = 'The American South'
        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://drive.google.com/file/d/1LQCQbf4r5isUuPqK6mILUz89iNwK0ARx/view?usp=sharing'

        PLAYER_RANGE = [2, 7].freeze
        OPTIONAL_RULES = [
          {
            sym: :finish_on_400,
            short_name: '$400 Finish',
            desc: 'Game ends immediately when any corporation\'s share price reaches $400.',
          },
          {
            sym: :diesels,
            short_name: 'Diesels',
            desc: '8- and 10-trains are removed. 12-trains become 1830-style Diesels available '\
                  'after the first 6-train. A train may be traded in on a Diesel for a $300 credit. '\
                  '5-trains are permanent.',
          },
          {
            sym: :southern_bank,
            short_name: 'Southern Bank',
            desc: 'Adds P6, the Southern Bank private company. Starting capital increases to '\
                  '$2400 divided by the number of players. This private currently does not do '\
                  'anything special except give revenue of $10 per round.',
          },
          {
            sym: :historical_order,
            short_name: 'Historical Order',
            desc: 'Corporations must start in historical order. A corporation\'s 6th share may not '\
                  'be purchased until all predecessor corporations have sold 6 shares.',
          },
          {
            sym: :no_mergers,
            short_name: 'No Mergers',
            desc: 'Disables all merger rules.',
          },
        ].freeze
      end
    end
  end
end
