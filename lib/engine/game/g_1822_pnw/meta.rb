# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822PNW
      module Meta
        include Game::Meta

        DEV_STAGE = :beta
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = nil
        GAME_DESIGNER = 'Ken Kuhn'.freeze
        GAME_IMPLEMENTER = 'Michael Alexander'.freeze
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822PNW'.freeze
        GAME_LOCATION = 'Pacific Northwest'.freeze
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/thread/2890404/1822pnw-public-rules-review'.freeze
        GAME_TITLE = '1822PNW'.freeze

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :remove_two_ls,
            short_name: 'Remove two L/2 trains',
          },
          {
            sym: :remove_three_ls,
            short_name: 'Remove three L/2 trains',
          },
        ].freeze

        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)
          return if !optional_rules.include?(:remove_two_ls) || !optional_rules.include?(:remove_three_ls)

          { error: 'Cannot use both L/2 Train Roster Adjustment Variants' }
        end
      end
    end
  end
end
