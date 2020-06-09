# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18NewEngland
        JSON = <<-'DATA'
{
  "filename": "18_newengland",
  "modulename": "18NewEngland",
  "currencyFormatStr": "$%d",
  "bankCash": 12000,
  "certLimit": {
    "2": 25,
    "3": 20,
    "4": 16,
    "5": 13
  },
  "startingCash": {
    "2": 600,
    "3": 400,
    "4": 280,
    "5": 280
  },
  "capitalization": "incremental",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "B12": "Campbell Hall",
    "B2": "Syracuse",
    "C3": "Albany",
    "C5": "Hudson",
    "C9": "Rhinecliff",
    "C11": "Poughkeepsie",
    "C17": "White Plains",
    "C19": "New York",
    "D4": "New Lebanon",
    "E13": "Danbury",
    "E15": "Stamford",
    "F2": "Burlington",
    "F4": "Pittsfield",
    "F12": "Waterbury",
    "F14": "Bridgeport",
    "G11": "Middletown",
    "G13": "New Haven",
    "H4": "Greenfield",
    "H6": "Northampton",
    "H8": "Springfield",
    "H10": "Hartford",
    "H14": "Saybrook",
    "I13": "New London",
    "J6": "Worcester",
    "J14": "Westerly",
    "K1": "New Hampshire",
    "K3": "Fitchburg",
    "K5": "Leominster",
    "L4": "Lowell and Wilmington",
    "L8": "Woonsocket",
    "L10": "Providence",
    "M1": "Portland",
    "M5": "Boston",
    "M7": "Quincy",
    "O11": "Cape Cod"
  },
  "tiles": {
    "3": 5,
    "4": 5,
    "6": 8,
    "7": 5,
    "8": 18,
    "9": 15,
    "58": 5,
    "14": 4,
    "15": 4,
    "16": 2,
    "19": 2,
    "20": 2,
    "23": 5,
    "24": 5,
    "25": 4,
    "26": 2,
    "27": 2,
    "28": 2,
    "29": 2,
    "30": 2,
    "31": 2,
    "87": 4,
    "88": 4,
    "204": 4,
    "207": 1,
    "619": 4,
    "622": 1,
    "39": 2,
    "40": 2,
    "41": 2,
    "42": 2,
    "43": 2,
    "44": 2,
    "45": 2,
    "46": 2,
    "47": 2,
    "63": 7,
    "70": 2,
    "611": 3,
    "216": 2,
    "911": 4
  },
  "market": [
    [
      "35",
      "40",
      "45",
      "50",
      "55",
      "60",
      "65",
      "70",
      "80",
      "90",
      "100p",
      "110p",
      "120p",
      "130p",
      "145p",
      "160p",
      "180p",
      "200p",
      "220",
      "240",
      "260",
      "280",
      "310",
      "340",
      "380",
      "420",
      "460",
      "500"
    ]
  ],
  "companies": [
    {
      "name": "Delaware and Raritan Canal",
      "value": 20,
      "revenue": 5,
      "desc": "No special ability. Blocks hex K3 while owned by a player.",
      "sym": "D&R",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            ""
          ]
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 60,
      "sym": "B&A",
      "name": "Boston and Albany Railroad",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        80
      ],
      "coordinates": "",
      "color": "red"
    },
    {
      "float_percent": 60,
      "sym": "B&M",
      "name": "Boston and Maine Railroad",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        80
      ],
      "coordinates": "",
      "color": "green"
    },
    {
      "float_percent": 60,
      "sym": "CN",
      "name": "Canadian National Railway",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        80
      ],
      "coordinates": "",
      "color": "yellow",
      "text_color": "black"
    },
    {
      "float_percent": 60,
      "sym": "CVT",
      "name": "Central Vermont Railway",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        80
      ],
      "coordinates": "",
      "color": "purple"
    },
    {
      "float_percent": 60,
      "sym": "D&H",
      "name": "Delaware and Hudson Railway",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        80
      ],
      "coordinates": "",
      "color": "darkBlue"
    },
    {
      "float_percent": 60,
      "sym": "NYC",
      "name": "New York Central Railroad",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        80
      ],
      "coordinates": "",
      "color": "black"
    },
    {
      "float_percent": 60,
      "sym": "NYNHH",
      "name": "New York, New Haven and Hartford Railroad",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        80
      ],
      "coordinates": "",
      "color": "orange"
    },
    {
      "float_percent": 60,
      "sym": "P&W",
      "name": "Providence and Worcester Railroad",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        80
      ],
      "coordinates": "",
      "color": "brown"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 10
    },
    {
      "name": "3",
      "distance": 3,
      "price": 180,
      "rusts_on": "6E",
      "num": 7
    },
    {
      "name": "4",
      "distance": 4,
      "price": 300,
      "rusts_on": "8E",
      "num": 4
    },
    {
      "name": "5E",
      "distance": 5,
      "price": 500,
      "num": 4
    },
    {
      "name": "6E",
      "distance": 6,
      "price": 600,
      "num": 3
    },
    {
      "name": "8E",
      "distance": 8,
      "price": 800,
      "num": 20
    }
  ],
  "hexes": {
    "white": {
      "": [
        "B16",
        "B6",
        "C13",
        "D10",
        "D12",
        "D14",
        "D16",
        "D2",
        "D6",
        "D8",
        "E3",
        "G3",
        "G7",
        "G9",
        "I11",
        "I3",
        "I9",
        "J10",
        "J12",
        "J4",
        "J8",
        "K11",
        "K13",
        "K7",
        "L2",
        "M11",
        "M9",
        "N10",
        "N8",
        "O9",
        "L6"
      ],
      "upgrade=cost:40,terrain:mountain": [
        "E11",
        "E5",
        "E7",
        "E9",
        "F10",
        "F6",
        "F8",
        "G5",
        "I5",
        "I7"
      ],
      "upgrade=cost:20,terrain:water": [
        "B10",
        "B14",
        "B18",
        "B8",
        "C15",
        "C7",
        "H12",
        "H2",
        "K9",
        "M3"
      ],
      "town=revenue:0": [
        "C17",
        "C9",
        "D4",
        "F14",
        "G11",
        "H14",
        "H6",
        "J14",
        "K5",
        "L8"
      ],
      "city=revenue:0": [
        "C5",
        "E15",
        "F12",
        "F4",
        "I13"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:water": [
        "B12",
        "E13",
        "H4"
      ],
      "town=revenue:20;city=revenue:20": [
        "M7"
      ],
      "town=revenue:0;upgrade=cost:20,terrain:water": [
        "N4"
      ]
    },
    "red": {
      "offboard=revenue:yellow_0|green_20|brown_30|gray_30;path=a:5,b:_0": [
        "B2"
      ],
      "city=revenue:yellow_40|green_50|brown_70|gray_100;path=a:2,b:_0;path=a:3,b:_0": [
        "C19"
      ],
      "city=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0": [
        "F2"
      ],
      "offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:5,b:_0": [
        "K1"
      ],
      "offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:0,b:_0;path=a:1,b:_0": [
        "M1"
      ]
    },
    "gray": {
      "path=a:4,b:5": [
        "A13"
      ],
      "path=a:4,b:5": [
        "B4"
      ],
      "path=a:4,b:5": [
        "A13"
      ],
      "path=a:2,b:3": [
        "E17"
      ],
      "path=a:2,b:3;path=a:3,b:4": [
        "G15"
      ],
      "town=revenue:40;path=a:2,b:_0;path=a:_0,b:3": [
        "O11"
      ]
    },
    "yellow": {
      "city=revenue:30;path=a:_0,b:2;path=a:_0,b:3;upgrade=cost:20,terrain:water;label=Y": [
        "L10"
      ],
      "city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=Y": [
        "C3"
      ],
      "city=revenue:20;path=a:_0,b:0;path=a:_0,b:3": [
        "C11"
      ],
      "city=revenue:30;city=revenue:30;city=revenue:30;path=a:_0,b:1;path=a:_1,b:3;path=a:_2,b:5;label=NH": [
        "G13"
      ],
      "city=revenue:30;path=a:_0,b:1;path=a:_0,b:2;label=H": [
        "H10"
      ],
      "city=revenue:20;city=revenue:20;path=a:_0,b:1;path=a:_1,b:3": [
        "H8"
      ],
      "city=revenue:20;path=a:_0,b:4;path=a:_0,b:5": [
        "J6"
      ],
      "city=revenue:20;path=a:_0,b:0;path=a:_0,b:1;upgrade=cost:20,terrain:water": [
        "K3"
      ],
      "city=revenue:20;town=revenue=10": [
        "L4"
      ],
      "city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=B": [
        "M5"
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
      "operating_rounds": 2
    },
    {
      "name": "3",
      "on": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5",
      "on": "5E",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 2
    },
    {
      "name": "6",
      "on": "6E",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 2
    },
    {
      "name": "8",
      "on": "8E",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 2
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
