# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1817
        JSON = <<-'DATA'
{
  "filename": "1817",
  "modulename": "1817",
  "currencyFormatStr": "$%d",
  "bankCash": 99999,
  "certLimit": {
    "3": 21,
    "4": 16,
    "5": 13,
    "6": 11,
    "7": 9
  },
  "startingCash": {
    "3": 420,
    "4": 315,
    "5": 252,
    "6": 210,
    "7": 180
  },
  "capitalization": "incremental",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A20": "Montréal",
    "A28": "Maritime Prov.",
    "B5": "Lansing",
    "B13": "Toronto",
    "B17": "Rochester",
    "C8": "Detroit",
    "C14": "Buffalo",
    "C22": "Albany",
    "C26": "Boston",
    "D1": "Chicago",
    "D7": "Toledo",
    "D9": "Cleveland",
    "D19": "Scranton",
    "E22": "New York",
    "F3": "Indianapolis",
    "F13": "Pittsburgh",
    "F19": "Philadelphia",
    "G6": "Cincinnati",
    "G18": "Baltimore",
    "H1": "St. Louis",
    "H3": "Louisville",
    "H9": "Charleston",
    "I12": "Blacksburg",
    "I16": "Richmond",
    "J7": "Atlanta",
    "J15": "Raleigh-Durham"
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
      "40a",
      "40a",
      "40a",
      "40",
      "45",
      "50",
      "55s",
      "60",
      "65",
      "70s",
      "80",
      "90",
      "100",
      "110",
      "120s",
      "135",
      "150",
      "165",
      "180",
      "200",
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
       "desc" : "Owning corp may place special Pittsburgh yellow tile during tile-laying, regardless of connectivity.  The hex is not reserved, and the power is lost if another company builds there first.",
       "sym" : "PSM",
       "abilities": [
         {
           "type": "tile_lay",
           "hexes": [
             "F13"
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
      "name" : "Ohio Bridge Company",
      "value" : 40,
      "revenue" : 0,
      "desc" : "Comes with one $10 bridge token that may be placed by the owning corp in Louisville, Cincinnati, or Charleston, max one token per city, regardless of connectivity..  Allows owning corp to skip $10 river fee when placing yellow tiles.",
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
            "H3",
            "G6",
            "H9"
          ],
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name" : "Union Bridge Company",
      "value" : 80,
      "revenue" : 0,
      "desc" : "Comes with two $10 bridge token that may be placed by the owning corp in Louisville, Cincinnati, or Charleston, max one token per city, regardless of connectivity..  Allows owning corp to skip $10 river fee when placing yellow tiles.",
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
            "H3",
            "G6",
            "H9"
          ],
          "count": 2,
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
      "desc" : "Comes with one coal mine marker.  When placing a yellow tile in a mountain hex, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra revenue and do not count as a stop.  May not start or end a route at a coal mine.",
      "sym" : "MINC",
      "abilities": [
        {
          "type": "tile_lay",
          "hexes": [
            "B25",
            "C20",
            "C24",
            "E18",
            "F15",
            "G12",
            "G14",
            "H11",
            "H13",
            "H15",
            "I8",
            "I10"
          ],
          "tiles": [
            "7","8", "9"
          ],
          "free": true,
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
      "desc" : "Comes with two coal mine markers.  When placing a yellow tile in a mountain hex, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra revenue and do not count as a stop.  May not start or end a route at a coal mine.",
      "sym" : "CM",
      "abilities": [
        {
          "type": "tile_lay",
          "hexes": [
            "B25",
            "C20",
            "C24",
            "E18",
            "F15",
            "G12",
            "G14",
            "H11",
            "H13",
            "H15",
            "I8",
            "I10"
          ],
          "tiles": [
            "7","8", "9"
          ],
          "free": true,
          "when": "track",
          "owner_type": "corporation",
          "count": 2
        }
      ]
    },
    {
      "name" : "Major Coal Mine",
      "value" : 90,
      "revenue" : 0,
      "desc" : "Comes with three coal mine markers.  When placing a yellow tile in a mountain hex, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra revenue and do not count as a stop.  May not start or end a route at a coal mine.",
      "sym" : "MAJC",
      "abilities": [
        {
          "type": "tile_lay",
          "hexes": [
            "B25",
            "C20",
            "C24",
            "E18",
            "F15",
            "G12",
            "G14",
            "H11",
            "H13",
            "H15",
            "I8",
            "I10"
          ],
          "tiles": [
            "7","8", "9"
          ],
          "free": true,
          "when": "track",
          "owner_type": "corporation",
          "count": 3
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
      "name" : "Mail Contract",
      "value" : 90,
      "revenue" : 0,
      "desc" : "Pays owning corp $15 at the start of each operating round, as long as the company has at least one train.",
      "sym" : "MAIL",
      "abilities": [
        {
          "type": "revenue_change",
          "revenue": 15,
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
      "sym": "A&A",
      "name": "Arcade and Attica",
      "logo": "1817/AA",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "gold"
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
      "num": 20
    },
    {
      "name": "2+",
      "distance": 2,
      "price": 100,
      "obsolete_on": "4",
      "num": 4
    },
    {
      "name": "3",
      "distance": 3,
      "price": 250,
      "rusts_on": "6",
      "num": 12
    },
    {
      "name": "4",
      "distance": 4,
      "price": 400,
      "rusts_on": "8",
      "num": 8
    },
    {
      "name": "5",
      "distance": 5,
      "price": 600,
      "num": 5
    },
    {
      "name": "6",
      "distance": 6,
      "price": 750,
      "num": 4
    },
    {
      "name": "7",
      "distance": 7,
      "price": 900,
      "num": 3
    },
    {
      "name": "8",
      "distance": 8,
      "price": 1100,
      "num": 16,
      "events": [
        {"type": "signal_end_game"}
      ]
    }
  ],
  "hexes": {
    "red": {
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:5,b:_0;path=a:0,b:_0": [
        "A20"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0": [
        "A28"
      ],
      "offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:4,b:_0;path=a:5,b:_0": [
        "D1"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "H1"
      ],
      "offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0": [
        "J7"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:2,b:_0;path=a:3,b:_0": [
        "J15"
      ]
    },
    "white": {
      "city=revenue:0": [
        "B5",
        "B17",
        "C14",
        "C22",
        "F3",
        "F13",
        "F19",
        "I16"
      ],
      "city=revenue:0;upgrade=cost:20": [
        "D7"
      ],
      "city=revenue:0;upgrade=cost:15,terrain:mountain": [
        "D19",
        "I12"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "G6",
        "H3",
        "H9"
      ],
      "upgrade=cost:15,terrain:mountain": [
        "B25",
        "C20",
        "C24",
        "E16",
        "E18",
        "F15",
        "G12",
        "G14",
        "H11",
        "H13",
        "H15",
        "I8",
        "I10"
      ],
      "upgrade=cost:10,terrain:water": [
        "D13",
        "E12",
        "F11",
        "G4",
        "G10",
        "H7"
      ],
      "upgrade=cost:20": [
        "B9",
        "B27",
        "D25",
        "D27",
        "G20",
        "H17"
      ],
      "": [
        "B3",
        "B7",
        "B11",
        "B15",
        "B19",
        "B21",
        "B23",
        "C4",
        "C6",
        "C16",
        "C18",
        "D3",
        "D5",
        "D15",
        "D17",
        "D21",
        "D23",
        "E2",
        "E4",
        "E6",
        "E8",
        "E10",
        "E14",
        "E20",
        "F5",
        "F7",
        "F9",
        "F17",
        "F21",
        "G2",
        "G8",
        "G16",
        "H5",
        "I2",
        "I4",
        "I6",
        "I14"
      ],
      "border=edge:5,type:impassable": [
        "C10"
      ],
      "border=edge:2,type:impassable": [
        "D11"
      ]
    },
    "gray": {
      "town=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "B13"
      ],
      "city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:5,b:_0;path=a:0,b:_0": [
        "D9"
      ],
      "junction;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0": [
        "F1"
      ]
    },
    "yellow": {
      "city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B;upgrade=cost:20,terrain:water": [
        "C8"
      ],
      "city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=B": [
        "C26"
      ],
      "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_1;label=NY;upgrade=cost:20,terrain:water": [
        "E22"
      ],
      "city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B": [
        "G18"
      ]
    },
    "blue": {
      "": [
        "C12"
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
