# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18CZ
        JSON = <<-'DATA'
{
  "filename": "18_cz",
  "modulename": "18CZ",
  "currencyFormatStr": "K%d",
  "bankCash": 120000,
  "certLimit": {
    "3": 14,
    "4": 12,
    "5": 10,
    "6": 9
  },
  "startingCash": {
    "3": 350,
    "4": 300,
    "5": 250,
    "6": 210
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "G15": "Jihlava",
    "D16": "Hradec Kralove",
    "B10": "Decin",
    "B12": "Liberec",
    "C23": "Opava",
    "E21": "Opava",
    "G23": "Hulin",
    "G11": "Tabor",
    "I11": "Ceske Budejovice",
    "F6": "Pilzen",
    "E9": "Kladno",
    "B8": "Teplice & Ustid nad Labem",
    "D26": "Frydland & Frydek",
    "C7": "Chomutov & Most",
    "E11": "Praha",
    "D2": "Cheb",
    "D4": "Karolvy Vary",
    "E15": "Pardubice",
    "C25": "Ostrava",
    "F22": "Pferov",
    "G19": "Brno",
    "I9": "Strakonice"
  },
  "tiles": {
    "1": 1,
    "2": 2,
    "7": 5,
    "8": 14,
    "9": 13,
    "3": 4,
    "58": 4,
    "4": 4,
    "5": 4,
    "6": 4,
    "57": 4,
    "201": 2,
    "202": 2,
    "621": 2,
    "55": 1,
    "56": 1,
    "69": 1,
    "16": 1,
    "19": 1,
    "20": 1,
    "23": 3,
    "24": 3,
    "25": 2,
    "26": 2,
    "27": 2,
    "28": 1,
    "29": 1,
    "30": 1,
    "31": 1,
    "14": 4,
    "15": 4,
    "619": 4,
    "208": 2,
    "207": 2,
    "622": 2,
    "611": 7,
    "216": 3,
    "39": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "43": 1,
    "44": 1,
    "45": 1,
    "46": 1,
    "47": 1,
    "70": 1,
    "8885": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO"
    },
    "8859": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;label=OO"
    },
    "8860": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:4;label=OO"
    },
    "8863": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:5;label=OO"
    },
    "8864": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:3;label=OO"
    },
    "8865": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:3,b:_1;path=a:_1,b:4;label=OO"
    },
    "8889": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:30;city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_2;label=P"
    },
    "8890": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=P"
    },
    "8891": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;label=P"
    },
    "8892": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=P"
    },
    "8893": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=P"
    },
    "8894": {
      "count": 1,
      "color": "red",
      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
    },
    "8895": {
      "count": 1,
      "color": "red",
      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
    },
    "8896": {
      "count": 1,
      "color": "red",
      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
    },
    "8897": {
      "count": 1,
      "color": "red",
      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
    },
    "8898": {
      "count": 1,
      "color": "red",
      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
    },
    "8866": {
      "count": 2,
      "color": "green",
      "code": "town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;frame=color:purple"
    },
    "8866": {
      "count": 2,
      "color": "green",
      "code": "town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;frame=color:purple"
    },
    "14": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple"
    },
    "887": {
      "count": 4,
      "color": "green",
      "code": "town=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;path=a:2,b:_0;frame=color:purple"
    },
    "15": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;frame=color:purple"
    },
    "888": {
      "count": 4,
      "color": "green",
      "code": "town=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;path=a:2,b:_0;frame=color:purple"
    },
    "889": {
      "count": 2,
      "color": "brown",
      "code": "town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple"
    },
    "611": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;frame=color:purple"
    },
    "216": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y;frame=color:purple"
    },
    "8894": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO;frame=color:purple"
    },
    "8895": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO;frame=color:purple"
    },
    "8896": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=OO;frame=color:purple"
    },
    "8857": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y;frame=color:purple"
    },
    "595": {
      "count": 2,
      "color": "gray",
      "code": "city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple"
    }
  },
  "market": [
    [
      "40",
      "45",
      "50p",
      "53p",
      "55p",
      "58p",
      "60p",
      "63p",
      "65p",
      "68p",
      "70p",
      "75p",
      "80p",
      "85p",
      "90p",
      "95p",
      "100p",
      "105p",
      "110p",
      "115p",
      "120p",
      "126",
      "132",
      "138",
      "144",
      "151",
      "158",
      "165",
      "172",
      "180",
      "188",
      "196",
      "204",
      "213",
      "222",
      "231",
      "240",
      "250",
      "260",
      "275",
      "290",
      "305",
      "320",
      "335",
      "350",
      "370"
    ]
  ],
  "companies": [
    {
      "name": "Takamatsu E-Railroad",
      "value": 20,
      "revenue": 5,
      "desc": "Blocks Takamatsu (K4).",
      "sym": "TR",
      "max_ownership_percent": 60,
      "abilities": [
        {
          "type": "blocks_hexes",
          "hexes": [
            "K4"
          ]
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 50,
      "sym": "SX",
      "name": "Sächsische Eisenbahn",
      "logo": "18_cz/SX",
      "max_ownership_percent": 60,
      "tokens": [
        0,
        40
      ],
      "coordinates": ["A7", "B4"],
      "color": "red"
    },
    {
      "float_percent": 50,
      "sym": "PR",
      "name": "Preußische Eisenbahn",
      "logo": "18_cz/PR",
      "max_ownership_percent": 60,
      "tokens": [
        0,
        40
      ],
      "coordinates": ["A21", "B18"],
      "color": "black"
    },
    {
      "float_percent": 50,
      "sym": "BY",
      "name": "Bayrische Staatsbahn",
      "logo": "18_cz/BY",
      "max_ownership_percent": 60,
      "tokens": [
        0,
        40
      ],
      "coordinates": ["F2", "H4"],
      "color": "blue"
    },
    {
      "float_percent": 50,
      "sym": "kk",
      "name": "kk Staatsbahn",
      "logo": "18_cz/kk",
      "max_ownership_percent": 60,
      "tokens": [
        0,
        40
      ],
      "coordinates": ["J14", "I17"],
      "color": "orange"
    },
    {
      "float_percent": 50,
      "sym": "Ug",
      "name": "ungar. Staatsbahn",
      "logo": "18_cz/Ug",
      "max_ownership_percent": 60,
      "tokens": [
        0,
        40
      ],
      "coordinates": ["G27", "I23"],
      "color": "purple"
    },
    {
      "float_percent": 50,
      "sym": "BN",
      "name": "Böhmische Nordbahn",
      "logo": "18_cz/BN",
      "max_ownership_percent": 60,
      "shares":[40, 20, 20, 20],
      "tokens": [
        0,
        40,
        100
      ],
      "city": 1,
      "coordinates": "E11",
      "color": "grey"
    },
    {
      "float_percent": 50,
      "sym": "NWB",
      "name": "Österreichische Nordwestbahn",
      "logo": "18_cz/NWB",
      "max_ownership_percent": 60,
      "shares":[40, 20, 20, 20],
      "tokens": [
        0,
        40,
        100
      ],
      "city": 0,
      "coordinates": "E11",
      "color": "yellow",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "ATE",
      "name": "Aussig-Teplitzer Eisenbahn",
      "logo": "18_cz/ATE",
      "max_ownership_percent": 60,
      "shares":[40, 20, 20, 20],
      "tokens": [
        0,
        40,
        100
      ],
      "color": "gold",
      "text_color": "black",
      "coordinates": "B8"
    },
    {
      "float_percent": 50,
      "sym": "BTE",
      "name": "Buschtehrader Eisenbahn",
      "logo": "18_cz/BTE",
      "max_ownership_percent": 60,
      "shares":[40, 20, 20, 20],
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "D2",
      "color": "brightGreen",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "KFN",
      "name": "Kaiser Ferdinands Nordbahn",
      "logo": "18_cz/KFN",
      "max_ownership_percent": 60,
      "shares":[40, 20, 20, 20],
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "G19",
      "color": "lightBlue"
    },
    {
      "float_percent": 50,
      "sym": "EKJ",
      "name": "Eisenbahn Karlsbad – Johanngeorgenstadt",
      "logo": "18_cz/EKJ",
      "max_ownership_percent": 75,
      "shares":[50, 25, 25],
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "D4",
      "color": "white",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "OFE",
      "name": "Ostrau-Friedlander Eisenbahn",
      "logo": "18_cz/OFE",
      "max_ownership_percent": 75,
      "shares":[50, 25, 25],
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "C25",
      "color": "lightRed",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "BCB",
      "name": "Böhmische Commercialbahn",
      "logo": "18_cz/BCB",
      "max_ownership_percent": 75,
      "shares":[50, 25, 25],
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "E15",
      "color": "orange",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "MW",
      "name": "Mährische Westbahn",
      "logo": "18_cz/MW",
      "max_ownership_percent": 75,
      "shares":[50, 25, 25],
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "F22",
      "color": "mintGreen",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "VBW",
      "name": "Vereinigte Böhmerwaldbahnen",
      "logo": "18_cz/VBW",
      "max_ownership_percent": 75,
      "shares":[50, 25, 25],
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "I9",
      "color": "turquoise"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": "4",
      "num": 6
    }
  ],
  "hexes": {
    "white": {
      "": [
        "A11",
        "B22",
        "B24",
        "C15",
        "D6",
        "D8",
        "D18",
        "D20",
        "D22",
        "D24",
        "E7",
        "E17",
        "E19",
        "E23",
        "E25",
        "F4",
        "F8",
        "F14",
        "F16",
        "F18",
        "F24",
        "G3",
        "G5",
        "G7",
        "G25",
        "H8",
        "H12",
        "H18",
        "H20",
        "H22",
        "H24",
        "I13",
        "I19",
        "I21",
        "J12"
      ],
      "upgrade=cost:40,terrain:mountain": [
        "B6",
        "C3",
        "A15",
        "B20",
        "C21",
        "I7"
      ],
      "upgrade=cost:20,terrain:mountain": [
        "A13",
        "D28",
        "E27",
        "E5",
        "F26",
        "H14",
        "G13"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:mountain": [
        "C5"
      ],
      "town=revenue:0;upgrade=cost:20,terrain:mountain": [
        "H6",
        "J10",
        "B16",
        "H16",
        "G17"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:mountain": [
        "G15"
      ],
      "upgrade=cost:10,terrain:water": [
        "D10",
        "D12",
        "D14",
        "C17",
        "G9",
        "H10"
      ],
      "town=revenue:0;upgrade=cost:10,terrain:water": [
        "F10",
        "A9",
        "C9",
        "C11"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "D16",
        "E15"
      ],
      "city=revenue:0": [
        "B10",
        "C23",
        "E21",
        "G23",
        "G11",
        "E9",
        "D2",
        "D4",
        "F22"
      ],
      "city=revenue:0;label=Y": [
        "B12",
        "I11",
        "F6",
        "C25",
        "G19",
        "I9"
      ],
      "town=revenue:0": [
        "E1",
        "E3",
        "C13",
        "F12",
        "C19",
        "G21",
        "C27"
      ],
      "town=revenue:0;town=revenue:0": [
        "E13",
        "F20",
        "B14"
      ],
      "city=revenue:20;city=revenue:20;path=a:5,b:_0;path=a:3,b:_1;label=P;upgrade=cost:10,terrain:water": [
        "E11"
      ],
      "label=SX;border=edge:0,type:impassible;border=edge:5,type:impassible;border=edge:4,type:impassible": [
        "A7",
        "B4"
      ],
      "label=PR;border=edge:0,type:impassible;border=edge:5,type:impassible;border=edge:4,type:impassible;border=edge:1,type:impassible": [
        "A21",
        "B18"
      ],
      "label=BY;border=edge:2,type:impassible;border=edge:3,type:impassible;border=edge:4,type:impassible;border=edge:5,type:impassible": [
        "F2",
        "H4"
      ],
      "label=kk;border=edge:1,type:impassible;border=edge:2,type:impassible;border=edge:3,type:impassible;border=edge:4,type:impassible": [
        "J14",
        "I17"
      ],
      "label=Ug;border=edge:1,type:impassible;border=edge:2,type:impassible;border=edge:3,type:impassible": [
        "G27",
        "I23"
      ]
    },
    "yellow": {
      "city=revenue:0;city=revenue:0;label=OO": [
        "D26",
        "C7"
      ],
      "city=revenue:0;city=revenue:0;label=OO;upgrade=cost:10,terrain:water": [
        "B8"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "3",
      "on": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "buy_companies": true
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "buy_companies": true
    },
    {
      "name": "5",
      "on": "5",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3,
      "events": {
        "close_companies": true
      }
    },
    {
      "name": "6",
      "on": "6",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "D",
      "on": "D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "D+",
      "on": "D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
