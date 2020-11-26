# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1817NA
        JSON = <<-'DATA'
{
  "filename": "1817_na",
  "modulename": "1817NA",
  "currencyFormatStr": "$%d",
  "bankCash": 99999,
  "certLimit": {
    "2": 21,
    "3": 16,
    "4": 13,
    "5": 11,
    "6": 9
  },
  "startingCash": {
    "2": 420,
    "3": 315,
    "4": 252,
    "5": 210,
    "6": 180
  },
  "capitalization": "incremental",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A7": "Dawson City",
    "B2": "Anchorage",
    "B6": "The Klondike",
    "B18": "Arctic",
    "C3": "Asia",
    "C9": "Hazelton",
    "D12": "Edmonton",
    "D16": "Winnipeg",
    "D22": "Quebec",
    "D26": "Europe",
    "E9": "Seattle",
    "F14": "Denver",
    "F20": "Toronto",
    "F22": "New York",
    "H8": "Hawaii",
    "H10": "Los Angeles",
    "H18": "New Orleans",
    "I13": "Guadalajara",
    "I15": "Mexico City",
    "I21": "Miami",
    "J18": "Belize",
    "K21": "South America"
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
       "name" : "Denver Telecommunications",
       "value" : 40,
       "revenue" : 0,
       "desc" : "Owning corp may place special Denver yellow tile during tile-laying, regardless of connectivity.  The hex is not reserved, and the power is lost if another company builds there first.",
       "sym" : "DTC",
       "abilities": [
         {
           "type": "tile_lay",
           "hexes": [
             "F14"
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
      "name" : "Mountain Engineers",
      "value" : 40,
      "revenue" : 0,
      "desc" : "Owning company receives $20 after laying a yellow tile in a mountain hex.  Any fees must be paid first.",
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
      "name" : "Union Bridge Company",
      "value" : 80,
      "revenue" : 0,
      "desc" : "Comes with two $10 bridge token that may be placed by the owning corp in Winnipeg or New Orleans, max one token per city, regardless of connectivity..  Allows owning corp to skip $10 river fee when placing yellow tiles.",
      "sym" : "UBC",
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
            "D16",
            "H18"
          ],
          "count": 2,
          "show_count": true,
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
      "desc" : "Comes with one coal mine marker.  When placing a yellow tile in a mountain hex next to a revenue location, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra revenue and do not count as a stop.  May not start or end a route at a coal mine.",
      "sym" : "MINC",
      "abilities": [
        {
          "type": "tile_lay",
          "hexes": [
            "B24",
            "C19",
            "C23",
            "E17",
            "F14",
            "G11",
            "G13",
            "H10",
            "H12",
            "H14",
            "I7",
            "I9"
          ],
          "tiles": [
            "7","8", "9"
          ],
          "free": false,
          "when": "track",
          "owner_type": "corporation",
          "count": 1,
          "show_count": true
        }
      ]
    },
    {
      "name" : "Major Coal Mine",
      "value" : 90,
      "revenue" : 0,
      "desc" : "Comes with three coal mine markers.  When placing a yellow tile in a mountain hex next to a revenue location, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra revenue and do not count as a stop.  May not start or end a route at a coal mine.",
      "sym" : "MAJC",
      "abilities": [
        {
          "type": "tile_lay",
          "hexes": [
            "B24",
            "C19",
            "C23",
            "E17",
            "F14",
            "G11",
            "G13",
            "H10",
            "H12",
            "H14",
            "I7",
            "I9"
          ],
          "tiles": [
            "7","8", "9"
          ],
          "free": false,
          "when": "track",
          "owner_type": "corporation",
          "count": 3,
          "show_count": true
        }
      ]
    },
    {
      "name" : "Minor Mail Contract",
      "value" : 60,
      "revenue" : 0,
      "desc" : "Pays owning corp $10 at the start of each operating round, as long as the company has at least one train.",
      "sym" : "MINM",
      "abilities": [
        {
          "type": "revenue_change",
          "revenue": 10,
          "when": "has_train",
          "owner_type": "corporation"
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
      "sym": "J",
      "name": "Elgin, Joliet and Eastern Railway",
      "logo": "1817/J",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "text_color": "black",
      "color": "green"
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
      "sym": "NYOW",
      "name": "New York, Ontario and Western Railway",
      "logo": "1817/W",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "turquoise"
    },
    {
      "float_percent": 20,
      "sym": "NYSW",
      "name": "New York, Susquehanna and Western Railway",
      "logo": "1817/S",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "white",
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
      "sym": "PLE",
      "name": "Pittsburgh and Lake Erie Railroad",
      "logo": "1817/PLE",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "lime"
    },
    {
      "float_percent": 20,
      "sym": "PW",
      "name": "Providence and Worcester Railroad",
      "logo": "1817/PW",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "text_color": "black",
      "color": "lightBrown"
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
      "sym": "SR",
      "name": "Strasburg Railroad",
      "logo": "1817/SR",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "natural"
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
      "sym": "WT",
      "name": "Warren & Trumbull Railroad",
      "logo": "1817/WT",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "lavender"
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
      "num": 31
    },
    {
      "name": "2+",
      "distance": 2,
      "price": 100,
      "obsolete_on": "4",
      "num": 3
    },
    {
      "name": "3",
      "distance": 3,
      "price": 250,
      "rusts_on": "6",
      "num": 8
    },
    {
      "name": "4",
      "distance": 4,
      "price": 400,
      "rusts_on": "8",
      "num": 6
    },
    {
      "name": "5",
      "distance": 5,
      "price": 600,
      "num": 4
    },
    {
      "name": "6",
      "distance": 6,
      "price": 750,
      "num": 3
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
      "num": 30,
      "events": [
        {"type": "signal_end_game"}
      ]
    }
  ],
  "hexes": {
    "white": {
      "upgrade=cost:15,terrain:mountain": [
        "A3",
        "B4",
        "B8",
        "B10",
        "D10",
        "E11",
        "E13",
        "F12",
        "G13",
        "G19",
        "H12",
        "J14"
      ],
      "": [
        "A5",
        "A9",
        "B12",
        "C7",
        "C11",
        "C13",
        "C15",
        "C17",
        "C23",
        "D18",
        "D20",
        "D24",
        "E21",
        "E23",
        "F10",
        "G9",
        "G11",
        "G15",
        "G21",
        "H14",
        "H16",
        "H20",
        "J16",
        "K17",
        "K19"
      ],
      "border=edge:0,type:impassable;border=edge:1,type:impassable": [
        "E19"
      ],
      "border=edge:4,type:impassable": [
        "E17"
      ],
      "border=edge:3,type:impassable": [
        "F18"
      ],
      "city=revenue:0;upgrade=cost:15,terrain:mountain": [
        "A7"
      ],
      "city=revenue:0": [
        "B2",
        "C9",
        "D22",
        "E9",
        "F14",
        "F20",
        "H10",
        "I13"
      ],
      "city=revenue:0;border=edge:3,type:impassable": [
        "J18"
      ],
      "upgrade=cost:20,terrain:lake": [
        "D8",
        "E25",
        "J20"
      ],
      "upgrade=cost:20,terrain:lake;border=edge:0,type:impassable": [
        "I19"
      ],
      "upgrade=cost:10,terrain:water": [
        "D14",
        "E15",
        "F16",
        "G17"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "H18",
        "D16"
      ]
    },
    "gray": {
      "town=revenue:yellow_50|green_20|brown_40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0": [
        "B6"
      ],
      "path=a:1,b:4": [
        "B14",
        "C19"
      ],
      "path=a:1,b:5": [
        "B16",
        "C21"
      ],
      "city=revenue:yellow_30|green_50|brown_60|gray_80;path=a:1,b:_0;path=a:_0,b:2;path=a:0,b:_0;path=a:_0,b:1": [
        "I21"
      ]
    },
    "red": {
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0": [
        "B18"
      ],
      "offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0": [
        "C3"
      ],
      "offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:1,b:_0;path=a:0,b:_0": [
        "D26"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:3,b:_0;path=a:4,b:_0": [
        "H8"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:1,b:_0;path=a:2,b:_0": [
        "K21"
      ]
    },
    "yellow": {
      "city=revenue:30;path=a:2,b:_0;path=a:_0,b:4;label=B": [
        "D12"
      ],
      "city=revenue:40;city=revenue:40;path=a:3,b:_1;path=a:0,b:_0;label=NY;upgrade=cost:20,terrain:lake": [
        "F22"
      ],
      "city=revenue:30;path=a:1,b:_0;path=a:_0,b:5;label=B;upgrade=cost:20,terrain:lake": [
        "I15"
      ]
    },
    "blue": {
      "offboard=revenue:yellow_0,visit_cost:99;path=a:3,b:_0": [
        "I17",
        "C1",
        "F8",
        "I9",
        "J12"
      ],
      "offboard=revenue:yellow_0,visit_cost:99;path=a:2,b:_0;offboard=revenue:yellow_0,visit_cost:99;path=a:4,b:_0": [
        "I11"
      ],
      "offboard=revenue:yellow_0,visit_cost:99;path=a:5,b:_0": [
        "A1"
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
