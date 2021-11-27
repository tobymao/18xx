# frozen_string_literal: true

module Engine
  module Game
    module G18Carolinas
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze

        LOCATION_NAMES = {
          'A7' => 'Knoxville',
          'A23' => 'Richmond',
          'B20' => 'Weldon',
          'C11' => 'Winston-Salem',
          'C13' => 'Greensboro',
          'C15' => 'Durham & Cary',
          'C17' => 'Raleigh',
          'C21' => 'Greenville',
          'D4' => 'Asheville',
          'C9' => 'Statesville',
          'D10' => 'Charlotte',
          'D12' => 'Concord',
          'D8' => 'Gastonia',
          'E15' => 'Fayetteville',
          'E5' => 'Greenville',
          'E7' => 'Spartanburg & Gaffney',
          'E9' => 'Rock Hill',
          'F20' => 'Jacksonville',
          'G1' => 'Atlanta',
          'G11' => 'Camden',
          'G13' => 'Florence',
          'G19' => 'Wilmington',
          'G9' => 'Columbia',
          'H12' => 'Santee',
          'H16' => 'Myrtle Beach',
          'H6' => 'Augusta',
          'I11' => 'St George',
          'I15' => 'Georgetown',
          'J10' => 'Beaufort',
          'J12' => 'Charleston',
        }.freeze

        # rubocop:disable Layout/LineLength
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 3,
          '5' => 4,
          '6' => 4,
          '7' => 3,
          '8' => 15,
          '9' => 12,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 2,
          '12' => 3,
          '13' => 8,
          '14' => 3,
          '15' => 5,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 2,
          '29' => 2,
          '87' => 2,
          '88' => 2,
          '38' => 4,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '70' => 1,
          '1s' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:20;town=revenue:20;path=a:1,b:_0,track:narrow;path=a:_0,b:3,track:narrow;path=a:0,b:_1,track:narrow;path=a:_1,b:4,track:narrow',
          },
          '2s' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:20;town=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow;path=a:1,b:_1,track:narrow;path=a:_1,b:2,track:narrow',
          },
          '3s' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:1,track:narrow',
          },
          '4s' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow',
          },
          '5s' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow',
          },
          '6s' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow',
          },
          '7s' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'path=a:0,b:1,track:narrow',
          },
          '8s' =>
          {
            'count' => 13,
            'color' => 'yellow',
            'code' => 'path=a:0,b:2,track:narrow',
          },
          '9s' =>
          {
            'count' => 10,
            'color' => 'yellow',
            'code' => 'path=a:0,b:3,track:narrow',
          },
          '55s' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:20;town=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow;path=a:1,b:_1,track:narrow;path=a:_1,b:4,track:narrow',
          },
          '56s' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:20;town=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:2,track:narrow;path=a:1,b:_1,track:narrow;path=a:_1,b:3,track:narrow',
          },
          '57s' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow',
          },
          '58s' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:2,track:narrow',
          },
          'C1' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:40,loc:1;city=revenue:40,loc:4;path=a:0,b:_0;path=a:5,b:_1,track:narrow;label=C',
          },
          'C2' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:40;path=a:0,b:_0,track:narrow;path=a:5,b:_0,track:narrow;label=C',
          },
          'C3' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:1,b:_0;path=a:5,b:_1,track:narrow;label=C',
          },
          'C4' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:40;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow;label=C',
          },
          '12s' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow',
          },
          '13s' =>
          {
            'count' => 8,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          '14s' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          '15s' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          '16s' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:2,track:narrow;path=a:1,b:3,track:narrow',
          },
          '19s' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:2,b:4,track:narrow',
          },
          '20s' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:1,b:4,track:narrow',
          },
          '23s' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:0,b:4,track:narrow',
          },
          '24s' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:0,b:2,track:narrow',
          },
          '25s' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:0,b:2,track:narrow;path=a:0,b:4,track:narrow',
          },
          '26s' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:0,b:5,track:narrow',
          },
          '27s' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:0,b:1,track:narrow',
          },
          '28s' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:0,b:4,track:narrow;path=a:0,b:5,track:narrow',
          },
          '29s' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:0,b:2,track:narrow;path=a:0,b:1,track:narrow',
          },
          '87s' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          '88s' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'C5' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0,track:narrow;label=C',
          },
          'C6' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow;label=C',
          },
          'C7' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
          },
          'C8' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C',
          },
          'C9' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        NORTH_COLOR = '#00a651'
        SOUTH_COLOR = '#fdba12'

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            %w[
            B8
            B10
            B12
            B14
            B16
            B18
            B22
            C5
            C7
            C11
            C19
            C23
            D6
            D14
            D16
            D18
            D20
            D22
            E11
            E13
            E17
            E19
            E21
            E23
            F16
            F18
            ] => "frame=color:#{NORTH_COLOR}",
            %w[
            B6
            G17
            ] => "frame=color:#{NORTH_COLOR},color2:#{SOUTH_COLOR}",
            %w[
            E3
            F2
            F6
            F8
            F10
            F12
            F14
            G3
            G7
            G15
            H2
            H4
            H8
            H10
            H14
            I3
            I5
            I7
            I9
            I13
            J8
            ] => "frame=color:#{SOUTH_COLOR}",
            %w[
            C17
            ] => "city=revenue:0;upgrade=cost:40,terrain:water;frame=color:#{NORTH_COLOR}",
            %w[
            G9
            ] => "city=revenue:0;upgrade=cost:40,terrain:water;label=C;frame=color:#{SOUTH_COLOR}",
            %w[
            H6
            ] => "city=revenue:0;upgrade=cost:40,terrain:water;frame=color:#{SOUTH_COLOR}",
            %w[
            D10
            ] => "city=revenue:30,loc:5;city=revenue:0,loc:2;path=a:0,b:_0,track:narrow;upgrade=cost:40,terrain:water;label=C;frame=color:#{NORTH_COLOR},color2:#{SOUTH_COLOR}",
            %w[
            G5
            F4
            ] => "upgrade=cost:40,terrain:water;frame=color:#{SOUTH_COLOR}",
            %w[
            C15
            ] => "town=revenue:0;town=revenue:0;frame=color:#{NORTH_COLOR}",
            %w[
            E7
            ] => "town=revenue:0;town=revenue:0;frame=color:#{SOUTH_COLOR}",
            %w[
            D4
            D8
            B20
            C13
            C21
            E15
            ] => "city=revenue:0;frame=color:#{NORTH_COLOR}",
            %w[
            E9
            E5
            G13
            H16
            I11
            ] => "city=revenue:0;frame=color:#{SOUTH_COLOR}",
            %w[
            C9
            D12
            F20
            ] => "town=revenue:0;frame=color:#{NORTH_COLOR}",
            %w[
            G11
            I15
            J10
            ] => "town=revenue:0;frame=color:#{SOUTH_COLOR}",
            %w[
            H12
            ] => "town=revenue:0;upgrade=cost:40,terrain:water;frame=color:#{SOUTH_COLOR}",
            %w[
            J12
            ] => "city=revenue:0;label=C;frame=color:#{SOUTH_COLOR}",
            %w[
            G19
            ] => "city=revenue:30,loc:0;city=revenue:0,loc:3;path=a:1,b:_0,track:narrow;label=C;frame=color:#{NORTH_COLOR},color2:#{SOUTH_COLOR}",
          },
          red: {
            %w[
            A7
            ] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:0,b:_0,track:dual',
            %w[
            A23
            ] => 'offboard=revenue:yellow_40|green_50|brown_60|gray_80;path=a:0,b:_0',
            %w[
            G1
            ] => 'offboard=revenue:yellow_40|green_60|brown_80|gray_100;path=a:4,b:_0,track:dual',
          },
          gray: {
            %w[
            I17
            ] => 'offboard=revenue:0;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
            %w[
            A19
            ] => 'offboard=revenue:0;path=a:5,b:_0,terminal:1',
            %w[
            B4
            ] => 'path=a:0,b:4,track:narrow',
            %w[
            C3
            ] => 'path=a:0,b:3,track:narrow;offboard=revenue:0;path=a:5,b:_0,terminal:1',
            %w[
            D2
            ] => 'path=a:0,b:3,track:narrow;offboard=revenue:0;path=a:4,b:_0,terminal:1',
            %w[
            E1
            ] => 'path=a:3,b:4,track:narrow',
          },
        }.freeze
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
