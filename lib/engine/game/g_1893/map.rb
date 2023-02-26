# frozen_string_literal: true

module Engine
  module Game
    module G1893
      module Map
        TILES = {
          '3' => 2,
          '4' => 4,
          '5' => 2,
          '6' => 4,
          '7' => 3,
          '8' => 10,
          '9' => 7,
          '14' => 4,
          '15' => 5,
          '16' => 1,
          '19' => 1,
          '20' => 2,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 2,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 3,
          '58' => 4,
          '70' => 1,
          '141' => 2,
          '142' => 2,
          '143' => 2,
          '144' => 2,
          '145' => 1,
          '146' => 1,
          '147' => 1,
          '611' => 4,
          '619' => 3,
          'K1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:1,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:4;label=L',
          },
          'K5' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;label=BX',
          },
          'K6' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;label=BX',
          },
          'K14' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=BX',
          },
          'K15' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=BX',
          },
          'K57' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:_0,b:3;label=BX',
          },
          'K55' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;label=L',
          },
          'K170' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=L',
          },
          'K201' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;label=K',
          },
          'K255' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          'K269' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          'K314' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=L',
          },
          'KV63' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=S',
          },
          'KV201' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;upgrade=cost:40,terrain:water;label=K',
          },
          'KV255' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'upgrade=cost:60,terrain:water;label=K',
          },
          'KV259' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0',
          },
          'KV269' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;upgrade=cost:40,'\
            'terrain:water;label=K',
          },
          'KV333' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },
          'KV619' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
          },
        }.freeze

        LEVERKUSEN_YELLOW_TILES = %w[K1 K55].freeze
        LEVERKUSEN_GREEN_TILE = 'K314'
        LEVERKUSEN_HEX_NAME = 'G6'

        RHINE_PASSAGE = %w[L5 S6].freeze

        LOCATION_NAMES = {
          'B5' => 'Düsseldorf & Neuss',
          'D5' => 'Benrath',
          'D7' => 'Solingen',
          'B9' => 'Wuppertal',
          'E2' => 'Grevenbroich',
          'E4' => 'Dormagen',
          LEVERKUSEN_HEX_NAME => 'Leverkusen',
          'I2' => 'Bergheim',
          'I8' => 'Bergisch-Gladbach',
          'L3' => 'Frechen',
          'L5' => 'Köln',
          'L9' => 'Gummersbach',
          'N1' => 'Aachen',
          'O2' => 'Düren',
          'O4' => 'Brühl',
          'O6' => 'Porz',
          'P7' => 'Troisdorf',
          'P9' => 'Siegen',
          'R7' => 'Bonn-Beuel',
          'S6' => 'Bonn',
          'T3' => 'Euskirchen',
          'U6' => 'Andernach',
          'U8' => 'Neuwied',
        }.freeze

        LAYOUT = :flat

        AXES = { x: :number, y: :letter }.freeze
      end
    end
  end
end
