# frozen_string_literal: true

# TODO: figure out the status of the following in this config.
# trains are correct
# cert limits are correct
# cash is correct
# phases aren't checked yet.
# tiles are not correct.
# market is not correct
# map hexes are not correct
# companies are not correct.
# minors aren't there
# privates aren't correct.

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
    "A11": "Kiel"
  },
  "tiles": {
    "3": 2,
    "5": 2,
    "6": 2,
    "7": 2,
    "8": 5,
    "9": 5
  },
  "market": [
    [
      "54",
      "64",
      "72",
      "78",
      "82"
    ],
    [
      "66",
      "74",
      "80p",
      "84p",
      "86"
    ],
    [
      "76",
      "82",
      "86",
      "88p",
      "92",
      "98"
    ],
    [
      "84",
      "88",
      "90",
      "94",
      "100",
      "108"
    ],
    [
      "90",
      "92",
      "96",
      "102",
      "110",
      "120",
      "132"
    ],
    [
      "98",
      "104",
      "112",
      "122",
      "134",
      "148"
    ],
    [
      "106",
      "114",
      "124",
      "136",
      "150",
      "166"
    ],
    [
      "126",
      "138",
      "152",
      "168",
      "186"
    ],
    [
      "140",
      "154p",
      "170",
      "188",
      "208"
    ],
    [
      "172",
      "190",
      "210",
      "232"
    ],
    [
      "192",
      "212",
      "234",
      "258"
    ],
    [
      "214",
      "236",
      "260",
      "286"
    ],
    [
      "262",
      "288",
      "316"
    ],
    [
      "290",
      "318",
      "348"
    ],
    [
      "320",
      "350",
      "382"
    ],
    [
      "384",
      "418"
    ]
  ],
  "companies": [
    {
      "name": "Private with an icon",
      "sym": "P1",
      "value": 100,
      "revenue": 5,
      "desc": "Description"
    },
    {
      "name": "Private with a company",
      "sym": "P1",
      "value": 140,
      "revenue": 10,
      "desc": "Description"
    },
    {
      "name": "Private with a token",
      "sym": "P1",
      "value": 160,
      "revenue": 15,
      "desc": "Description",
      "min_players": 3
    },
    {
      "name": "Private with a tile",
      "sym": "P1",
      "value": 160,
      "revenue": 15,
      "desc": "This tile (2) is aliased in this game to 57"
    },
    {
      "name": "Private with a custom tile",
      "sym": "P1",
      "value": 180,
      "revenue": 20,
      "desc": "This tile is defined in the game file"
    },
    {
      "name": "Private with Hex and Note",
      "sym": "P1",
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
    "white": {
      "": [
        "A13",
        "B10",
        "B12",
        "B14"
      ],
      "city=revenue:0": [
        "A11"
      ]
    },
    "yellow": {
      "city=revenue:20;path=a:2,b:_0": [
        "C13"
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
