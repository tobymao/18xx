# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1832
      module Meta
        include Game::Meta

        DEPENDS_ON = '1850'

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Bill Dixon'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1832'
        GAME_LOCATION = 'Southern States, USA'
        PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://drive.google.com/file/d/1LQCQbf4r5isUuPqK6mILUz89iNwK0ARx/view?usp=sharing'

        PLAYER_RANGE = [3, 7].freeze
        OPTIONAL_RULES = [
          {
            sym: :game_end_on_400_stock_price,
            short_name: 'End game if stock price hits 400',
            desc: 'Game will end after the operating turn of a company with share value of 400',
          },
          {
            sym: :diesel_trains,
            short_name: 'Use 1830-style diesels',
            desc: 'Instead of 8, 10, and 12 trains — use Diesels',
          },
        ].freeze
      end
    end
  end
end
