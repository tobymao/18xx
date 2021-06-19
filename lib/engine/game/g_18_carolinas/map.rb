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
          '8' => 10,
          '9' => 7,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 2,
          '12' => 3,
          '13' => 3,
          '14' => 3,
          '15' => 4,
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
          '87' => 3,
          '88' => 2,
          '38' => 4,
          '39' => 1,
          '40' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '70' => 1,
          'S1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;town=revenue:10;path=a:1,b:_0,track:narrow;path=a:_0,b:3,track:narrow;path=a:0,b:_1,track:narrow;path=a:_1,b:4,track:narrow',
          },
          'S2' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow;path=a:1,b:_1,track:narrow;path=a:_1,b:2,track:narrow',
          },
          'S3' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:1,track:narrow',
          },
          'S4' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow',
          },
          'S5' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow',
          },
          'S6' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow',
          },
          'S7' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'path=a:0,b:1,track:narrow',
          },
          'S8' =>
          {
            'count' => 10,
            'color' => 'yellow',
            'code' => 'path=a:0,b:2,track:narrow',
          },
          'S9' =>
          {
            'count' => 7,
            'color' => 'yellow',
            'code' => 'path=a:0,b:3,track:narrow',
          },
          'S55' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow;path=a:1,b:_1,track:narrow;path=a:_1,b:4,track:narrow',
          },
          'S56' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:2,track:narrow;path=a:1,b:_1,track:narrow;path=a:_1,b:3,track:narrow',
          },
          'S57' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow',
          },
          'S58' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:2,track:narrow',
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
          'S12' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow',
          },
          'S13' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:0,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'S14' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'S15' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'S16' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:2,track:narrow;path=a:1,b:3,track:narrow',
          },
          'S19' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:2,b:4,track:narrow',
          },
          'S20' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:1,b:4,track:narrow',
          },
          'S23' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:0,b:4,track:narrow',
          },
          'S24' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:0,b:2,track:narrow',
          },
          'S25' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:0,b:2,track:narrow;path=a:0,b:4,track:narrow',
          },
          'S26' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:0,b:5,track:narrow',
          },
          'S27' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3,track:narrow;path=a:0,b:1,track:narrow',
          },
          'S28' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:0,b:4,track:narrow;path=a:0,b:5,track:narrow',
          },
          'S29' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'path=a:0,b:2,track:narrow;path=a:0,b:1,track:narrow',
          },
          'S87' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'S88' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
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
            ] => 'frame=color:#00a651',
            %w[
            B6
            G17
            ] => 'frame=color:#00a651,color2:#fdba12',
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
            ] => 'frame=color:#fdba12',
            %w[
            C17
            ] => 'city=revenue:0;upgrade=cost:40,terrain:water;frame=color:#00a651',
            %w[
            G9
            ] => 'city=revenue:0;upgrade=cost:40,terrain:water;label=C;frame=color:#fdba12',
            %w[
            H6
            ] => 'city=revenue:0;upgrade=cost:40,terrain:water;frame=color:#fdba12',
            %w[
            D10
            ] => 'city=revenue:30,loc:5;city=revenue:0,loc:2;path=a:0,b:_0,track:narrow;upgrade=cost:40,terrain:water;label=C;frame=color:#00a651,color2:#fdba12',
            %w[
            G5
            F4
            ] => 'upgrade=cost:40,terrain:water;frame=color:#fdba12',
            %w[
            C15
            ] => 'town=revenue:0;town=revenue:0;frame=color:#00a651',
            %w[
            E7
            ] => 'town=revenue:0;town=revenue:0;frame=color:#fdba12',
            %w[
            D4
            D8
            B20
            C13
            C21
            E15
            ] => 'city=revenue:0;frame=color:#00a651',
            %w[
            E9
            E5
            G13
            H16
            I11
            ] => 'city=revenue:0;frame=color:#fdba12',
            %w[
            C9
            D12
            F20
            ] => 'town=revenue:0;frame=color:#00a651',
            %w[
            G11
            I15
            J10
            ] => 'town=revenue:0;frame=color:#fdba12',
            %w[
            H12
            ] => 'town=revenue:0;upgrade=cost:40,terrain:water;frame=color:#fdba12',
            %w[
            J12
            ] => 'city=revenue:0;label=C;frame=color:#fdba12',
            %w[
            G19
            ] => 'city=revenue:30,loc:0;city=revenue:0,loc:3;path=a:1,b:_0,track:narrow;label=C;frame=color:#00a651,color2:#fdba12',
          },
          red: {
            %w[
            A7
            ] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:0,b:_0',
            %w[
            A23
            ] => 'offboard=revenue:yellow_40|green_50|brown_60|gray_80;path=a:0,b:_0',
            %w[
            G1
            ] => 'offboard=revenue:yellow_40|green_60|brown_80|gray_100;path=a:4,b:_0',
          },
          blue: {
            %w[
          I17
          ] => 'junction;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          },
          gray: {
            %w[
          A19
          ] => 'junction;path=a:5,b:_0,terminal:1',
            %w[
            B4
            ] => 'path=a:0,b:4,track:narrow',
            %w[
            C3
            ] => 'path=a:0,b:3,track:narrow;junction;path=a:5,b:_0,terminal:1',
            %w[
            D2
            ] => 'path=a:0,b:3,track:narrow;junction;path=a:4,b:_0,terminal:1',
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
