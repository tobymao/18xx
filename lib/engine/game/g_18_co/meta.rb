# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18CO
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'Rock & Stock'
        GAME_DESIGNER = 'R. Ryan Driskel'
        GAME_IMPLEMENTER = 'R. Ryan Driskel'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18CO:-Rock-&-Stock'
        GAME_LOCATION = 'Colorado, USA'
        GAME_RULES_URL = 'https://drive.google.com/file/d/16W5v3w__GW4CzXQ9QeQERYVnbkdRDqg1/view'

        PLAYER_RANGE = [3, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :priority_order_pass,
            short_name: 'Priority Order Pass',
            desc: 'Priority is awarded in pass order in both Auction and Stock Rounds.',
          },
          {
            sym: :pay_per_trash,
            short_name: 'Pay Per Trash',
            desc: 'Selling multiple shares before a corporation\'s first Operating Round '\
                  'returns the amount listed in each movement down on the market, starting '\
                  'at the current share price.',
          },
          {
            sym: :major_investors,
            short_name: 'Major Investors',
            desc: 'The Presidency cannot be transferred to another player during Corporate Share Buying.',
          },
        ].freeze
      end
    end
  end
end
