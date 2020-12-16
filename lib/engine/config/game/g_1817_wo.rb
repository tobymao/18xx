# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1817WO
        JSON = <<-'DATA'
{
  "filename": "1817_wo",
  "modulename": "1817WO",
  "currencyFormatStr": "$%d",
  "bankCash": 99999,
  "certLimit": {
    "2": 16,
    "3": 13,
    "4": 11,
    "5": 9
  },
  "startingCash": {
    "2": 330,
    "3": 240,
    "4": 195,
    "5": 168
  },
  "capitalization": "incremental",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "C2": "Prince of Wales Fort",
    "D7": "Amazonia",
    "G4": "Mare Nostrum",
    "G8": "Beginnings",
    "I2": "Brrrrrrrrrr!",
    "I6": "New Pittsburgh",
    "K4": "Dynasties",
    "K8": "Terra Australis",
    "A2": "Gold Rush",
    "A6": "Kingdom of Hawai'i",
    "D9": "Antarctica",
    "F1": "Vikings",
    "H9": "Libertalia",
    "J9": "You are lost",
    "L1": "Gold Rush",
    "L9": "Nieuw Zeeland"
  },
  "tiles": {
    "5": "unlimited",
    "6": "unlimited",
    "7": "unlimited",
    "8": "unlimited",
    "9": "unlimited",
    "14": "unlimited",
    "15": "unlimited",
    "54": "unlimited",
    "57": "unlimited",
    "62": "unlimited",
    "63": "unlimited",
    "80": "unlimited",
    "81": "unlimited",
    "82": "unlimited",
    "83": "unlimited",
    "448": "unlimited",
    "544": "unlimited",
    "545": "unlimited",
    "546": "unlimited",
    "592": "unlimited",
    "593": "unlimited",
    "597": "unlimited",
    "611": "unlimited",
    "619": "unlimited",
    "X00": {
      "count": "unlimited",
      "color": "yellow",
      "code": "city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B"
    },
    "X30": {
      "count": "unlimited",
      "color": "gray",
      "code": "city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY"
    }
  },
  "market": [
    [
      "0l",
      "0a",
      "0a",
      "0a",
      "40",
      "45",
      "50p",
      "55s",
      "60p",
      "65p",
      "70s",
      "80p",
      "90p",
      "100p",
      "110p",
      "120s",
      "135p",
      "150p",
      "165p",
      "180p",
      "200p",
      "220",
      "245",
      "270",
      "300",
      "330",
      "360",
      "400",
      "440",
      "490",
      "540",
      "600"
    ]
  ],
  "companies": [
    {
       "name" : "Pittsburgh Steel Mill",
       "value" : 40,
       "revenue" : 0,
       "desc" : "Owning corp may place special 'New Pittsburgh' yellow tile during tile-laying, regardless of connectivity.  The hex is not reserved, and the power is lost if another company builds there first.",
       "sym" : "PSM",
       "abilities": [
         {
           "type": "tile_lay",
           "hexes": [
             "I6"
           ],
           "tiles": [
             "X00"
           ],
           "when": "track",
           "owner_type": "corporation",
           "count": 1
         }
       ]
    },
    {
      "name" : "Mountain (Ocean) Engineers",
      "value" : 40,
      "revenue" : 0,
      "desc" : "Owning company receives $20 after laying a yellow tile in a mountain (ocean) hex.  Any fees must be paid first.",
      "sym" : "ME",
      "abilities": [
        {
            "type": "tile_income",
            "income" : 20,
            "terrain": "mountain",
            "owner_type": "corporation",
            "owner_only": true
        }
      ]
    },
    {
      "name" : "Ohio Bridge Company",
      "value" : 40,
      "revenue" : 0,
      "desc" : "Comes with one $10 bridge token that may be placed by the owning corp in Mare Nostrum or Dynasties max one token per city, regardless of connectivity..  Allows owning corp to skip $10 river fee when placing yellow tiles.",
      "sym" : "OBC",
      "abilities": [
        {
          "type": "tile_discount",
          "discount" : 10,
          "terrain": "water",
          "owner_type": "corporation"
        },
        {
          "type": "assign_hexes",
          "hexes": [
            "G4", "K4"
          ],
          "count":1,
          "when": "owning_corp_or_turn",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name" : "Train Station",
      "value" : 80,
      "revenue" : 0,
      "desc" : "Provides an additional station marker for the owning corp, awarded at time of purchase",
      "sym" : "TS",
      "abilities": [
        {
            "type": "additional_token",
            "count" : 1,
            "owner_type": "corporation"
        }
      ]
    },
    {
      "name" : "Minor Coal Mine",
      "value" : 30,
      "revenue" : 0,
      "desc" : "Comes with one coal mine marker.  When placing a yellow tile in a ocean hex next to a revenue location, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra revenue and do not count as a stop.  May not start or end a route at a coal mine. C8 may not have a coal mine.",
      "sym" : "MINC",
      "abilities": [
        {
          "type": "tile_lay",
          "hexes": [
            "B7",
            "E4", "E2",
            "F9",
            "I8",
            "K6",
            "L5"
          ],
          "tiles": [
            "7","8", "9"
          ],
          "free": false,
          "when": "track",
          "owner_type": "corporation",
          "count": 1
        }
      ]
    },
    {
      "name" : "Coal Mine",
      "value" : 60,
      "revenue" : 0,
      "desc" : "Comes with two coal mine markers.  When placing a yellow tile in a mountain hex next to a revenue location, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra revenue and do not count as a stop.  May not start or end a route at a coal mine. C8 may not have a coal mine.",
      "sym" : "CM",
      "abilities": [
        {
          "type": "tile_lay",
          "hexes": [
            "B7",
            "E4", "E2",
            "F9",
            "I8",
            "K6",
            "L5"
          ],
          "tiles": [
            "7","8", "9"
          ],
          "free": false,
          "when": "track",
          "owner_type": "corporation",
          "count": 2
        }
      ]
    },
    {
      "name" : "Major Mail Contract",
      "value" : 120,
      "revenue" : 0,
      "desc" : "Pays owning corp $20 at the start of each operating round, as long as the company has at least one train.",
      "sym" : "MAJM",
      "abilities": [
        {
          "type": "revenue_change",
          "revenue": 20,
          "when": "has_train",
          "owner_type": "corporation"
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 20,
      "sym": "A&S",
      "name": "Alton & Southern Railway",
      "logo": "1817/AS",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "pink"
    },
    {
      "float_percent": 20,
      "sym": "Belt",
      "name": "Belt Railway of Chicago",
      "logo": "1817/Belt",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "text_color": "black",
      "color": "orange"
    },
    {
      "float_percent": 20,
      "sym": "Bess",
      "name": "Bessemer and Lake Erie Railroad",
      "logo": "1817/Bess",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "black"
    },
    {
      "float_percent": 20,
      "sym": "B&A",
      "name": "Boston and Albany Railroad",
      "logo": "1817/BA",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "red"
    },
    {
      "float_percent": 20,
      "sym": "DL&W",
      "name": "Delaware, Lackawanna and Western Railroad",
      "logo": "1817/DLW",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "brown"
    },
    {
      "float_percent": 20,
      "sym": "GT",
      "name": "Grand Trunk Western Railroad",
      "logo": "1817/GT",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "violet"
    },
    {
      "float_percent": 20,
      "sym": "H",
      "name": "Housatonic Railroad",
      "logo": "1817/H",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "text_color": "black",
      "color": "lightBlue"
    },
    {
      "float_percent": 20,
      "sym": "ME",
      "name": "Morristown and Erie Railway",
      "logo": "1817/ME",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "yellow",
      "text_color": "black"
    },
    {
      "float_percent": 20,
      "sym": "PSNR",
      "name": "Pittsburgh, Shawmut and Northern Railroad",
      "logo": "1817/PSNR",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "brightGreen"
    },
    {
      "float_percent": 20,
      "sym": "R",
      "name": "Rutland Railroad",
      "logo": "1817/R",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "blue"
    },
    {
      "float_percent": 20,
      "sym": "UR",
      "name": "Union Railroad",
      "logo": "1817/UR",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "navy"
    },
    {
      "float_percent": 20,
      "sym": "WC",
      "name": "West Chester Railroad",
      "logo": "1817/WC",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "gray"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 48
    },
    {
      "name": "2+",
      "distance": 2,
      "price": 100,
      "num": 2
    },
    {
      "name": "3",
      "distance": 3,
      "price": 250,
      "rusts_on": "6",
      "num": 7
    },
    {
      "name": "4",
      "distance": 4,
      "price": 400,
      "rusts_on": "8",
      "num": 5
    },
    {
      "name": "5",
      "distance": 5,
      "price": 600,
      "num": 3
    },
    {
      "name": "6",
      "distance": 6,
      "price": 750,
      "num": 2
    },
    {
      "name": "7",
      "distance": 7,
      "price": 900,
      "num": 2
    },
    {
      "name": "8",
      "distance": 8,
      "price": 1100,
      "num": 32
    }
  ],
  "hexes": {
    "white": {
      "": [
        "B3",
        "B5",
        "C6",
        "D3",
        "D5",
        "E6",
        "E8",
        "F3",
        "F5",
        "G2",
        "G6",
        "H1",
        "H5",
        "H7",
        "J5",
        "J7",
        "L3",
        "L7"
      ],
      "upgrade=cost:15,terrain:lake": [

        "B7",
        "C8",
        "E2",
        "E4",
        "F9",
        "I8",
        "K6",
        "L5"
      ],
      "upgrade=cost:10,terrain:water": [
        "H3",
        "I4",
        "J3"
      ],
      "upgrade=cost:20": [
        "B1",
        "F7",
        "K2"
      ],
      "city=revenue:0;upgrade=cost:15,terrain:lake": [
        "C2"
      ],
      "city=revenue:0": [
        "G8",
        "I2",
        "I6",
        "K8"
      ],
      "city=revenue:0;upgrade=cost:20": [
        "D7"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "G4",
        "K4"
      ]
    },
    "gray": {
      "path=a:0,b:1;path=a:1,b:5;path=a:0,b:5": [
        "J1"
      ],
      "city=revenue:yellow_10|green_20|brown_30|gray_40;path=a:4,b:_0;path=a:_0,b:5": [
        "A6"
      ],
      "city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;path=a:1,b:_0;path=a:5,b:_0": [
        "F1"
      ],
      "town=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0;path=a:_0,b:4": [
        "H9"
      ],
      "city=revenue:0": [
        "L9"
      ]
    },
    "yellow": {
      "city=revenue:40;city=revenue:40;path=a:2,b:_0;path=a:5,b:_1;label=NY;upgrade=cost:20": [
        "C4"
      ]
    },
    "red": {
      "offboard=revenue:yellow_30|green_50|brown_20|gray_60;path=a:4,b:_0": [
        "A2"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:2,b:_0;path=a:4,b:_0": [
        "D9"
      ],
      "offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:3,b:_0;path=a:4,b:_0": [
        "J9"
      ],
      "offboard=revenue:yellow_30|green_50|brown_20|gray_60;path=a:1,b:_0": [
        "L1"
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
      "operating_rounds": 2,
      "corporation_sizes": [2]
    },
    {
      "name": "2+",
      "on": "2+",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 2,
      "corporation_sizes": [2]
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
      "corporation_sizes": [2, 5]
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
      "corporation_sizes": [5]
    },
    {
      "name": "5",
      "on": "5",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 2,
      "corporation_sizes": [5, 10]
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
      "operating_rounds": 2,
      "corporation_sizes": [10]
    },
    {
      "name": "7",
      "on": "7",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 2,
      "corporation_sizes": [10]
    },
    {
      "name": "8",
      "on": "8",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "status": [
        "no_new_shorts"
      ],
      "operating_rounds": 2,
      "corporation_sizes": [10]
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
