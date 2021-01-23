# frozen_string_literal: true

# TODO: figure out the status of the following in this config.
# trains are correct
# cert limits are correct
# cash is correct
# phases are checked.
# tiles are almost correct
# tile 221 needs to be fixed somehow with the ferry.
# market is correct
# map hexes are mostly there, but not verified
# river/water is not on the map yet.
# companies are correct.
# minors are correct.
# privates are partially correct.

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
	"L14": "Fürth Nürnberg"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 2,
    "4": 3,
    "5": 3,
    "6": 3,
    "7": 8,
    "8": 16,
    "9": 12,
    "55": 1,
    "56": 1,
    "57": 2,
    "58": 4,
    "69": 2,
    "201": 2,
    "202": 2,
    "12": 2,
    "13": 2,
    "14": 2,
    "15": 2,
    "16": 2,
    "18": 1,
    "19": 2,
    "20": 2,
    "23": 3,
    "24": 3,
    "25": 3,
    "26": 2,
    "27": 2,
    "28": 2,
    "29": 2,
    "87": 2,
    "88": 2,
    "203": 2,
    "204": 2,
    "205": 1,
    "206": 1,
    "207": 2,
    "208": 2,
    "209": 1,
    "210": 1,
    "211": 1,
    "212": 1,
    "213": 1,
    "214": 1,
    "215": 1,
    "39": 1,
    "40": 1,
    "41": 2,
    "42": 2,
    "43": 1,
    "44": 2,
    "45": 2,
    "46": 2,
    "47": 2,
    "63": 3,
    "70": 1,
    "216": 4,
    "217": 2,
    "218": 2,
    "219": 2,
    "220": 1,
    "221": 1
  },
  "market": [
    [
      "",
      "",
      "",
      "",
      "132",
      "148",
      "166",
      "186",
      "208",
      "232",
      "258",
      "286",
      "316",
      "348",
      "382",
      "418"
    ],
    [
      "",
      "",
      "98",
      "108",
      "120",
      "134",
      "150",
      "168",
      "188",
      "210",
      "234",
      "260",
      "288",
      "318",
      "350",
      "384"
    ],
    [
      "82",
      "86",
      "92p",
      "100",
      "110",
      "122",
      "136",
      "152",
      "170",
      "190",
      "212",
      "236",
      "262",
      "290",
      "320"
    ],
    [
      "78",
      "84p",
      "88p",
      "94",
      "102",
      "112",
      "124",
      "138",
      "154p",
      "172",
      "192",
      "214"
    ],
    [
      "72",
      "80p",
      "86",
      "90",
      "96",
      "104",
      "114",
      "126",
      "140"
    ],
    [
      "64",
      "74",
      "82",
      "88",
      "92",
      "98",
      "106"
    ],
    [
      "54",
      "66",
      "76",
      "84",
      "90"
    ]
  ],
  "companies": [
    {
      "name": "Leipzig-Dresdner Bahn",
      "sym": "LD",
      "value": 190,
      "revenue": 20,
      "desc": "Leipzig-Dresdner Bahn - Sachsen Direktor Papier",
      "abilities": [
        {
          "type": "shares",
          "shares": [
            "SX_0",
            "SX_1"
          ]
        },
        {
          "type": "no_buy"
        },
        {
          "type": "close",
          "when": "bought_train",
          "corporation": "SX"
        }
      ]
    },
    {
      "name": "Ostbayrische Bahn",
      "sym": "OBB",
      "value": 120,
      "revenue": 10,
      "desc": "Ostbayrische Bahn - 2 Tiles on M15, M17 extra (one per OR) and without cost",
      "abilities": [
        {
          "type": "tile_lay",
          "description": "Place a free track tile at m15, M17 at any time during the corporation's operations.",
          "owner_type": "player",
          "hexes": [
            "M15",
            "M17"
          ],
          "tiles": [
            "3",
            "4",
            "7",
            "8",
            "9",
            "58"
          ],
          "free": true,
          "count": 1
        },
        {
            "type": "shares",
            "shares": "BY_2"
        }
      ]
    },
    {
      "name": "Nürnberg-Fürth",
      "sym": "NF",
      "value": 100,
      "revenue": 5,
      "desc": "Nürnberg-Fürth Bahn, Director of AG may lay token on L14 north or south",
      "abilities": [
          { "type": "shares",
                    "shares": "BY_2"
          }
      ]
    },
    {
      "name": "Hannoversche Bahn",
      "sym": "HB",
      "value": 160,
      "revenue": 30,
      "desc": "10 Percent Share of Preussische Bahn on Exchange",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["PR"],
          "owner_type": "player",
          "when": [
            "Phase 2.3",
            "Phase 2.4",
            "Phase 3.1"
          ],
          "from": "ipo"
        }
      ]
    },
    {
      "name": "Pfalzbahnen",
      "sym": "PB",
      "value": 150,
      "revenue": 15,
      "desc": "Can lay a tile on L6 and Token on L6 if Baden AG is active already",
      "abilities": [
        {
          "type": "teleport",
          "owner_type": "player",
          "free_tile_lay": true,
          "hexes": [
            "L6"
          ],
          "tiles": [
            "210",
            "211",
            "212",
            "213",
            "214",
            "215"
          ]
        },
        {
          "type": "shares",
          "shares": "BY_1"
        }
      ]
    },
    {
      "name": "Braunschweigische Bahn",
      "sym": "BB",
      "value": 130,
      "revenue": 25,
      "desc": "Can be exchanged for a 10% share of Preussische Bahn",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["PR"],
          "owner_type": "player",
          "when": [
            "Phase 2.3",
            "Phase 2.4",
            "Phase 3.1"
          ],
          "from": "ipo"
        }
      ]
    }
  ],
  "minors": [
    {
      "sym": "P1",
      "name": "Bergisch Märkische Bahn",
      "logo": "1835/PR",
      "tokens": [
        0
      ],
      "coordinates": "H2",
      "color": "black"
    },
    {
      "sym": "P2",
      "name": "Berlin Potsdamer Bahn",
      "logo": "1835/PR",
      "tokens": [
        0
      ],
      "coordinates": "E19",
      "color": "black"
    },
    {
      "sym": "P3",
      "name": "Magdeburger-Bahn",
      "logo": "1835/PR",
      "tokens": [
        0
      ],
      "coordinates": "F14",
      "color": "black"
    },
    {
      "sym": "P4",
      "name": "Köln-Mindener Bahn",
      "logo": "1835/PR",
      "tokens": [
        0
      ],
      "coordinates": "G5",
      "color": "black"
    },
    {
      "sym": "P5",
      "name": "Berlin Stettiner Bahn",
      "logo": "1835/PR",
      "tokens": [
        0
      ],
      "coordinates": "E19",
      "color": "black"
    },
    {
      "sym": "P6",
      "name": "Altona Kiel Bahn",
      "logo": "1835/PR",
      "tokens": [
        0
      ],
      "coordinates": "C11",
      "color": "black"
    }
  ],
  "corporations": [
    {
      "sym": "BY",
      "name": "Bayrische Eisenbahn",
      "logo": "1835/BY",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "coordinates": "O15",
      "color": "Blue"
    },
    {
      "sym": "OL",
      "name": "Oldenburgische Eisenbahn",
      "logo": "1835/OL",
      "tokens": [
        0,
        0
      ],
      "coordinates": "D6",
      "color": "gray"
    },
    {
      "sym": "SX",
      "name": "Sächsische Eisenbahn",
      "logo": "1835/SX",
      "tokens": [
        0,
        0,
        0
      ],
      "coordinates": "H16",
      "color": "red"
    },
    {
      "sym": "BA",
      "name": "Badische Eisenbahn",
      "logo": "1835/BA",
      "tokens": [
        0,
        0
      ],
      "coordinates": "L6",
      "color": "brown"
    },
    {
      "sym": "HE",
      "name": "Hessische Eisenbahn",
      "logo": "1835/HE",
      "tokens": [
        0,
        0
      ],
      "coordinates": "J8",
      "color": "green"
    },
    {
      "sym": "WT",
      "name": "Württembergische Eisenbahn",
      "logo": "1835/WT",
      "tokens": [
        0,
        0
      ],
      "coordinates": "M9",
      "color": "yellow"
    },
    {
      "sym": "MS",
      "name": "Eisenbahn Mecklenburg Schwerin",
      "logo": "1835/MS",
      "tokens": [
        0,
        0
      ],
      "coordinates": "C13",
      "color": "violet"
    },
    {
      "sym": "PR",
      "name": "Preussische Eisenbahn",
      "logo": "1835/PR",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "coordinates": "E19",
      "color": "black"
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
    "white": {
      "": [
        "B18",
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
      "city=revenue:0,loc:5.5": [
        "A11"
      ],
      "city=revenue:0,loc:center;upgrade=cost:50": [
        "D8"
      ],
      "city=revenue:0,loc:1.5": [
        "F10"
      ],
      "city=revenue:0,loc:center": [
        "F14"
      ],
      "city=revenue:0,loc:0": [
        "G5"
      ],
      "city=revenue:0,loc:3.5;label=Y": [
        "H2"
      ],
      "city=revenue:0,loc:2.5": [
        "H16"
      ],
      "city=revenue:0,loc:0.5;upgrade=cost:50;label=Y": [
        "H20"
      ],
      "city=revenue:0;label=Y;upgrade=cost:50": [
        "I3"
      ],
      "city=revenue:0,loc:0.5": [
        "M9"
      ],
      "city=revenue:0,loc:5": [
        "N12"
      ],
      "city=revenue:0": [
        "O5"
      ],
      "city=revenue:0,loc:1;label=Y": [
        "O15"
      ],
      "town=revenue:0,loc:5.5": [
        "B12"
      ],
      "town=revenue:0": [
        "B14"
      ],
      "town=revenue:0,loc:3": [
        "B16"
      ],
      "town=revenue:0,loc:4": [
        "F4"
      ],
      "town=revenue:0,loc:2": [
        "F6"
      ],
      "town=revenue:0,loc:0.5": [
        "G11"
      ],
      "town=revenue:0,loc:5": [
        "G15"
      ],
      "town=revenue:0,loc:1;town=revenue:0,loc:2.5": [
        "H4"
      ],
      "town=revenue:0,loc:2.5": [
        "H10"
      ],
      "upgrade=cost:70,terrain:mountain;town=revenue:0,loc:2.5": [
        "I13"
      ],
      "town=revenue:0,loc:3.5": [
        "I15"
      ],
      "town=revenue:0,loc:0.5;town=revenue:0,loc:3.5": [
        "I17"
      ],
      "town=revenue:0,loc:1.5": [
        "K3"
      ],
      "town=revenue:0,loc:1": [
        "K11"
      ],
      "town=revenue:0,loc:1": [
        "K3"
      ],
      "town=revenue:0,loc:1": [
        "K11"
      ],
      "town=revenue:0,loc:4.5": [
        "L2"
      ],
      "town=revenue:0,loc:1;town=revenue:0,loc:5": [
        "L8"
      ],
      "town=revenue:0,loc:0;town=revenue:0,loc:1.5": [
        "M7"
      ],
      "town=revenue:0,loc:5;town=revenue:0,loc:center": [
        "N10"
      ],
      "upgrade=cost:50,terrain:water;town=revenue:0,loc:3": [
        "M15"
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
      "border=edge:3,type:water": [
        "C9"
      ],
      "border=edge:0,type:water": [
        "B10"
      ]
    },
    "red": {
      "offboard=revenue:yellow_20|green_20|brown_40;path=a:1,b:_0": [
        "C21"
      ],
     "offboard=revenue:yellow_20|green_30|brown_40,groups:OS;path=a:1,b:_0;border=edge:0": [
        "H22"
      ],
      "offboard=revenue:yellow_20|green_30|brown_40,hide:1,groups:OS;border=edge:3": [
        "I21"
      ],
      "offboard=revenue:yellow_0|green_50|brown_0,groups:Alsace;path=a:3,b:_0;border=edge:0": [
        "M5"
      ],
      "offboard=revenue:yellow_0|green_50|brown_0,hide:1,groups:Alsace;path=a:4,b:_0;border=edge:3": [
        "N4"
      ]
    },
    "yellow": {
      "city=revenue:30,loc:1;city=revenue:30,loc:3;path=a:1,b:_0;path=a:2,b:_1": [
        "E19"
      ],
      "city=revenue:0,loc:0;city=revenue:0,loc:4.5;label=XX;upgrade=cost:50": [
        "G3"
      ],
      "city=revenue:0;city=revenue:0;label=XX;upgrade=cost:50": [
        "J6"
      ],
      "city=revenue:0,loc:5.5;city=revenue:0,loc:4;label=XX": [
        "L6"
      ]
    },
    "green": {
      "city=revenue:40;path=a:0,b:_0;city=revenue:40;path=a:2,b:_1;city=revenue=40;path=a:4,b:_2;path=a:3,b:_2;label=HH": [
        "C11"
      ],
      "city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;upgrade=cost:50;label=Y": [
        "J8"
      ],
      "city=revenue:30,loc:2.5;path=a:3,b:_0;path=a:2,b:_0;city=revenue:30,loc:5.5;path=a:5,b:_1;path=a:0,b:_1;label=XX": [
        "L14"
      ]
    },
    "brown": {
      "path=a:4,b:5": [
        "A9",
        "G1"
      ],
      "town=revenue:10,loc:5;path=a:5,b:_0": [
        "A17"
      ],
      "path=a:5,b:0": [
        "B8"
      ],
      "town=revenue:10;path=a:4,b:_0;town=revenue:10;path=a:5,b:_1;path=a:0,b:_1": [
        "C5"
      ],
      "town=revenue:10;path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:1": [
        "C7"
      ],
      "city=revenue:10,loc:3;path=a:3,b:_0;path=a:1,b:_0;path=a:1,b:5;path=a:5,b:_0": [
        "C13"
      ],
      "path=a:3,b:5": [
        "D4"
      ],
      "city=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "D6"
      ],
      "town=revenue:10;path=a:1,b:_0;path=a:0,b:_0;path=a:2,b:_0": [
        "E21"
      ],
      "city=revenue:20;path=a:1,b:_0;path=a:0,b:_0;path=a:4,b:_0": [
        "F12"
      ],
      "path=a:2,b:0": [
        "G21"
      ],
      "town=revenue:10;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "I1"
      ],
      "path=a:1,b:2;path=a:2,b:3;path=a:1,b:3": [
        "I19"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:5,b:_0;path=a:3,b:4": [
        "J4"
      ],
      "path=a:0,b:1;path=a:0,b:3;path=a:1,b:3": [
        "J16"
      ],
      "town=revenue:10;path=a:0,b:_0;path=a:1,b:_0": [
        "M19"
      ],
      "path=a:0,b:1;path=a:1,b:3;path=a:0,b:3": [
        "N6"
      ],
      "path=a:2,b:3": [
        "P6",
        "P14"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:3,b:_0": [
        "P10"
      ]


    }
  },
  "phases": [
    {
      "name": "1.1",
      "on": "2",
      "train_limit": {
        "minor": 2,
        "major": 4
      },
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "1.2",
      "on": "2+2",
      "train_limit": {
        "minor": 2,
        "major": 4
      },
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "2.1",
      "on": "3",
      "train_limit": {
        "minor": 2,
        "major": 4
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.2",
      "on": "3+3",
      "train_limit": {
        "major": 4,
        "minor": 2
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.3",
      "on": "4",
      "train_limit": {
        "major": 3,
        "minor": 1
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "2.4",
      "on": "4+4",
      "train_limit": {
        "prussian": 4,
        "major": 3,
        "minor": 1
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3.1",
      "on": "5",
      "train_limit": {
        "prussian": 4,
        "major": 3,
        "minor": 1
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 3,
      "events": {
        "close_companies": true
      }
    },
    {
      "name": "3.2",
      "on": "5+5",
      "train_limit": {
        "prussian": 3,
        "major": 2
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "3.3",
      "on": "6",
      "train_limit": {
        "prussian": 3,
        "major": 2
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "3.4",
      "on": "6+6",
      "train_limit": {
        "prussian": 3,
        "major": 2
      },
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
