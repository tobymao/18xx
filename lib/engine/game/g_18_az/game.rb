# frozen_string_literal: true

require_relative '../g_1846/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18AZ
      class Game < G1846::Game
        include_meta(G18AZ::Meta)
        include G18AZ::Entities
        include G18AZ::Map

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

        GREEN_GROUP = %w[UP GC].freeze
        NORTH_GROUP = %w[SPP SP].freeze
        SOUTH_GROUP = %w[YV ABC ATSF].freeze


        REMOVED_CORP_SECOND_TOKEN = {
          'UP' => 'H12',
          'GC' => 'H12',
          'SP' => 'D20',
          'SPP' => 'D14',
          'YV' => 'G7',
          'ABC' => 'E17',
          'ATSF' => 'E11',
        }.freeze

        LSL_HEXES = %w[ ].freeze
        LSL_ICON = 'sbl'
        LSL_ID = 'SBL'

        LITTLE_MIAMI_HEXES = [].freeze

        MEAT_HEXES = %w[ ].freeze
        STEAMBOAT_HEXES = %w[ ].freeze
        BOOMTOWN_HEXES = [].freeze

        MEAT_REVENUE_DESC = 'Citrus'

        def steamboat
          @steamboat ||= company_by_id('SO')
        end

      end
    end
  end
end
