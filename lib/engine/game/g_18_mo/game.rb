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
        'Mail Contract',
        'Tunnel Blasting Company',
        'Arizona Development Office',
        'Excelsior Mine Company',
        ].freeze

        BLUE_GROUP = [
        'Texas & Pacific Railway',
        'Arizona & Colorado Railroad',
        'Arizona Engine Works',
        'Survey Office',
        ].freeze

        GREEN_GROUP = %w[ATSF MKT CBQ RI MP SSW SLSF].freeze

        REMOVED_CORP_SECOND_TOKEN = {
          'ATSF' => 'B8',
          'SSW' => 'J12',
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
          @steamboat ||= company_by_id('SO')
        end

        def num_removals(group)
          return 0 if @players.size == 5
          return 1 if @players.size == 4

          case group
          when ORANGE_GROUP, BLUE_GROUP
            1
          when GREEN_GROUP
            2
          end
        end

        def corporation_removal_groups
          [GREEN_GROUP]
        end

      end
    end
  end
end
