# frozen_string_literal: true

require_relative '../g_1822_ca/map'

module Engine
  module Game
    module G1822CaWrs
      module Map
        TILES = G1822CA::Map::TILES

        LOCATION_NAMES = G1822CA::Map::LOCATION_NAMES.dup
        LOCATION_NAMES.update({ 'T12' => 'Moncton', 'T14' => 'Montréal' })
        LOCATION_NAMES.freeze

        WRS_HEXES = {
          gray: {
            %w[T12] => 'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;'\
                       'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;',
            %w[T14] => 'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:3;'\
                       'path=a:1,b:_0;path=a:2,b:_0;',
            ['P18'] =>
              'city=revenue:yellow_20|green_30|brown_40|gray_40,slots:3;'\
              'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
          },
        }.freeze

        HEXES = G1822CA::Map.merge_hexes(G1822CA::Map::WESTERN_HEXES, WRS_HEXES)
        HEXES.freeze
      end
    end
  end
end
