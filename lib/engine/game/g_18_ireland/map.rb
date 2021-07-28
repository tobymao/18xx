# frozen_string_literal: true

module Engine
  module Game
    module G18Ireland
      module Map
        TILES = {
          '1' => 1,
          '3' => 5,
          '4' => 5,
          '5' => 1,
          '7' => 14,
          '8' => 18,
          '9' => 18,
          '19' => 1,
          '20' => 1,
          '55' => 1,
          '58' => 5,
          '60' => 2,
          '69' => 1,
          '77' => 8,
          '78' => 14,
          '79' => 14,
          '80' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:2;path=a:0,b:1;path=a:1,b:2' },
          '81' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:2;path=a:2,b:4;path=a:0,b:4' },
          '82' => { 'count' => 3, 'color' => 'green', 'code' => 'path=a:0,b:3;path=a:0,b:1;path=a:1,b:3' },
          '83' => { 'count' => 3, 'color' => 'green', 'code' => 'path=a:0,b:3;path=a:0,b:2;path=a:2,b:3' },
          '631' => 1,
          '644' => 1,
          '645' => 1,
          '657' => 1,
          '658' => 1,
          '659' => 1,
          '710' => 1,
          '711' => 1,
          '712' => 1,
          '713' => 1,
          '714' => 1,
          '715' => 1,
          'IR1' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:30;city=revenue:30;path=a:3,b:_0;label=BC',
          },
          'IR2' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;city=revenue:10;path=a:0,b:_0;'\
                      'path=a:2,b:_1;path=a:_1,b:3;label=DD;upgrade=cost:40',
          },
          'IR3' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:3,b:_0;label=EM',
          },
          'IR4' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0,track:narrow;label=EM',
          },
          'IR5' => { 'count' => 14, 'color' => 'yellow', 'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow' },
          'IR6' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:4,b:_1;label=BC',
          },
          'IR7' => {
            'count' => 1, # @todo loc:3 should be center
            'color' => 'green',
            'code' => 'city=revenue:20,loc:2;town=revenue:10,loc:3;'\
                      'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:0,b:_1;path=a:_1,b:3;label=DD',
          },
          'IR8' => { # @todo layout could be better
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,loc:3;town=revenue:10,loc:2;'\
                      'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:0,b:_1;path=a:_1,b:2;label=DD',
          },
          'IR9' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_1;label=DUB',
          },
          'IR10' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:3,b:_0,track:narrow;path=a:4,b:_0;label=EM',
          },
          'IR11' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0,track:narrow;label=EM',
          },
          'IR12' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:1,b:_0,track:narrow;'\
                      'path=a:2,b:_0;path=a:4,b:_0;label=EM',
          },
          'IR13' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0,track:narrow;path=a:4,b:_0',
          },
          'IR14' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'IR15' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:3,b:_0',
          },
          'IR16' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0,track:narrow;path=a:3,b:_0',
          },
          'IR17' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0,track:narrow;path=a:3,b:_0;path=a:4,b:_0',
          },
          'IR18' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          'IR19' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:4,b:_0',
          },
          'IR20' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0,track:narrow',
          },
          'IR21' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0,track:narrow',
          },
          'IR22' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'IR23' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow',
          },
          'IR24' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:2,track:narrow',
          },
          'IR25' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:1,track:narrow',
          },
          'IR26' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:3;path=a:1,b:2,track:narrow' },
          'IR27' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:3,track:narrow;path=a:1,b:2' },
          'IR28' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:1,b:3,track:narrow;path=a:0,b:4' },
          'IR29' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1,track:narrow;path=a:2,b:4' },
          'IR30' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:1,b:2,track:narrow;path=a:0,b:4' },
          'IR31' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:1,b:2;path=a:0,b:4,track:narrow' },
          'IR32' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1;path=a:2,b:4,track:narrow' },
          'IR33' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1;path=a:2,b:3,track:narrow' },
          'IR34' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1,track:narrow;path=a:3,b:4' },
          'IR35' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1,track:narrow;path=a:2,b:3' },
          'IR36' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0,track:narrow',
          },
          'IR37' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:2,b:_0;path=a:4,b:_0',
          },
          'IR38' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:3,b:_0',
          },
          'IR39' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0,track:narrow;path=a:2,b:_0',
          },
          'IR40' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0,track:narrow',
          },
          'IR41' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0,track:narrow',
          },
          'IR42' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:2,b:_0;path=a:3,b:_0',
          },
          'IR43' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:2,b:_0',
          },
          'IR44' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50;city=revenue:50;path=a:0,b:_0;'\
                      'path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=BC',
          },
          'IR45' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2,loc:1.5;city=revenue:50;city=revenue:50;'\
                      'path=a:1,b:_0;path=a:_0,b:2;path=a:0,b:_1;path=a:3,b:_2;label=DUB',
          },
          'IR46' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:4,b:_0',
          },
          'IR47' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0,track:narrow;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0,track:narrow',
          },
          'IR48' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0;'\
                      'path=a:2,b:_0,track:narrow;path=a:3,b:_0;path=a:4,b:_0',
          },
          'IR49' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0,track:narrow;'\
                      'path=a:2,b:_0,track:narrow;path=a:3,b:_0;path=a:4,b:_0',
          },
          'IR50' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0',
          },
          'IR51' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0,track:narrow;path=a:3,b:_0;path=a:4,b:_0,track:narrow',
          },
          'IR52' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0,track:narrow;'\
                      'path=a:2,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0',
          },
          'IR53' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;'\
                      'path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'IR54' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'IR55' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0,track:narrow',
          },
          'IR56' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;'\
                      'path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'IR57' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;'\
                      'path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'IR58' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'town=revenue:10;path=a:0,b:_0,track:narrow;'\
                      'path=a:2,b:_0,track:narrow;path=a:4,b:_0,track:narrow',
          },
          'IR59' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:2;path=a:0,b:1;path=a:1,b:2;'\
                      'path=a:3,b:4;path=a:3,b:5;path=a:4,b:5',
          },
          'IR60' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:2;path=a:1,b:3;path=a:2,b:4;path=a:3,b:5;path=a:0,b:4;path=a:1,b:5',
          },
          'IR61' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:4;path=a:1,b:2;path=a:2,b:4;path=a:3,b:5;path=a:0,b:5',
          },
          'IR62' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'IR63' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:3,b:_0',
          },
          'IR64' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0,track:narrow;path=a:3,b:_0',
          },
          'IR65' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0,track:narrow',
          },
          'IR66' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0;path=a:5,b:_0',
          },
          'IR67' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=BC',
          },
          'IR68' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=DUB',
          },
          'IR69' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;path=a:5,b:_0',
          },
          'IR70' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0;'\
                      'path=a:2,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0;path=a:5,b:_0,track:narrow',
          },
          'IR71' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;'\
                      'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0,track:narrow',
          },
          'IR72' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0;'\
                      'path=a:2,b:_0,track:narrow;path=a:3,b:_0;path=a:4,b:_0,track:narrow;path=a:5,b:_0',
          },
          'IM' => {
            'count' => 1,
            'color' => 'red',
            'code' => 'offboard=revenue:green_20|brown_50|gray_0;path=a:5,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'E1' => 'Burtonport',
          'G1' => 'Londonderry',
          'H2' => 'Dungiven',
          'J2' => 'Larne',
          'D4' => 'Killybegs',
          'F4' => 'Donegal',
          'J4' => 'Belfast',
          'I5' => 'Armagh & Portadown',
          'D6' => 'Sligo',
          'F6' => 'Enniskillen',
          'E7' => 'Collooney',
          'G7' => 'Clones',
          'B8' => 'Achill',
          'C9' => 'Claremorris',
          'G9' => 'Cavan',
          'I9' => 'Dundalk & Drogheda',
          'B10' => 'Westport',
          'F10' => 'Dromod',
          'A11' => 'Clifden',
          'I11' => 'Dublin',
          'D12' => 'Athenry',
          'F12' => 'Athlone',
          'C13' => 'Galway',
          'G13' => 'Maryborough',
          'I13' => 'Kingstown',
          'F14' => 'Ballybrophy',
          'J14' => 'Wicklow',
          'C15' => 'Ennis',
          'B16' => 'Kilkee',
          'D16' => 'Limerick',
          'H16' => 'Carlow',
          'E17' => 'Charleville & Limerick Junction',
          'G17' => 'Kilkenny',
          'I17' => 'Wexford',
          'B18' => 'Tralee',
          'A19' => 'Dingle',
          'G19' => 'Waterford',
          'I19' => 'Rosslare',
          'A21' => 'Valentia',
          'C21' => 'Bantry',
          'D22' => 'Clonakilty',
          'C23' => 'Baltimore',
          'E21' => 'Cork',
        }.freeze

        HEXES = {
          white: {
            %w[I1 F2 G3 G5 H6 C7 D8 H8 E9 D10 C11 E11 G11 H14 G15 F16 D18
               E19] => '',
            %w[D14] => 'border=edge:2,type:impassable',
            ['C17'] => 'border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['I3'] => 'border=edge:0,type:impassable',
            %w[I15] => 'upgrade=cost:100,terrain:mountain',
            ['E3'] => 'border=edge:0,type:impassable;upgrade=cost:100,terrain:mountain',
            ['B20'] => 'border=edge:2,type:impassable;upgrade=cost:100,terrain:mountain',
            ['E15'] => 'upgrade=cost:80,terrain:mountain',
            %w[J6 I7 B12 F18 C19 D20 H4] => 'upgrade=cost:40,terrain:mountain',
            ['E5'] => 'upgrade=cost:40,terrain:mountain;border=edge:2,type:impassable;border=edge:3,type:impassable',
            ['F20'] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:impassable',
            %w[E1 A11 C21] => 'town=revenue:0;upgrade=cost:100,terrain:mountain',
            %w[A19
               D4] => 'town=revenue:0;border=edge:0,type:impassable;'\
                      'border=edge:5,type:impassable;upgrade=cost:100,terrain:mountain',
            ['A21'] => 'town=revenue:0;border=edge:3,type:impassable;upgrade=cost:100,terrain:mountain',
            ['B8'] => 'town=revenue:0;border=edge:0,type:impassable;upgrade=cost:100,terrain:mountain',
            ['B10'] => 'town=revenue:0;border=edge:3,type:impassable;upgrade=cost:100,terrain:mountain',
            %w[I17] => 'city=revenue:0',
            %w[G1] => 'city=revenue:0;icon=image:port,sticky:1',
            ['D6'] => 'city=revenue:0;border=edge:3,type:impassable',
            ['C13'] => 'city=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['G19'] => 'city=revenue:0;border=edge:1,type:impassable',
            %w[H2 J2 F4 F14] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            ['B18'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:3,type:impassable',
            ['E21'] => 'city=revenue:0;city=revenue:0;label=BC',
            ['J4'] => 'city=revenue:0;city=revenue:0;label=BC;icon=image:port,sticky:1',
            ['E17'] => 'town=revenue:0;town=revenue:0',
            ['I5'] => 'town=revenue:0;town=revenue:0;border=edge:3,type:impassable',
            %w[F6 G13] => 'city=revenue:0,slots:2;label=EM',
            ['E7'] => 'town=revenue:0;upgrade=cost:80,terrain:mountain',
            %w[G7 C9 G9 D12 D22 C23 J14 H16 G17] => 'town=revenue:0',
            ['I19'] => 'town=revenue:0;icon=image:port,sticky:1',
            ['B16'] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            ['C15'] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:3,type:impassable',
            %w[F8 H10 H12 E13 H18] => 'upgrade=cost:40,terrain:water',
            ['I9'] => 'city=revenue:0,loc:2;town=revenue:0,loc:0;label=DD',
            %w[F10 D16] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            ['F12'] => 'town=revenue:0;upgrade=cost:40,terrain:water',
          },
          yellow: {
            ['I11'] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=DUB',
            ['I13'] => 'town=revenue:10;path=a:3,b:_0;',
          },
          blue: { # Placeholders for Irish Mail
            %w[F0 H0 G-1 J12 G21 H20] => '',
          },
        }.freeze

        LAYOUT = :flat

        AXES = { x: :letter, y: :number }.freeze
      end
    end
  end
end
