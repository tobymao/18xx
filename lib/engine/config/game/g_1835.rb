# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1835
        JSON = <<-'DATA'
{
  "filename": "1835",
  "modulename": "1835",
  "currencyFormatStr": "%dM",
  "bankCash": 12000,
  "certLimit": {
    "3": 19,
    "4": 15,
    "5": 12,
    "6": 11,
    "7": 9
  },
  "startingCash": {
    "3": 600,
    "4": 475,
    "5": 390,
    "6": 340,
    "7": 310
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A11": "Kiel",
    "A17": "Stralsund",
    "B12": "Luebeck",
    "B14": "Wismar",
    "B16": "Rostok",
    "C5": "Wilhelmshaven & Leer",
    "C7": "Bremerhaven",
    "C11": " &  & ",
    "C13": "Schwerin",
    "C21": "M",
    "D6": "Oldenburg",
    "D8": "Bremen",
    "E19": " & ",
    "E21": "FF Oder",
    "F4": "Rheine",
    "F6": "Osnabrueck",
    "F10": "Hannover",
    "F12": "Braunschweig",
    "F14": "Magdeburg",
    "G3": "Duisburg & Essen",
    "G5": "Dortmund",
    "G11": "Hildesheim",
    "G15": "Halle",
    "H2": "D dorf",
    "H4": "Wuppertal & Hagen",
    "H10": "Kassel",
    "H16": "Leipzig",
    "H20": "Schlesien",
    "H22": "Schlesien",
    "I1": "AAchen",
    "I3": "Koeln",
    "I13": "Erfurt",
    "I15": "Gera",
    "I17": "Zwickau & Chemnitz",
    "J4": "Koblenz",
    "J6": "Mainz & Wiesbaden",
    "J8": "F",
    "K3": "Trier",
    "K11": "Wuerzburg",
    "L2": "Saarbruecken",
    "L6": "Baden Baden & Karlsruhe",
    "L8": "Sinsheim & Heilbronn",
    "L14": " & ",
    "M5": "Lothringen",
    "M7": "Pforzheim & Calw",
    "M9": "Suttgart",
    "M15": "Regensburg",
    "N4": "Elsass",
    "N10": "Ulm & Günzburg",
    "N12": "Augsburg",
    "O5": "Freiburg",
    "O15": "Muenchen",
    "P10": "Friedrichshafen"
  },
  "tiles": {},
  "market": [
    [
      "60y",
      "67",
      "71",
      "76",
      "82",
      "90",
      "100p",
      "112",
      "126",
      "142",
      "160",
      "180",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325",
      "350"
    ],
    [
      "53y",
      "60y",
      "66",
      "70",
      "76",
      "82",
      "90p",
      "100",
      "112",
      "126",
      "142",
      "160",
      "180",
      "200",
      "220",
      "240",
      "260",
      "280",
      "300"
    ],
    [
      "46y",
      "55y",
      "60y",
      "65",
      "70",
      "76",
      "82p",
      "90",
      "100",
      "111",
      "125",
      "140",
      "155",
      "170",
      "185",
      "200"
    ],
    [
      "39o",
      "48y",
      "54y",
      "60y",
      "66",
      "71",
      "76p",
      "82",
      "90",
      "100",
      "110",
      "120",
      "130"
    ],
    [
      "32o",
      "41o",
      "48y",
      "55y",
      "62",
      "67",
      "71p",
      "76",
      "82",
      "90",
      "100"
    ],
    [
      "25b",
      "34o",
      "42o",
      "50y",
      "58y",
      "65",
      "67p",
      "71",
      "75",
      "80"
    ],
    [
      "18b",
      "27b",
      "36o",
      "45o",
      "54y",
      "63",
      "67",
      "69",
      "70"
    ],
    [
      "10b",
      "12b",
      "30b",
      "40o",
      "50y",
      "60y",
      "67",
      "68"
    ],
    [
      "",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y",
      "60y"
    ],
    [
      "",
      "",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y"
    ],
    [
      "",
      "",
      "",
      "10b",
      "20b",
      "30b",
      "40o"
    ]
  ],
  "companies": [
    {
      "name": "Private with an icon",
      "value": 100,
      "revenue": 5,
      "desc": "Description"
    },
    {
      "name": "Private with a company",
      "value": 140,
      "revenue": 10,
      "desc": "Description"
    },
    {
      "name": "Private with a token",
      "value": 160,
      "revenue": 15,
      "desc": "Description",
      "min_players": 3
    },
    {
      "name": "Private with a tile",
      "value": 160,
      "revenue": 15,
      "desc": "This tile (2) is aliased in this game to 57"
    },
    {
      "name": "Private with a custom tile",
      "value": 180,
      "revenue": 20,
      "desc": "This tile is defined in the game file"
    },
    {
      "name": "Private with Hex and Note",
      "value": 220,
      "revenue": 30,
      "desc": "Description"
    }
  ],
  "corporations": [
    {
      "sym": "MS",
      "name": "Black Railroad",
      "logo": "1835/MS",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "C11",
      "color": "red"
    },
    {
      "sym": "LBRR",
      "name": "Light Blue Railroad",
      "logo": "1835/LBRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "lightBlue"
    },
    {
      "sym": "OL",
      "name": "Blue Railroad",
      "logo": "1835/OL",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "D6",
      "color": "blue"
    },
    {
      "sym": "NRR",
      "name": "Navy Railroad",
      "logo": "1835/NRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "navy"
    },
    {
      "sym": "BRR",
      "name": "Brown Railroad",
      "logo": "1835/BRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "brown"
    },
    {
      "sym": "GRR",
      "name": "Gray Railroad",
      "logo": "1835/GRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "gray"
    },
    {
      "sym": "GRR",
      "name": "Green Railroad",
      "logo": "1835/GRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "green"
    },
    {
      "sym": "LRR",
      "name": "Lavender Railroad",
      "logo": "1835/LRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "lavender"
    },
    {
      "sym": "LRR",
      "name": "Lime Railroad",
      "logo": "1835/LRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "lime"
    },
    {
      "sym": "BGRR",
      "name": "Bright Green Railroad",
      "logo": "1835/BGRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "brightGreen"
    },
    {
      "sym": "GRR",
      "name": "Gold Railroad",
      "logo": "1835/GRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "gold"
    },
    {
      "sym": "NRR",
      "name": "Natural Railroad",
      "logo": "1835/NRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "natural"
    },
    {
      "sym": "ORR",
      "name": "Orange Railroad",
      "logo": "1835/ORR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "orange"
    },
    {
      "sym": "PRR",
      "name": "Pink Railroad",
      "logo": "1835/PRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "pink"
    },
    {
      "sym": "VRR",
      "name": "Violet Railroad",
      "logo": "1835/VRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "violet"
    },
    {
      "sym": "RRR",
      "name": "Red Railroad",
      "logo": "1835/RRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "red"
    },
    {
      "sym": "LBRR",
      "name": "Light Brown Railroad",
      "logo": "1835/LBRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "lightBrown"
    },
    {
      "sym": "TRR",
      "name": "Turquoise Railroad",
      "logo": "1835/TRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "turquoise"
    },
    {
      "sym": "WRR",
      "name": "White Railroad",
      "logo": "1835/WRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "white"
    },
    {
      "sym": "YRR",
      "name": "Yellow Railroad",
      "logo": "1835/YRR",
      "tokens": [
        0,
        40,
        100
      ],
      "color": "yellow"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": "4",
      "num": 9
    },
    {
      "name": "2+2",
      "distance": 2,
      "price": 120,
      "rusts_on": "4+4",
      "num": 4
    },
    {
      "name": "3",
      "distance": 3,
      "price": 180,
      "rusts_on": "6",
      "num": 4
    },
    {
      "name": "3+3",
      "distance": 3,
      "price": 270,
      "rusts_on": "6+6",
      "num": 3
    },
    {
      "name": "4",
      "distance": 4,
      "price": 360,
      "num": 3
    },
    {
      "name": "4+4",
      "distance": 4,
      "price": 440,
      "num": 1
    },
    {
      "name": "5",
      "distance": 5,
      "price": 500,
      "num": 2
    },
    {
      "name": "5+5",
      "distance": 5,
      "price": 600,
      "num": 1
    },
    {
      "name": "6",
      "distance": 6,
      "price": 600,
      "num": 2
    },
    {
      "name": "6+6",
      "distance": 6,
      "price": 720,
      "num": 4
    }
  ],
  "hexes": {
    "gray": {
      "path=a:4,b:5": [
        "A9",
        "G1"
      ],
      "town=revenue:10;path=a:5,b:_0": [
        "A17"
      ],
      "path=a:0,b:5": [
        "B8"
      ],
      "town=revenue:10;town=revenue:10;path=a:4,b:_0;path=a:0,b:_1;path=a:_1,b:5": [
        "C5"
      ],
      "town=revenue:10;path=a:3,b:_0;path=a:_0,b:5;path=a:0,b:_0;path=a:_0,b:1": [
        "C7"
      ],
      "city=revenue:20;path=a:1,b:_0;path=a:_0,b:3;path=a:3,b:_0;path=a:_0,b:5;path=a:1,b:_0;path=a:_0,b:5": [
        "C13"
      ],
      "path=a:3,b:5": [
        "D4"
      ],
      "city=revenue:20;path=a:3,b:_0;path=a:_0,b:5;path=a:2,b:_0;path=a:_0,b:4": [
        "D6"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0": [
        "E21"
      ],
      "city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_0": [
        "F12"
      ],
      "path=a:0,b:2": [
        "G21"
      ],
      "town=revenue:10;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "I1"
      ],
      "path=a:1,b:3;path=a:2,b:3;path=a:1,b:2": [
        "I19"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:_0,b:5;path=a:3,b:_1;path=a:_1,b:4": [
        "J4"
      ],
      "path=a:1,b:3;path=a:0,b:3;path=a:0,b:1": [
        "J16",
        "N6"
      ],
      "": [
        "M19"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:_0,b:3": [
        "P10"
      ],
      "path=a:2,b:3": [
        "P6",
        "P14"
      ]
    },
    "white": {
      "city=revenue:0": [
        "A11",
        "F10",
        "F14",
        "G5",
        "H2",
        "H16",
        "H20",
        "M9",
        "N12",
        "O5",
        "O15"
      ],
      "": [
        "B10",
        "B18",
        "C9",
        "C15",
        "C17",
        "C19",
        "D10",
        "D12",
        "D16",
        "D18",
        "D20",
        "E5",
        "E7",
        "E9",
        "E11",
        "E13",
        "E17",
        "F8",
        "F16",
        "F18",
        "F20",
        "G7",
        "G9",
        "G17",
        "G19",
        "H14",
        "H18",
        "I5",
        "I11",
        "J2",
        "J10",
        "J12",
        "K5",
        "K13",
        "L4",
        "L10",
        "L12",
        "L16",
        "M11",
        "N14",
        "N16",
        "N18",
        "O9",
        "O11",
        "O13",
        "O17"
      ],
      "town=revenue:0": [
        "B12",
        "B14",
        "B16",
        "F4",
        "F6",
        "G11",
        "G15",
        "H10",
        "I15",
        "K3",
        "K11",
        "L2"
      ],
      "city=revenue:0;upgrade=cost:50,terrain:water": [
        "D8",
        "I3"
      ],
      "upgrade=cost:50,terrain:water": [
        "D14",
        "E15",
        "K7",
        "K9",
        "M13",
        "M17"
      ],
      "upgrade=cost:70,terrain:mountain": [
        "G13",
        "H6",
        "H8",
        "H12",
        "I7",
        "I9",
        "J14",
        "K15",
        "N8",
        "O7"
      ],
      "town=revenue:0;town=revenue:0": [
        "H4",
        "I17",
        "L8",
        "M7",
        "N10"
      ],
      "town=revenue:0;upgrade=cost:70,terrain:mountain": [
        "I13"
      ],
      "town=revenue:0;upgrade=cost:50,terrain:water": [
        "M15"
      ]
    },
    "green": {
      "city=revenue:40;city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:_0,b:4;path=a:0,b:_1;path=a:2,b:_2;label=HH;upgrade=cost:50,terrain:water": [
        "C11"
      ],
      "city=revenue:0,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0;upgrade=cost:50,terrain:water": [
        "J8"
      ],
      "city=revenue:40;city=revenue:40;path=a:2,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:5;label=": [
        "L14"
      ]
    },
    "red": {
      "offboard=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0": [
        "C21"
      ],
      "offboard=revenue:yellow_20|green_20|brown_40;path=a:1,b:_0": [
        "H22"
      ],
      "offboard=revenue:yellow_0|green_50|brown_0;path=a:3,b:_0;border=edge:0": [
        "M5"
      ],
      "offboard=revenue:yellow_0|green_50|brown_0;path=a:4,b:_0;border=edge:3": [
        "N4"
      ]
    },
    "yellow": {
      "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:2,b:_1;label=B": [
        "E19"
      ],
      "city=revenue:0;city=revenue:0": [
        "G3",
        "J6",
        "L6"
      ]
    }
  },
  "phases": [
    {
      "name": "1.1",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "1.1",
      "train_limit": 2,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "1.2",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "1.2",
      "train_limit": 2,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "2.1",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.1",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.2",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.2",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.3",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.3",
      "train_limit": 1,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.4",
      "train_limit": 1,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3.1",
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
      "name": "3.2",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "3.3",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "3.4",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
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
