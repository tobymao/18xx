# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822PNW
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '1822'

        GAME_SUBTITLE = nil
        GAME_DESIGNER = 'Ken Kuhn'.freeze
        GAME_IMPLEMENTER = 'Michael Alexander'.freeze
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822PNW'.freeze
        GAME_LOCATION = 'Pacific Northwest'.freeze
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/269597/1822pnw-rules'.freeze
        GAME_TITLE = '1822PNW'.freeze

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :starting_packet,
            short_name: 'Starting Packet Variant',
            desc: 'Quick start setup for players new to 1822/1822PNW to jump right into operating round action.',
          },
          {
            sym: :remove_two_ls,
            short_name: 'Remove two L/2 trains',
          },
          {
            sym: :remove_three_ls,
            short_name: 'Remove three L/2 trains',
          },
        ].freeze

        GAME_VARIANTS = [
          {
            sym: :short,
            name: 'Short Scenario',
            title: '1822PNW Short Scenario',
          },
          {
            sym: :srs,
            name: 'Southern Regional Scenario',
            title: '1822PNW SRS',
            desc: '(2-3 players) shorter game using only companies on the southern part of the map',
          },
        ].freeze

        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)
          remove_two = optional_rules.include?(:remove_two_ls)
          remove_three = optional_rules.include?(:remove_three_ls)
          if optional_rules.include?(:starting_packet) && (remove_two || remove_three)
            { error: 'Cannot use L/2 Train Roster Adjustment with the Starting Packet Variant' }
          elsif remove_two && remove_three
            { error: 'Cannot use both L/2 Train Roster Adjustment Variants' }
          end
        end
      end
    end
  end
end
