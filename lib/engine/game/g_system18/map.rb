# frozen_string_literal: true

module Engine
  module Game
    module GSystem18
      module Map
        S18_TILES = {
          '1' => 1,
          '2' => 1,
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 2,
          '9' => 2,
          '12' => 1,
          '13' => 1,
          '14' => 2,
          '15' => 2,
          '23' => 1,
          '24' => 1,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '53' => 2,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '59' => 2,
          '61' => 2,
          '63' => 4,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          '205' => 1,
          '206' => 1,
          '619' => 2,
        }.freeze

        def game_tiles
          tiles = {}
          S18_TILES.each { |i, j| tiles[i] = j.dup }

          send("map_#{map_name}_game_tiles", tiles)
        end

        def game_location_names
          send("map_#{map_name}_game_location_names")
        end

        def game_hexes
          send("map_#{map_name}_game_hexes")
        end
      end
    end
  end
end
