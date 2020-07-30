# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1846
        JSON = <<-'DATA'
{
  "filename": "1846",
  "modulename": "1846",
  "currencyFormatStr": "$%d",
  "bankCash": {
    "2": 7000,
    "3": 6500,
    "4": 7500,
    "5": 9000
  },
  "certLimit": {
    "3": 14,
    "4": 12,
    "5": 11
  },
  "startingCash": {
    "3": 400,
    "4": 400,
    "5": 400
  },
  "capitalization": "incremental",
  "layout": "pointy",
  "mustSellInBlocks": true,
  "locationNames": {
    "B8": "Holland",
    "B16": "Port Huron",
    "B18": "Sarnia",
    "C5": "Chicago Connections",
    "C9": "South Bend",
    "C15": "Detroit",
    "C17": "Windsor",
    "D14": "Toledo",
    "D20": "Erie",
    "D22": "Buffalo",
    "E11": "Fort Wayne",
    "E17": "Cleveland",
    "E21": "Salamanca",
    "E23": "Binghamton",
    "F20": "Homewood",
    "G3": "Springfield",
    "G7": "Terre Haute",
    "G9": "Indianapolis",
    "G13": "Dayton",
    "G15": "Columbus",
    "G19": "Wheeling",
    "G21": "Pittsburgh",
    "H12": "Cincinnati",
    "H20": "Cumberland",
    "I1": "St. Louis",
    "I5": "Centralia",
    "I15": "Huntington",
    "I17": "Charleston",
    "J10": "Louisville",
    "K3": "Cairo"
  },
  "tiles": {
    "5": 3,
    "6": 4,
    "7": 15,
    "8": 30,
    "9": 30,
    "14": 4,
    "15": 5,
    "16": 2,
    "17": 1,
    "18": 1,
    "19": 2,
    "20": 2,
    "21": 1,
    "22": 1,
    "23": 4,
    "24": 4,
    "25": 2,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "30": 1,
    "31": 1,
    "39": 1,
    "40": 1,
    "41": 2,
    "42": 2,
    "43": 2,
    "44": 1,
    "45": 2,
    "46": 2,
    "47": 2,
    "51": 2,
    "57": 4,
    "70": 1,
    "290": 1,
    "291": 1,
    "292": 1,
    "293": 1,
    "294": 2,
    "295": 2,
    "296": 1,
    "297": 2,
    "298": 1,
    "299": 1,
    "300": 1,
    "611": 4,
    "619": 3
  },
  "market": [
    [
      "0blk",
      "10",
      "20",
      "30",
      "40p",
      "50p",
      "60p",
      "70p",
      "80p",
      "90p",
      "100p",
      "112p",
      "124p",
      "137p",
      "150p",
      "165",
      "180",
      "195",
      "212",
      "230",
      "250",
      "270",
      "295",
      "320",
      "345",
      "375",
      "405",
      "440",
      "475",
      "510",
      "550"
    ]
  ],
  "companies": [
    {
      "name": "Michigan Southern",
      "value": 60,
      "discount": -80,
      "revenue": 0,
      "desc": "Starts with $60 in treasury, a 2 train, and a token in Detroit (C15). Splits revenue evenly with owner. Buyer pays an extra $80 (\"debt\").",
      "sym": "MS"
    },
    {
      "name": "Big 4",
      "value": 40,
      "discount": -60,
      "revenue": 0,
      "desc": "Starts with $40 in treasury, a 2 train, and a token in Indianapolis (G9). Splits revenue evenly with owner. Buyer pays an extra $60 (\"debt\").",
      "sym": "BIG4"
    },
    {
      "name": "Chicago and Western Indiana",
      "value": 60,
      "revenue": 10,
      "desc": "Reserves a token slot in Chicago (D6), when purchased the owning corporation may place an extra token at no cost.",
      "sym": "C&WI",
      "abilities": [
        {
          "type": "token",
          "owner_type":"corporation",
          "hexes": [
            "D6"
          ],
          "price": 0,
          "teleport_price": 0,
          "count": 1,
          "extra": true
        },
        {
          "type": "reservation",
          "hex": "D6",
          "city": 3
        }
      ]
    },
    {
      "name": "Mail Contract",
      "value": 80,
      "revenue": 0,
      "desc": "Adds $10 per location visited by any one train of the owning corporation. Never closes once purchased by a corporation.",
      "sym": "MAIL",
      "abilities": [
        {
          "type": "close",
          "when": "never",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Tunnel Blasting Company",
      "value": 60,
      "revenue": 20,
      "desc": "Reduces, for the owning corporation, the cost of laying all mountain tiles and tunnel/pass hexsides by $20.",
      "sym": "TBC",
      "abilities": [
        {
          "type":"tile_discount",
          "discount": 20,
          "terrain": "mountain",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Meat Packing Company",
      "value": 60,
      "revenue": 15,
      "desc": "The owning corporation may place a $30 marker in either St. Louis (I1) or Chicago (D6), to add $30 to all routes run to this location.",
      "sym": "MPC",
      "abilities": [
        {
          "type": "assign_hexes",
          "hexes": [
            "I1",
            "D6"
          ],
          "count": 1,
          "owner_type": "corporation"
        },
        {
          "type": "assign_corporation",
          "when": "sold",
          "count": 1,
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Steamboat Company",
      "value": 40,
      "revenue": 10,
      "desc": "Place or shift the port marker among port locations (B8, C5, D14, G19, I1). Add $20 per port symbol to all routes run to this location by the owning (or assigned) company.",
      "sym": "SC",
      "abilities": [
        {
          "type": "assign_hexes",
          "hexes": [
            "B8",
            "C5",
            "D14",
            "I1",
            "G19"
          ],
          "count": 1
        },
        {
          "type": "assign_corporation",
          "count": 1
        }
      ]
    },
    {
      "name": "Lake Shore Line",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may make an extra $0 cost tile upgrade of either Cleveland (E17) or Toledo (D14), but not both.",
      "sym": "LSL",
      "abilities": [
        {
           "type":"tile_lay",
           "owner_type":"corporation",
           "free":true,
           "hexes":[
              "D14",
              "E17"
           ],
            "tiles": [
              "14",
              "15",
              "619",
              "294",
              "295",
              "296"
            ],
           "when":"track",
           "count": 1
        }
      ]
    },
    {
      "name": "Michigan Central",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may lay up to two extra $0 cost yellow tiles in the MC's reserved hexes (B10, B12).",
      "sym": "MC",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "B10",
            "B12"
          ]
        },
        {
           "type":"tile_lay",
           "owner_type":"corporation",
           "free":true,
           "hexes":[
              "B10",
              "B12"
           ],
            "tiles": [
              "7",
              "8",
              "9"
            ],
           "when":"track",
           "count": 2
        }
      ]
    },
    {
      "name": "Ohio & Indiana",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may lay up to two extra $0 cost yellow tiles in the O&I's reserved hexes (F14, F16).",
      "sym": "O&I",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "F14",
            "F16"
          ]
        },
        {
           "type":"tile_lay",
           "owner_type":"corporation",
           "free":true,
           "hexes":[
              "F14",
              "F16"
           ],
            "tiles": [
              "7",
              "8",
              "9"
            ],
           "when":"track",
           "count": 2
        }
      ]
    }
  ],
  "minors": [
    {
      "sym": "MS",
      "name": "Michigan Southern",
      "logo": "1846/MS",
      "tokens": [0],
      "coordinates": "C15",
      "color": "pink",
      "text_color": "black"
    },
    {
      "sym": "BIG4",
      "name": "Big 4",
      "logo": "1846/B4",
      "tokens": [0],
      "coordinates": "G9",
      "color": "cyan",
      "text_color": "black"
    }
  ],
  "corporations": [
    {
      "float_percent": 20,
      "sym": "PRR",
      "name": "Pennsylvania",
      "logo": "1846/PRR",
      "tokens": [
        0,
        80,
        80,
        80,
        80
      ],
      "abilities": [
        {
          "type": "token",
          "description": "Reserved $40/$60 Ft. Wayne token",
          "hexes": [
            "E11"
          ],
          "price": 40,
          "teleport_price": 60
        },
        {
          "type": "reservation",
          "hex": "E11",
          "remove": "4"
        }
      ],
      "coordinates": "F20",
      "color": "red",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "NYC",
      "name": "New York Central",
      "logo": "1846/NYC",
      "tokens": [
        0,
        80,
        80,
        80
      ],
      "coordinates": "D20",
      "color": "black",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "B&O",
      "name": "Baltimore & Ohio",
      "logo": "1846/BO",
      "tokens": [
        0,
        80,
        80,
        80
      ],
      "abilities": [
        {
          "type": "token",
          "description": "Reserved $40/$100 Cincinnati token",
          "hexes": [
            "H12"
          ],
          "price": 40,
          "count": 1,
          "teleport_price": 100
        },
        {
          "type": "reservation",
          "hex": "H12",
          "remove": "4"
        }
      ],
      "coordinates": "G19",
      "color": "blue",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "C&O",
      "name": "Chesapeake & Ohio",
      "logo": "1846/CO",
      "tokens": [
        0,
        80,
        80,
        80
      ],
      "coordinates": "I15",
      "color": "lightBlue",
      "text_color": "black",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "ERIE",
      "name": "Erie",
      "logo": "1846/ERIE",
      "tokens": [
        0,
        80,
        80,
        80
      ],
      "abilities": [
        {
          "type": "token",
          "description": "Reserved $40 Erie token",
          "hexes": [
            "D20"
          ],
          "count": 1,
          "price": 40
        },
        {
          "type": "reservation",
          "hex": "D20",
          "slot": 1,
          "remove": "4"
        }
      ],
      "coordinates": "E21",
      "color": "yellow",
      "text_color": "black",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "GT",
      "name": "Grand Trunk",
      "logo": "1846/GT",
      "tokens": [
        0,
        80,
        80
      ],
      "coordinates": "B16",
      "color": "orange",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "IC",
      "name": "Illinois Central",
      "logo": "1846/IC",
      "tokens": [
        0,
        80,
        80,
        80
      ],
      "abilities": [
         {
            "type":"tile_lay",
            "free":true,
            "description": "Free tile lay: E5, F6, G5, H6, J4",
            "hexes":[
               "E5",
               "F6",
               "G5",
               "H6",
               "J4"
            ],
            "tiles": [
              "7",
              "8",
              "9"
            ]
        },
        {
          "type": "token",
          "description": "Reserved $40 Centralia token",
          "hexes": [
            "I5"
          ],
          "count": 1,
          "price": 40
        },
        {
          "type": "reservation",
          "hex": "I5",
          "remove": "4"
        }
      ],
      "coordinates": "K3",
      "color": "green",
      "always_market_price": true
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "obsolete_on": "5",
      "rusts_on": "6"
    },
    {
      "name": "4",
      "distance": 4,
      "price": 180,
      "obsolete_on": "6",
      "variants": [
         {
           "name": "3/5",
           "distance": [
             {
               "nodes": ["city", "offboard"],
               "pay": 3,
               "visit": 5
             }
           ],
           "price": 160
         }
      ]
    },
    {
      "name": "5",
      "distance": 5,
      "price": 500,
      "variants": [
         {
           "name": "4/6",
           "distance": [
             {
               "nodes": ["city", "offboard"],
               "pay": 4,
               "visit": 6
             }
           ],
           "price": 450
         }
      ],
      "events": [
        {"type": "close_companies"}
      ]
    },
    {
      "name": "6",
      "distance": 6,
      "price": 800,
      "variants": [
        {
          "name": "7/8",
          "distance": [
            {
              "nodes": ["city", "offboard"],
              "pay": 7,
              "visit": 8
            }
          ],
          "price": 900
        }
      ],
      "num": 9,
      "events": [
        {"type": "remove_tokens"}
      ]
    }
  ],
  "hexes": {
    "white": {
      "": [
        "B14",
        "C11",
        "C13",
        "D8",
        "D10",
        "D12",
        "E7",
        "E9",
        "E13",
        "E15",
        "F4",
        "F8",
        "F10",
        "F12",
        "G11",
        "H2",
        "H4",
        "H8",
        "H10",
        "I3",
        "I7",
        "I9",
        "J8",
        "D18",
        "B10",
        "B12",
        "F14",
        "F16"
      ],
      "border=edge:5,type:mountain,cost:40": [
        "E19"
      ],
      "icon=image:1846/ic": [
        "E5",
        "F6",
        "G5",
        "H6"
      ],
      "border=edge:4,type:water,cost:40;icon=image:1846/ic": [
        "J4"
      ],
      "border=edge:1,type:water,cost:40": [
        "J6"
      ],
      "border=edge:3,type:water,cost:40": [
        "I11"
      ],
      "city=revenue:0": [
        "C9",
        "E11",
        "G3",
        "G7",
        "G9",
        "G13",
        "G15"
      ],
      "city=revenue:0;border=edge:4,type:mountain,cost:40": [
        "B16"
      ],
      "city=revenue:0;icon=image:port,sticky:1;icon=image:1846/lsl,sticky:1": [
        "D14"
      ],
      "city=revenue:0;label=Z;icon=image:1846/lsl,sticky:1": [
        "E17"
      ],
      "city=revenue:0;label=Z;border=edge:0,type:water,cost:40": [
        "H12"
      ],
      "upgrade=cost:40,terrain:mountain;border=edge:5,type:water,cost:40": [
        "F18"
      ],
      "upgrade=cost:40,terrain:mountain": [
        "H16"
      ],
      "upgrade=cost:40,terrain:mountain;border=edge:4,type:water,cost:20": [
        "G17"
      ],
      "upgrade=cost:60,terrain:mountain": [
        "H14"
      ]
    },
    "gray": {
      "path=a:0,b:5": [
        "A15",
        "C7"
      ],
      "city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:2,type:mountain,cost:40": [
        "F20"
      ],
      "city=revenue:10,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0": [
        "I5"
      ],
      "city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0": [
        "I15"
      ],
      "city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0": [
        "E21"
      ],
      "city=revenue:20;path=a:3,b:_0": [
        "K3"
      ]
    },
    "red": {
      "offboard=revenue:yellow_40|brown_10;path=a:4,b:_0;icon=image:port;icon=image:port": [
        "B8"
      ],
      "offboard=revenue:yellow_30|brown_50,groups:E;icon=image:1846/20;path=a:1,b:_0;label=E;border=edge:1,type:mountain,cost:40 ": [
        "B18"
      ],
      "offboard=revenue:yellow_20|brown_40;icon=image:1846/50;path=a:5,b:_0;label=W;icon=image:port": [
        "C5"
      ],
      "offboard=revenue:yellow_40|brown_60,groups:E;icon=image:1846/30;path=a:1,b:_0;label=E;border=edge:1,type:mountain,cost:60": [
        "C17"
      ],
      "offboard=revenue:yellow_30|brown_60,hide:1,groups:E;icon=image:1846/30;path=a:0,b:_0;border=edge:5": [
        "C21"
      ],
      "offboard=revenue:yellow_30|brown_60,groups:E;icon=image:1846/30;path=a:1,b:_0;label=E;border=edge:2": [
        "D22"
      ],
      "offboard=revenue:yellow_20|brown_50,groups:E;icon=image:1846/30;path=a:1,b:_0;label=E": [
        "E23"
      ],
      "offboard=revenue:yellow_20|brown_50,groups:E;icon=image:1846/20;path=a:1,b:_0;label=E": [
        "I17"
      ],
      "offboard=revenue:yellow_30|brown_70,hide:1,groups:E;icon=image:1846/20;path=a:1,b:_0;border=edge:0": [
        "F22"
      ],
      "offboard=revenue:yellow_30|brown_70,groups:E;icon=image:1846/20;path=a:1,b:_0;path=a:2,b:_0;label=E;border=edge:3": [
        "G21"
      ],
      "offboard=revenue:yellow_20|brown_40,groups:E;icon=image:1846/30;path=a:2,b:_0;label=E": [
        "H20"
      ],
      "offboard=revenue:yellow_50|brown_70,groups:St. Louis;path=a:3,b:_0;path=a:4,b:_0;label=W;icon=image:port;icon=image:1846/meat;icon=image:1846/20": [
        "I1"
      ],
      "offboard=revenue:yellow_50|brown_70,groups:Louisville;path=a:2,b:_0;path=a:3,b:_0": [
        "J10"
      ]
    },
    "yellow": {
      "city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;label=Z;upgrade=cost:40,terrain:water;border=edge:4,type:mountain,cost:60": [
        "C15"
      ],
      "city=revenue:10,groups:Chicago;city=revenue:10,groups:Chicago;city=revenue:10,groups:Chicago;city=revenue:10,groups:Chicago;path=a:0,b:_0;path=a:3,b:_1;path=a:4,b:_2;path=a:5,b:_3;label=Chi;icon=image:1846/meat,sticky:1": [
        "D6"
      ],
      "city=revenue:10,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0": [
        "D20"
      ],
      "city=revenue:10;path=a:5,b:_0;border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:40;border=edge:4,type:mountain,cost:20;icon=image:port,sticky:1;icon=image:port,sticky:1": [
        "G19"
      ]
    },
    "blue": {
      "": [
        "C19",
        "D16"
      ]
    }
  },
  "phases": [
    {
      "name": "1",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 2,
      "buy_companies": true
    },
    {
      "name": "2",
      "train_limit": 4,
      "on": "4",
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "buy_companies": true
    },
    {
      "name": "3",
      "on": "5",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "on": "6",
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
