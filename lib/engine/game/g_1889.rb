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
      HEXES = {
        white: {
          %w[B5 C8 D3 D9 E8 H3 I8 I10 J3] => 'blank',
          %w[B11 G10 I12 J5 J9] => 'town',
          %w[A10 F3 G4 G12 H7 J11] => 'city',
          %w[A8 B9 C6 D5 D7 E4 E6 F5 F7 G6 G8 H9 H11 H13] => 'mtn80',
          %w[K6] => 'wtr80',
          %w[H5 I6] => 'mtn+wtr80',

          %w[C10] => 'c=r:0,v:KU',
          %w[E2] => 'c=r:0,v:IR',
          %w[I2] => 'c=r:0,v:SR',
          %w[I4] => 'c=r:0,n:Kotohira;l=H;u=c:80',
          %w[K8] => 'c=r:0,v:AR',
        },
        yellow: {
          %w[C4] => 'c=r:20,n:Ohzu;p=a:2,b:_0',
          %w[K4] => 'c=r:30,n:Takamatsu,v:KO;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T',
        },
        green: {
          %w[F9] => 'c=r:30,s:2,n:Kouchi,v:TR;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=K;u=c:80',
        },
        gray: {
          %w[B3] => 't=r:20;p=a:0,b:_0;p=a:_0,b:5',
          %w[B7] => 'c=r:40,s:2,n:Uwajima,v:UR;p=a:1,b:_0;p=a:3,b:_0;p=a:5,b:_0',
          %w[G14] => 't=r:20;p=a:3,b:_0;p=a:_0,b:4',
          %w[J7] => 'p=a:1,b:5',
        },
        red: {
          %w[F1 J1 L7] => '',
        }
      }.freeze

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
          Corporation::Base.new(
            'AR',
            name: 'Awa Railroad',
            tokens: 2,
            float_percent: 50,
            coordinates: 'K8',
          ),
          Corporation::Base.new(
            'IR',
            name: 'Iyo Railway',
            tokens: 2,
            float_percent: 50,
            coordinates: 'E2',
          ),
          Corporation::Base.new(
            'SR',
            name: 'Sanuki Railway',
            tokens: 2,
            float_percent: 50,
            coordinates: 'I2',
          ),
          Corporation::Base.new(
            'KO',
            name: 'Takamatsu & Kotohira Electric Railway',
            tokens: 2,
            float_percent: 50,
            coordinates: 'K4',
          ),
          Corporation::Base.new(
            'TR',
            name: 'Tosa Electric Railway',
            tokens: 3,
            float_percent: 50,
            coordinates: 'F9',
          ),
          Corporation::Base.new(
            'KU',
            name: 'Tosa Kuroshio Railway',
            tokens: 1,
            float_percent: 50,
            coordinates: 'C10',
          ),
          Corporation::Base.new(
            'UR',
            name: 'Uwajima Railway',
            tokens: 3,
            float_percent: 50,
            coordinates: 'B7',
          ),
        ]
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
