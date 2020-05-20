# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1889
        JSON = <<-DATA
{
  "filename": "1889",
  "modulename": "1889",
  "currencyFormatStr": "¥%d",
  "bankCash": 7000,
  "certLimit": {
    "2": 25,
    "3": 19,
    "4": 14,
    "5": 12,
    "6": 11
  },
  "startingCash": {
    "2": 420,
    "3": 420,
    "4": 420,
    "5": 390,
    "6": 390
  },
  "locationNames": {
    "F3": "Saijou",
    "G4": "Niihama",
    "H7": "Ikeda",
    "A10": "Sukumo",
    "J11": "Anan",
    "G12": "Nahari",
    "E2": "Matsuyama",
    "I2": "Marugame",
    "K8": "Tokushima",
    "C10": "Kubokawa",
    "J5": "Ritsurin Kouen",
    "G10": "Nangoku",
    "J9": "Komatsujima",
    "I12": "Muki",
    "B11": "Nakamura",
    "I4": "Kotohira",
    "C4": "Ohzu",
    "K4": "Takamatsu",
    "B7": "Uwajima",
    "B3": "Yawatahama",
    "G14": "Muroto",
    "F1": "Imabari",
    "J1": "Sakaide & Okayama",
    "L7": "Naruto & Awaji",
    "F9": "Kouchi"
  },
  "tiles": {
    "3": 2,
    "5": 2,
    "6": 2,
    "7": 2,
    "8": 5,
    "9": 5,
    "12": 1,
    "13": 1,
    "14": 1,
    "15": 3,
    "16": 1,
    "19": 1,
    "20": 1,
    "23": 2,
    "24": 2,
    "25": 1,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "39": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "45": 1,
    "46": 1,
    "47": 1,
    "57": 2,
    "58": 3,
    "205": 1,
    "206": 1,
    "437": 1,
    "438": 1,
    "439": 1,
    "440": 1,
    "448": 4,
    "465": 1,
    "466": 1,
    "492": 1,
    "611": 2
  },
  "market": [
    [
      "75",
      "80",
      "90",
      "100p",
      "110",
      "125",
      "140",
      "155",
      "175",
      "200",
      "225",
      "255",
      "285",
      "315",
      "350"
    ],
    [
      "70",
      "75",
      "80",
      "90p",
      "100",
      "110",
      "125",
      "140",
      "155",
      "175",
      "200",
      "225",
      "255",
      "285",
      "315"
    ],
    [
      "65",
      "70",
      "75",
      "80p",
      "90",
      "100",
      "110",
      "125",
      "140",
      "155",
      "175",
      "200"
    ],
    [
      "60",
      "65",
      "70",
      "75p",
      "80",
      "90",
      "100",
      "110",
      "125",
      "140"
    ],
    [
      "55",
      "60",
      "65",
      "70p",
      "75",
      "80",
      "90",
      "100"
    ],
    [
      "50y",
      "55",
      "60",
      "65p",
      "70",
      "75",
      "80"
    ],
    [
      "45y",
      "50y",
      "55",
      "60",
      "65",
      "70"
    ],
    [
      "40y",
      "45y",
      "50y",
      "55",
      "60"
    ],
    [
      "30o",
      "40y",
      "45y",
      "50y"
    ],
    [
      "20o",
      "30o",
      "40y",
      "45y"
    ],
    [
      "10o",
      "20o",
      "30o",
      "40y"
    ]
  ],
  "companies": [
    {
      "name": "Takamatsu E-Railroad",
      "value": 20,
      "revenue": 5,
      "desc": "Blocks Takamatsu (K4).",
      "sym": "TR",
      "abilities": [
        {
          "type": "blocks_hexes",
          "hexes": [
            "K4"
          ]
        }
      ]
    },
    {
      "name": "Mitsubishi Ferry",
      "value": 30,
      "revenue": 5,
      "desc": "Player owner may place the port tile on a coastal town (B11, G10, I12, or J9) without a tile on it already, outside of the operating rounds of a company controlled by another player. The player need not control a company or have connectivity to the placed tile from one of their companies. This does not close the company.",
      "sym": "MF",
      "abilities": [
        {
          "type": "tile_lay",
          "hexes": [
            "B11",
            "G10",
            "I12",
            "J9"
          ],
          "tiles": [
            "437"
          ],
          "owner_type": "player"
        }
      ]
    },
    {
      "name": "Ehime Railway",
      "value": 40,
      "revenue": 10,
      "desc": "When this company is sold to a corporation, the selling player may immediately place a green tile on Ohzu (C4), in addition to any tile which it may lay during the same operating round. This does not close the company.",
      "sym": "ER",
      "abilities": [
        {
          "type": "blocks_hexes",
          "hexes": [
            "C4"
          ]
        },
        {
          "type": "tile_lay",
          "hexes": [
            "C4"
          ],
          "tiles": [
            "12",
            "13",
            "14",
            "15",
            "205",
            "206"
          ],
          "when": "sold",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Sumitomo Mines Railway",
      "value": 50,
      "revenue": 15,
      "desc": "Owning corporation may ignore building cost for mountain hexes which do not also contain rivers. This does not close the company.",
      "abilities": [
        {
          "type": "ignore_terrain",
          "terrain": "mountain",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Dougo Railway",
      "value": 60,
      "revenue": 15,
      "desc": "Owning player may exchange this private company for a 10% share of Iyo Railway from the initial offering.",
      "abilities": [
        {
          "type": "exchange",
          "corporation": "IR",
          "owner_type": "player"
        }
      ]
    },
    {
      "name": "South Iyo Railway",
      "value": 80,
      "revenue": 20,
      "desc": "No special abilities.",
      "min_players": 3
    },
    {
      "name": "Uno-Takamatsu Ferry",
      "value": 150,
      "revenue": 30,
      "desc": "Does not close while owned by a player. If owned by a player when the first 5-train is purchased it may no longer be sold to a public company and the revenue is increased to 50.",
      "min_players": 4,
      "abilities": [
        {
          "type": "never_closes",
          "owner_type": "player"
        },
        {
          "type": "revenue_change",
          "revenue": 50,
          "when": "5",
          "owner_type": "player"
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 50,
      "sym": "AR",
      "name": "Awa Railroad",
      "logo": "1889/AR",
      "tokens": [
        0,
        40
      ],
      "coordinates": "K8",
      "color": "#37383a"
    },
    {
      "float_percent": 50,
      "sym": "IR",
      "name": "Iyo Railway",
      "logo": "1889/IR",
      "tokens": [
        0,
        40
      ],
      "coordinates": "E2",
      "color": "#f48221"
    },
    {
      "float_percent": 50,
      "sym": "SR",
      "name": "Sanuki Railway",
      "logo": "1889/SR",
      "tokens": [
        0,
        40
      ],
      "coordinates": "I2",
      "color": "#76a042"
    },
    {
      "float_percent": 50,
      "sym": "KO",
      "name": "Takamatsu & Kotohira Electric Railway",
      "logo": "1889/KO",
      "tokens": [
        0,
        40
      ],
      "coordinates": "K4",
      "color": "#d81e3e"
    },
    {
      "float_percent": 50,
      "sym": "TR",
      "name": "Tosa Electric Railway",
      "logo": "1889/TR",
      "tokens": [
        0,
        40,
        40
      ],
      "coordinates": "F9",
      "color": "#00a99e"
    },
    {
      "float_percent": 50,
      "sym": "KU",
      "name": "Tosa Kuroshio Railway",
      "logo": "1889/KU",
      "tokens": [
        0
      ],
      "coordinates": "C10",
      "color": "#0189d1"
    },
    {
      "float_percent": 50,
      "sym": "UR",
      "name": "Uwajima Railway",
      "logo": "1889/UR",
      "tokens": [
        0,
        40,
        40
      ],
      "coordinates": "B7",
      "color": "#7b352a"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": "4",
      "num": 6
    },
    {
      "name": "3",
      "distance": 3,
      "price": 180,
      "rusts_on": "6",
      "num": 5
    },
    {
      "name": "4",
      "distance": 4,
      "price": 300,
      "rusts_on": "D",
      "num": 4
    },
    {
      "name": "5",
      "distance": 5,
      "price": 450,
      "num": 3
    },
    {
      "name": "6",
      "distance": 6,
      "price": 630,
      "num": 2
    },
    {
      "name": "D",
      "distance": 999,
      "price": 1100,
      "num": 20,
      "available_on": "6",
      "discount": {
        "4": 300,
        "5": 300,
        "6": 300
      }
    }
  ],
  "hexes": {
    "white": {
      "blank": [
        "D3",
        "H3",
        "J3",
        "B5",
        "C8",
        "E8",
        "I8",
        "D9",
        "I10"
      ],
      "city": [
        "F3",
        "G4",
        "H7",
        "A10",
        "J11",
        "G12",
        "E2",
        "I2",
        "K8",
        "C10"
      ],
      "town": [
        "J5",
        "G10",
        "J9",
        "I12",
        "B11"
      ],
      "u=c:80,t:water": [
        "K6"
      ],
      "u=c:80,t:water+mountain": [
        "H5",
        "I6"
      ],
      "u=c:80,t:mountain": [
        "E4",
        "D5",
        "F5",
        "C6",
        "E6",
        "G6",
        "D7",
        "F7",
        "A8",
        "G8",
        "B9",
        "H9",
        "H11",
        "H13"
      ],
      "c=r:0;l=H;u=c:80": [
        "I4"
      ]
    },
    "yellow": {
      "c=r:20;p=a:2,b:_0": [
        "C4"
      ],
      "c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T": [
        "K4"
      ]
    },
    "gray": {
      "c=r:40,s:2;p=a:1,b:_0;p=a:3,b:_0;p=a:5,b:_0": [
        "B7"
      ],
      "t=r:20;p=a:0,b:_0;p=a:_0,b:5": [
        "B3"
      ],
      "t=r:20;p=a:3,b:_0;p=a:_0,b:4": [
        "G14"
      ],
      "p=a:1,b:5": [
        "J7"
      ]
    },
    "red": {
      "o=r:yellow_30|brown_60|diesel_100;p=a:0,b:_0;p=a:1,b:_0": [
        "F1"
      ],
      "o=r:yellow_20|brown_40|diesel_80;p=a:0,b:_0;p=a:1,b:_0": [
        "J1"
      ],
      "o=r:yellow_20|brown_40|diesel_80;p=a:1,b:_0;p=a:2,b:_0": [
        "L7"
      ]
    },
    "green": {
      "c=r:30,s:2;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=K;u=c:80,t:water": [
        "F9"
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
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
