# frozen_string_literal: true

require_relative '../g_1822_ca/map'

module Engine
  module Game
    module G1822CaErs
      module Map
        TILES = G1822CA::Map::TILES

        LOCATION_NAMES = G1822CA::Map::LOCATION_NAMES.dup
        LOCATION_NAMES.update({ 'T12' => 'Vancouver', 'T14' => 'Winnipeg' })
        LOCATION_NAMES.freeze

        ERS_HEXES = {
          gray: {
            %w[T12] => 'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;'\
                       'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            %w[T14] => 'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:3;'\
                       'path=a:4,b:_0;path=a:5,b:_0',
            ['Y29'] => 'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:4,b:_0,lanes:2',
          },
        }.freeze

        HEXES = G1822CA::Map.merge_hexes(G1822CA::Map::EASTERN_HEXES, ERS_HEXES)
        HEXES.freeze
      end
    end
  end
end
