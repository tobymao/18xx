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
        'El Paso & Southwestern RR',
        'Arizona Tunnel Blasting Company',
        'Arizona Development Office',
        'Excelsior Mine Company',
        ].freeze

        BLUE_GROUP = [
        'Texas & Pacific Railway',
        'Arizona & Colorado Railroad',
        'Arizona Engine Works',
        'Survey Office',
        ].freeze

        GREEN_GROUP = %w[ATSF SSW].freeze
        NORTH_GROUP = %w[RI MKT].freeze
        SOUTH_GROUP = %w[MP CBQ SLSF].freeze

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
      end
    end
  end
end
