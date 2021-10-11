# frozen_string_literal: true

module Engine
  module Game
    module G1888
      module Map
        # rubocop:disable Layout/LineLength
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 5,
          '5' => 3,
          '6' => 3,
          '7' => 4,
          '8' => 11,
          '9' => 9,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '51' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 3,
          '58' => 4,
          '69' => 1,
          '70' => 1,
          '611' => 5,
          '8858' => 1,
          '8859' => 1,
          '8860' => 1,
          '8863' => 1,
          '8864' => 1,
          '8865' => 1,
          'L39' =>
          {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=revenue:yellow_40|green_50|brown_60|gray_70;path=a:4,b:_0;path=a:5,b:_0',
          },
          'L40a' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' =>
              'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:0,b:_0',
          },
          'L40b' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          'L41' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'town=revenue:0;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;icon=image:1888/mine,large:1',
          },
          'L42' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40,loc:2.5;city=revenue:40;city=revenue:40,loc:5.5;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_2;path=a:5,b:_3;label=B',
          },
          'X7' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=OO',
          },
          '512' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=OO',
          },
          '8892' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
          '8893' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LOCATION_NAMES = {
          'A1' => 'Baotou',
          'A19' => 'Changchun',
          'B2' => 'Hohhot',
          'B6' => 'Zhangijakou & Xuanhua',
          'B12' => 'Chengde',
          'B16' => 'Chaoyang & Jinzhou',
          'B18' => 'Shenyang & Anshan',
          'B20' => 'Fushun & Benxi',
          'C3' => 'Datong',
          'C5' => 'Heng Shan',
          'C9' => 'Beijing',
          'C13' => 'Qinhuangdao',
          'C17' => 'Yingkou',
          'D10' => 'Tianjin',
          'D12' => 'Tangshan',
          'D20' => 'Dandong',
          'E3' => 'Taiyuan',
          'E5' => 'Shijiazhuang',
          'E7' => 'Boading',
          'E17' => 'Dalian',
          'F2' => 'Cangzhi',
          'F6' => 'Handan',
          'F16' => 'Yantai',
          'G5' => 'Anyang & Hebi',
          'G9' => 'Jinan',
          'F12' => 'Dongying',
          'G13' => 'Weifang',
          'H2' => "Xi'an",
          'H4' => 'Xinxiang & Jiaozuo',
          'H8' => 'Jining',
          'G11' => 'Zibo',
          'H14' => 'Qingdao',
          'H16' => 'harbor',
          'I7' => 'Zhengzhou',
          'I11' => 'Xuzhou',
        }.freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            %w[D8 D18 E9 F8 G17] => '',
            ['F14'] => 'border=edge:1,type:impassable',
            ['D16'] => 'border=edge:2,type:impassable',
            %w[E7 G13 H8] => 'town=revenue:0',
            ['C17'] => 'town=revenue:0;border=edge:1,type:impassable',
            ['G5'] => 'town=revenue:0;town=revenue:0',
            ['D12'] => 'town=revenue:0;icon=image:1888/JHR_dest,sticky:1',
            ['F12'] => 'town=revenue:0;upgrade=cost:20,terrain:water;icon=image:1888/ZDR_dest,sticky:1;border=edge:4,type:impassable',
            ['H14'] => 'city=revenue:0;icon=image:1888/LYR_dest,sticky:1',
            %w[D10 E5 F6] => 'city=revenue:0',
            ['C7'] => 'upgrade=cost:10,terrain:wall',
            ['C15'] => 'upgrade=cost:10,terrain:wall;border=edge:4,type:impassable;border=edge:5,type:impassable',
            ['B16'] => 'town=revenue:0;town=revenue:0;upgrade=cost:10,terrain:wall',
            %w[F10 G7 H6] => 'upgrade=cost:20,terrain:water',
            ['G9'] => 'city=revenue:0;upgrade=cost:20,terrain:water;icon=image:1888/HJR_dest,sticky:1',
            %w[C19 G15] => 'upgrade=cost:30,terrain:mountain',
            %w[B14 H12] => 'upgrade=cost:20,terrain:mountain',
            %w[B10 C11] => 'upgrade=cost:20,terrain:wall|mountain',
            ['B12'] => 'town=revenue:0;upgrade=cost:20,terrain:mountain',
            ['G11'] => 'city=revenue:0',
            ['H10'] => 'upgrade=cost:20,terrain:mountain',
            ['C13'] => 'city=revenue:0;upgrade=cost:20,terrain:wall|mountain;icon=image:1888/SSL_dest,sticky:1',
            ['B8'] => 'upgrade=cost:30,terrain:wall|mountain',
            ['B6'] => 'town=revenue:0;town=revenue:0;upgrade=cost:30,terrain:wall|mountain;icon=image:1888/JZR_dest,sticky:1',
            %w[B4 D2 D4 D6 F4] => 'upgrade=cost:40,terrain:wall|mountain',
            %w[C5 G3] => 'upgrade=cost:40,terrain:mountain',
            %w[C3 E3] => 'city=revenue:0;upgrade=cost:40,terrain:wall|mountain',
            %w[B2 F2] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
          },
          red: {
            ['A1'] => 'offboard=revenue:40,hide:1,groups:Baotou;path=a:5,b:_0;border=edge:4',
            ['A3'] => 'offboard=revenue:40,groups:Baotou;path=a:5,b:_0;border=edge:1',
            ['A19'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1;path=a:4,b:_0,terminal:1;border=edge:4',
            ['A21'] => 'path=a:0,b:1;border=edge:1',
            ['H2'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0;path=a:4,b:_0',
            ['I11'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0;path=a:3,b:_0',
          },
          gray: {
            ['A7'] => 'path=a:0,b:5',
            ['A15'] => 'path=a:0,b:4',
            ['A17'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['C21'] => 'path=a:0,b:2',
            ['D20'] => 'town=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['I5'] => 'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:2,b:_0;path=a:3,b:_0',
          },
          yellow: {
            ['B18'] => 'city=revenue:30;city=revenue:0;path=a:1,b:_0;label=OO',
            ['B20'] => 'city=revenue:0;city=revenue:30;label=OO',
            ['C9'] => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:5,b:_1;label=B;upgrade=cost:10,terrain:wall',
            ['H4'] => 'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:20,terrain:mountain;icon=image:1888/TJL_dest,sticky:1',
          },
          blue: {
            %w[D14 E11 E13 E15 E19 F18] => '',
            ['E17'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;path=a:2,b:_0;path=a:3,b:_0;icon=image:1888/CDL_dest,sticky:1',
            ['F16'] => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['H16'] => 'offboard=revenue:10,visit_cost:0;path=a:1,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LAYOUT = :pointy
      end
    end
  end
end
