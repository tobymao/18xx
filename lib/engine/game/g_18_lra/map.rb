# frozen_string_literal: true

module Engine
  module Game
    module G18Lra
      module Map
        def game_tiles
          {
            '1' => 2,
            '3' => 2,
            '4' => 6,
            '5' => 2,
            '6' => 2,
            '7' => 3,
            '8' => 7,
            '9' => 7,
            '14' => 2,
            '15' => 2,
            '18' => 1,
            '19' => 1,
            '20' => 1,
            '23' => 2,
            '24' => 2,
            '25' => 1,
            '26' => 1,
            '27' => 1,
            '28' => 1,
            '29' => 1,
            '30' => 1,
            '31' => 1,
            '39' => 1,
            '40' => 1,
            '41' => 1,
            '42' => 1,
            '43' => 1,
            '44' => 1,
            '45' => 1,
            '46' => 1,
            '47' => 1,
            '55' => 2,
            '56' => 2,
            '57' => 2,
            '58' => 6,
            '69' => 2,
            '87' => 2,
            '88' => 2,
            '141' => 2,
            '142' => 2,
            '143' => 2,
            '144' => 1,
            '204' => 2,
            '619' => 2,
            '933' => 2,
            'L01' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0;label=CM;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L02' =>
            {
              'count' => 3,
              'color' => 'yellow',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;label=CM;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L03' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:5,b:_0;label=CM;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L04' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30,loc:4.5;upgrade=cost:30,terrain:water;path=a:5,b:_0;'\
                        'path=a:3,b:_0;label=D;partition=a:0,b:3,type:water',
            },
            'L05' =>
            {
              'count' => 3,
              'color' => 'yellow',
              'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0;label=DU;'\
                        'icon=image:../logos/18_rhl/S,sticky:0;border=edge:2,type:impassable,color:blue',
            },
            'L06' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:0,loc:1;path=a:0,b:_0;path=a:3,b:_0;label=MG',
            },
            'L07' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:0,loc:4;path=a:0,b:_0;path=a:2,b:_0;label=MG',
            },
            'L08' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;label=MO;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L09' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:20;path=a:0,b:_0;path=a:5,b:_0;label=MO;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L10' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                        'label=CM;icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L11' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;'\
                        'label=CM;icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L12' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                        'label=CM;icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L13' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                        'label=CM;icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L14' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20;city=revenue:20;label=GEL;'\
                        'path=a:0,b:_0;path=a:_0,b:3;path=a:5,b:_1;path=a:_1,b:2',
            },
            'L15' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2;label=D;upgrade=cost:30,terrain:river;'\
                        'path=a:0,b:_0,track:narrow;path=a:3,b:_0;path=a:5,b:_0;'\
                        'icon=image:18_rhl/trajekt,sticky:0',
            },
            'L16' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2;label=DU;border=edge:1,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L17' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2,loc:5.5;city=revenue:30;label=KR;'\
                        'path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;'\
                        'icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L18' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40,loc:5;label=MG;'\
                        'path=a:5,b:_1;path=a:_1,b:1;path=a:0,b:_0;path=a:_0,b:3',
            },
            'L19' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40,loc:5;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;',
            },
            'L20' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40,loc:1;label=MG;'\
                        'path=a:5,b:_1;path=a:_1,b:1;path=a:0,b:_0;path=a:_0,b:4',
            },
            'L21' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:2;path=a:4,b:_1;path=a:_1,b:5',
            },
            'L22' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5',
            },
            'L23' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:3;path=a:4,b:_1;path=a:_1,b:5',
            },
            'L24' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:4',
            },
            'L25' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:2;label=MO;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L26' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:2;label=MO;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L27' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:2;label=NE;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
            'L28' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:10,slots:2;label=OY;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:5,b:_0',
            },
            'L29' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20;label=RH;upgrade=cost:30,terrain:river;'\
                        'path=a:3,b:_0,track:narrow;path=a:0,b:_0;path=a:1,b:_0;'\
                        'border=edge:4,type:impassable,color:blue;border=edge:5,type:impassable,color:blue;'\
                        'icon=image:18_rhl/trajekt,sticky:0;icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L30' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20,slots:2;label=RH;upgrade=cost:30,terrain:river;'\
                        'path=a:0,b:_0,track:narrow;path=a:3,b:_0;path=a:5,b:_0;'\
                        'border=edge:1,type:impassable,color:blue',
            },
            'L31' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=UE;'\
                        'border=edge:3,type:impassable,color:blue',
            },
            'L32' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'town=revenue:20;label=CM;icon=image:../logos/18_rhl/K,sticky:0;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
            'L33' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'town=revenue:20;label=CM;icon=image:../logos/18_rhl/K,sticky:0;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
            'L34' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:3;label=D;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                        'border=edge:1,type:impassable,color:blue;border=edge:2,type:impassable,color:blue;',
            },
            'L35' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:3;label=DU;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                        'border=edge:2,type:impassable,color:blue;icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L36' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:3;label=KR;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L37' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:3;label=MG;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
            'L38' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:40,slots:3;label=MO;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L39' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:40,slots:2;label=NE;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
            'L40' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:20,slots:2;label=OY;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
            'L41' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:30,slots:2;label=RH;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'border=edge:5,type:impassable,color:blue;icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L42' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:30,slots:3;label=RU;border=edge:2,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0',
            },
            'L43' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:30,slots:3;label=UE;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          }
        end

        def game_map
          super
        end
      end
    end
  end
end
