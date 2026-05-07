# frozen_string_literal: true

require_relative '../g_1880_romania/map'

module Engine
  module Game
    module G1880RomaniaTransilvania
      module Map
        include G1880Romania::Map

        LAYOUT = :pointy
        AXES = { x: :letter, y: :number }.freeze

        LOCATION_NAMES = {
          'G1' => 'Satu Mare',
          'K1' => 'Sighetu Marmației',
          'Q1' => 'Czernowitz',
          'D2' => 'Viena / Budapešta',
          'J2' => 'Baia-Mare',
          'P2' => 'Rădăuți',
          'E3' => 'Oradea',
          'G3' => 'Margita / Simleu',
          'I3' => 'Zalău',
          'K3' => 'Dej',
          'M3' => 'Bistrița',
          'J4' => 'Cluj-Napoca',
          'L4' => 'Târgu Mureș',
          'D19' => 'Bacău',
          'A5' => 'Sinnicolau Mare',
          'C5' => 'Arad',
          'K5' => 'Turda',
          'M5' => 'Mediaș',
          'D6' => 'Timișoara',
          'H6' => 'Deva / Hunedoara',
          'J6' => 'Alba Iulia',
          'L6' => 'Sibiu',
          'N6' => 'Făgăraș',
          'P6' => 'Brașov',
          'E7' => 'Reșița',
          'B8' => 'Belgrad',
          'D8' => 'Oravița / Moldova Veche',
        }.freeze

        HEXES = {
          white: {
            # no cities or towns
            %w[I1 F2 H2 D4 F4 E5 B6 F6 C7 F8] => '',
            %w[L2 N2 O3 G5 I5 G7] => 'upgrade=cost:40,terrain:mountain',
            %w[H4 N4 I7] => 'upgrade=cost:30,terrain:mountain',
            ['O5'] => 'upgrade=cost:20,terrain:mountain',

            # town
            ['K1'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[M3 N6] => 'town=revenue:0;upgrade=cost:30,terrain:mountain',
            %w[K3 K5 M5] => 'town=revenue:0;upgrade=cost:10,terrain:mountain',

            # double towns
            ['G3'] => 'town=revenue:0;town=revenue:0',
            ['D8'] => 'town=revenue:0;town=revenue:0;icon=image:port',
            ['H6'] => 'town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:mountain',

            # city
            %w[E3 J4 L4 C5 D6] => 'city=revenue:0',
            ['G1'] => 'city=revenue:0;label=T',
            ['L6'] => 'city=revenue:0;upgrade=cost:20,terrain:mountain',

            # town and city
            %w[J2 I3] => 'town=revenue:0;city=revenue:0',
            ['J6'] => 'town=revenue:0;city=revenue:0;upgrade=cost:20,terrain:mountain',
            ['E7'] => 'town=revenue:0;city=revenue:0;upgrade=cost:40,terrain:mountain',
          },
          gray: {
            ['P2'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
            ['A5'] => 'town=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
            ['P6'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0;path=a:2,b:_0',
          },
          red: {
            ['D2'] => 'city=revenue:yellow_20|green_30|brown_50|gray_70;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['B8'] => 'city=revenue:yellow_20|green_30|brown_50|gray_70;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['Q1'] => 'city=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0,terminal:1',
            ['K7'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_50,hide:1,groups:Istanbul;'\
                      'path=a:3,b:_0,terminal:1;border=edge:4',
            ['M7'] => 'offboard=revenue:yellow_10|green_30|brown_40|gray_50,groups:Istanbul;path=a:2,b:_0,terminal:1;'\
                      'border=edge:1',
          },
        }.freeze
      end
    end
  end
end
