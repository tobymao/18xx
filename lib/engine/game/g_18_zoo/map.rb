# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Map
        TILE_Y = 'label=Y;city=revenue:yellow_30|green_40|brown_50,slots:1'
        LABEL_O = 'label=O;icon=image:river,sticky:1'
        TILE_O = "town=revenue:10;#{LABEL_O}".freeze
        TILE_O_O = 'town=revenue:10;town=revenue:10'
        TILE_M = 'upgrade=cost:1,terrain:hill'
        TILE_MM = 'upgrade=cost:2,terrain:mountain'

        TILES = {
          '7' => 7,
          'X7' => {
            'count' => 7,
            'color' => 'yellow',
            'code' => "#{Engine::Config::Tile::YELLOW['3']};#{LABEL_O}",
          },
          '8' => 18,
          'X8' => {
            'count' => 18,
            'color' => 'yellow',
            'code' => "#{Engine::Config::Tile::YELLOW['58']};#{LABEL_O}",
          },
          '9' => 13,
          'X9' => {
            'count' => 13,
            'color' => 'yellow',
            'code' => "#{Engine::Config::Tile::YELLOW['4']};#{LABEL_O}",
          },
          '5' => 2,
          '6' => 2,
          '57' => 2,
          '201' => 2,
          '202' => 2,
          '621' => 2,
          '16' => 1,
          'X16' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::YELLOW['56']};#{LABEL_O}",
          },
          '19' => 1,
          'X19' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::YELLOW['69']};#{LABEL_O}",
          },
          '20' => 1,
          'X20' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::YELLOW['55']};#{LABEL_O}",
          },
          '23' => 2,
          'X23' => {
            'count' => 2,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['981']};#{LABEL_O}",
          },
          '24' => 2,
          'X24' => {
            'count' => 2,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['991']};#{LABEL_O}",
          },
          '25' => 2,
          'X25' => {
            'count' => 2,
            'color' => 'green',
            'code' => "#{TILE_O_O};path=a:0,b:_0;path=a:_0,b:2;path=a:0,b:_1;path=a:_1,b:4;#{LABEL_O}",
          },
          '26' => 2,
          'X26' => {
            'count' => 2,
            'color' => 'green',
            'code' => "#{TILE_O_O};path=a:0,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:5;#{LABEL_O}",
          },
          '27' => 2,
          'X27' => {
            'count' => 2,
            'color' => 'green',
            'code' => "#{TILE_O_O};path=a:0,b:_0;path=a:_0,b:1;path=a:0,b:_1;path=a:_1,b:3;#{LABEL_O}",
          },
          '28' => 1,
          'X28' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{TILE_O_O};path=a:0,b:_0;path=a:_0,b:4;path=a:0,b:_1;path=a:_1,b:5;#{LABEL_O}",
          },
          '29' => 1,
          'X29' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{TILE_O_O};path=a:0,b:_0;path=a:_0,b:1;path=a:0,b:_1;path=a:_1,b:2;#{LABEL_O}",
          },
          '30' => 1,
          'X30' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{TILE_O_O};path=a:0,b:_0;path=a:_0,b:1;path=a:0,b:_1;path=a:_1,b:4;#{LABEL_O}",
          },
          '31' => 1,
          'X31' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{TILE_O_O};path=a:0,b:_0;path=a:_0,b:2;path=a:0,b:_1;path=a:_1,b:5;#{LABEL_O}",
          },
          '14' => 2,
          '15' => 2,
          '619' => 2,
          '576' => 1,
          '577' => 1,
          '579' => 1,
          '792' => 1,
          '793' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '611' => 3,
          '582' => 3,
          'TI_455' => {
            'count' => 1,
            'color' => 'gray',
            'code' => "#{Engine::Config::Tile::GRAY['455']};icon=image:18_zoo/TI",
          },
          'GI_455' => {
            'count' => 1,
            'color' => 'gray',
            'code' => "#{Engine::Config::Tile::GRAY['455']};icon=image:18_zoo/GI",
          },
          'BB_455' => {
            'count' => 1,
            'color' => 'gray',
            'code' => "#{Engine::Config::Tile::GRAY['455']};icon=image:18_zoo/BB",
          },
          '80' => 1,
          'X80' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['143']};#{LABEL_O}",
          },
          '81' => 1,
          'X81' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['144']};#{LABEL_O}",
          },
          '82' => 1,
          'X82' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['141']};#{LABEL_O}",
          },
          '83' => 1,
          'X83' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['142']};#{LABEL_O}",
          },
        }.freeze

        # used by Maps B, D, and E
        MAP_B_BASE_2 = {
          'G8' => [TILE_O, :white],
          'G10' => [TILE_M, :white],
          'G12' => ['', :white],
          'H9' => [TILE_MM, :white],
          'H11' => ['offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=R', :red],
          'H13' => [TILE_M, :white],
          'I8' => [TILE_O, :white],
          'I10' => [TILE_M, :white],
          'I12' => ['', :white],
        }.freeze

        # used by Map C and F
        MAP_C_BASE_2 = {
          'H8' => [TILE_O, :white],
          'H10' => [TILE_M, :white],
          'H12' => ['', :white],
          'I9' => [TILE_MM, :white],
          'I11' => ['offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=R', :red],
          'I13' => [TILE_M, :white],
          'J8' => [TILE_O, :white],
          'J10' => [TILE_M, :white],
          'J12' => ['', :white],
        }.freeze

        MAP_C_LOCATION_NAMES = {
          'E13' => 'M',
          'F18' => 'M',
          'G9' => 'M',
          'J16' => 'M',
          'L6' => 'M',
          'E7' => 'MM',
          'F8' => 'MM',
          'F12' => 'MM',
          'G11' => 'MM',
          'H18' => 'MM',
          'I19' => 'MM',
          'L4' => 'MM',
          'M7' => 'MM',
        }.freeze

        def game_hole
          self.class::HOLE
        end

        def game_location_names
          self.class::LOCATION_NAMES
        end

        def game_base_2
          self.class::BASE_2
        end

        def game_location_name_base_2
          self.class::LOCATION_NAMES_BASE_2
        end

        def game_base_3
          self.class::BASE_3
        end

        def game_location_name_base_3
          self.class::LOCATION_NAMES_BASE_3
        end
      end
    end
  end
end
