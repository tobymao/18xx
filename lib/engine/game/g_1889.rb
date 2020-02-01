# frozen_string_literal: true

require 'engine/bank'
require 'engine/company/base'
require 'engine/company/tile_laying'
require 'engine/company/terrain_discount'
require 'engine/corporation/base'
require 'engine/game/base'
require 'engine/hex'
require 'engine/tile'

module Engine
  module Game
    class G1889 < Base
      private

      def init_bank
        Bank.new(7000)
      end

      def init_companies
        [
          Company::Base.new('Takamatsu E-Railroad', value: 20, income: 5),
          # Company::TileLaying.new('Mitsubishi Ferry', value: 30, income: 5),
          # Company::TileLaying.new('Ehime Railway', value: 40, income: 10),
          # Company::TerrainDiscount.new('Sumitomo Mines Railway', value: 50, income: 15),
        ]
      end

      def init_corporations
        [
          Corporation::Base.new('AR', name: 'Awa Railroad', tokens: 2),
          Corporation::Base.new('IR', name: 'Iyo Railway', tokens: 2),
          Corporation::Base.new('SR', name: 'Sanuki Railway', tokens: 2),
          Corporation::Base.new('KO', name: 'Takamatsu & Kotohira Electric Railway', tokens: 2),
          Corporation::Base.new('TR', name: 'Tosa Electric Railway', tokens: 3),
          Corporation::Base.new('KU', name: 'Tosa Kuroshio Railway', tokens: 1),
          Corporation::Base.new('UR', name: 'Uwajima Railway', tokens: 3),
        ]
      end

      def init_hexes
        coordinates = %w[
          A8 A10 B3 B5 B7 B9 B11 C4 C6 C8 C10
          D3 D5 D7 D9 E2 E4 E6 E8 F1 F3 F5
          F7 F9 G4 G6 G8 G10 G12 G14 H3 H5 H7
          H9 H11 H13 I2 I4 I6 I8 I10 I12 J1 J3
          J5 J7 J9 J11 K4 K6 K8 L7
        ]

        # blanks
        hexes = coordinates.map do |c|
          [c, Hex.new(c, layout: :flat, tile: Tile.for('_0'))]
        end.to_h

        # preprinted tiles
        {
          yellow: {
            'C4' => 'c=r:20,n:Ohzu;p=a:2,b:_0',
            'K4' => 'c=r:30,n:Takamatsu;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T', # v:KO
          },
          green: {
            'F9' => 'c=r:30,s:2,n:Kouchi,v:TR;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=K',
          },
          gray: {
            'B3' => 't=r:20;p=a:0,b:_0;p=a:_0,b:5',
            'B7' => 'c=r:40,s:2,n:Uwajima;p=a:1,b:_0;p=a:3,b:_0;p=a:5,b:_0', # v:UR
            'G14' => 't=r:20;p=a:3,b:_0;p=a:_0,b:4',
            'J7' => 'p=a:1,b:5',
          },
        }.each do |color, tiles|
          tiles.each do |coord, code|
            tile = Tile.from_code(coord, color, code)
            hexes[coord] = Hex.new(coord, layout: :flat, tile: tile)
          end
        end

        cities = %w[A10 C10 E2 F3 G4 G12 H7 I2 I4 J11]
        cities.each do |coord|
          hexes[coord] = Hex.new(coord, layout: :flat, tile: Tile.for('_1'))
        end

        hexes.values
      end

      def init_tiles
        tiles = {
          '3' => 2,
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 5,
          '9' => 5,
          '12' => 1,
          '13' => 1,
          '14' => 1,
          '15' => 3,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 2,
          '58' => 3,
          '205' => 1,
          '206' => 1,
          '437' => 1,
          '438' => 1,
          '439' => 1,
          '440' => 1,
          '448' => 4,
          '465' => 1,
          '466' => 1,
          '492' => 1,
          '611' => 2,
        }

        tiles.flat_map do |name, num|
          num.times.map { Tile.for(name) }
        end
      end
    end
  end
end
