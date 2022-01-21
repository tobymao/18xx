# frozen_string_literal: true

require_relative '../g_1846/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18MO
      class Game < G1846::Game
        include_meta(G18MO::Meta)
        include G18MO::Entities
        include G18MO::Map

        ORANGE_GROUP = [
        'Misc Bonus Token A',
        'Misc Bonus Token B',
        'Tunnel Blasting Company',
        'Steamboat Company',
        ].freeze

        BLUE_GROUP = [
        'Misc Track A',
        'Misc Track B',
        'Misc Track C',
        'Misc Track D',
        ].freeze

        GREEN_GROUP = %w[ATSF MKT CBQ RI MP SSW SLSF].freeze

        REMOVED_CORP_SECOND_TOKEN = {
          'ATSF' => 'B8',
          'SSW' => 'J8',
          'MKT' => 'E9',
          'RI' => 'C7',
          'MP' => 'C13',
          'CBQ' => 'C7',
          'SLSF' => 'E9',
        }.freeze

        LSL_HEXES = %w[].freeze
        LSL_ICON = 'sbl'
        LSL_ID = 'SBL'

        LITTLE_MIAMI_HEXES = [].freeze

        MEAT_HEXES = %w[].freeze
        STEAMBOAT_HEXES = %w[].freeze
        BOOMTOWN_HEXES = [].freeze

        MEAT_REVENUE_DESC = 'Citrus'

        def steamboat
          @steamboat ||= company_by_id('SC')
        end

        def check_other(route)
          visited_hexes = {}
          route.visited_stops.each do |stop|
            hex = stop.hex
            raise GameError, 'Route cannot run to multiple cities in a hex' if visited_hexes[hex]

            visited_hexes[hex] = true
          end
        end

        def num_removals(group)
          return 0 if @players.size == 5
          return 1 if @players.size == 4

          case group
          when ORANGE_GROUP, BLUE_GROUP
            6 - @players.size
          when GREEN_GROUP
            5 - @players.size
          end
        end

        def corporation_removal_groups
          [GREEN_GROUP]
        end
      end
    end
  end
end
