# frozen_string_literal: true

# File made by copying and editing g_1889.rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18FL
        JSON = <<-'DATA'
{
  "filename": "18FL",
  "modulename": "18FL",
  "currencyFormatStr": "$%d",
  "bankCash": 8000,
  "certLimit": {
    "2": 21,
    "3": 15,
    "4": 12
  },
  "startingCash": {
    "2": 300,
    "3": 300,
    "4": 300
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": true,
  "locationNames": {
    "A22": "Savannah",
    "B1": "New Orleans",
    "B5": "Mobile",
    "B7": "Pensacola",
    "B13": "Chattahoochee",
    "B15": "Talahassee",
    "B19": "Lake City",
    "B23": "Jacksonville",
    "C14": "St. Marks",
    "C24": "St. Augustine",
    "D19": "Cedar Key",
    "D23": "Palatka",
    "D25": "Daytona",
    "E26": "Titusville",
    "F23": "Orlando",
    "G20": "Tampa",
    "I22": "Punta Gorda",
    "I28": "West Palm Beach",
    "J27": "Fort Lauderdale",
    "K28": "Miami",
    "M24": "Key West",
    "N23": "Havana"
  },
  "tiles": {
    "3": 6,
    "4": 8,
    "6o": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:20,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=O"
    },
    "6fl": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:20,slots:1;path=a:1,b:_0;path=a:3,b:_0;label=FL"
    },
    "8": 10,
    "9": 14,
    "58": 8,

    "15": {
      "count": 2,
      "color": "green",
      "code": "city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K"
    },
    "80": 4,
    "81": 4,
    "82": 6,
    "83": 6,
    "141": 5,
    "142": 5,
    "143": 5,
    "405": {
      "count": 2,
      "color": "green",
      "code": "city=revenue:40,slots:2;path=a:1,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=T"
    },
    "443o": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=O"
    },
    "443fl": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=FL"
    },
    "487": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40,slots:1;city=revenue:40,slots:1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=Jax"
    },

    "63": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=O"
    },
    "146": 8,
    "431": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:60,slots:2;path=a:1,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=T"
    },
    "488": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:50,slots:1;city=revenue:50,slots:1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=Jax"
    },
    "544": 2,
    "545": 2,
    "546": 2,
    "611": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=FL"
    },

    "489": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Jax"
    }
  },
  "market": [[
      "60",
      "65",
      "70p",
      "75p",
      "80p",
      "90p",
      "100p",
      "110p",
      "125",
      "140",
      "160",
      "180",
      "200m",

      "225",
      "250",
      "275",
      "300",
      "330",
      "360",
      "400"
  ]],
  "companies": [
    {
      "name": "Talahassee Railroad",
      "value": 0,
      "discount": -20,
      "revenue": 5,
      "desc": "The winner of this private gets Priority Deal in the first Stock Round. This may be closed to grant a corporation an additional yellow tile lay. Terrain costs must be paid for normally",
      "sym": "TR",
      "abilities": [
        {
          "type": "tile_lay",
          "owner_type": "player",
          "count": 1,
          "free": false,
          "special": false,
          "reachable": true,
          "hexes": [],
          "tiles": [],
          "closed_when_used_up": "true",
          "when": "track"
        }
      ]
    },
    {
      "name": "Peninsular and Occidental Steamship Company",
      "value": 0,
      "discount": -30,
      "revenue": 10,
      "desc": "Closing this private grants the operating Corporation a port token to place on a port city. The port token increases the value of that city by $20 for that corporation only",
      "sym": "POSC",
      "abilities": [
        {
          "type": "assign_hexes",
          "when": "any",
          "hexes": [
            "B5", "B23", "G20", "K28"
          ],
          "count": 1,
          "owner_type": "player"
        },
        {
          "type": "assign_corporation",
          "when": "any",
          "count": 1,
          "owner_type": "player"
        }
      ]
    },
    {
      "name": "Terminal Company",
      "value": 0,
      "discount": -70,
      "revenue": 15,
      "desc": "Allows a Corporation to place an extra token on a city tile of yellow or higher. This is an additional token and free. This token does not use a token slot in the city. This token can be disconnected",
      "sym": "TC",
      "min_players": 3,
      "abilities": [
        {
          "when": "any",

          "extra": "true",

          "type": "token",
          "owner_type": "player",
          "count": 1,
          "from_owner": true,
          "extra_slot": true,
          "special_only": true,
          "price": 0,
          "teleport_price": 0,
          "hexes": [
            "B5", "B15", "B23", "G20", "F23", "J27", "K28"
          ]
        }
      ]
    },
    {
      "name": "Florida East Coast Canal and Transportation Company",
      "value": 0,
      "discount": -110,
      "revenue": 20,
      "desc": "This Company comes with a single share of the Florida East Coast Railway",
      "sym": "FECCTC",
      "min_players": 4,
      "abilities": [
        {
           "type":"close",
           "when": "bought_train",
           "corporation":"FECR"
        },
        {
           "type":"shares",
           "shares":"FECR_1"
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 50,
      "sym": "LN",
      "name": "Louisville and Nashville Railroad",
      "logo": "18_fl/LN",
      "shares": [40, 20, 20, 20],
      "tokens": [
        0,
        20,
        20,
        20
      ],
      "coordinates": "B5",
      "color": "darkblue",
      "type": "medium",
      "always_market_price": true
    },
    {
      "float_percent": 50,
      "sym": "Plant",
      "name": "The Plant System",
      "logo": "18_fl/Plant",
      "shares": [40, 20, 20, 20],
      "tokens": [
        0,
        20,
        20,
        20
      ],
      "coordinates": "B15",
      "color": "deepskyblue",
      "text_color": "black",
      "type": "medium",
      "always_market_price": true
    },
    {
      "float_percent": 50,
      "sym": "SR",
      "name": "Southern Railway",
      "logo": "18_fl/SR",
      "shares": [40, 20, 20, 20],
      "tokens": [
        0,
        20,
        20,
        20
      ],
      "coordinates": "B23",
      "city": 1,
      "color": "brightGreen",
      "type": "medium",
      "always_market_price": true
    },
    {
      "float_percent": 50,
      "sym": "SAL",
      "name": "Seaboard Air Line",
      "logo": "18_fl/SAL",
      "shares": [40, 20, 20, 20],
      "tokens": [
        0,
        20,
        20,
        20
      ],
      "coordinates": "B23",
      "city": 0,
      "color": "orange",
      "type": "medium",
      "always_market_price": true
    },
    {
      "float_percent": 50,
      "sym": "ACL",
      "name": "Atlantic Coast Line",
      "logo": "18_fl/ACL",
      "shares": [40, 20, 20, 20],
      "tokens": [
        0,
        20,
        20,
        20
      ],
      "coordinates": "G20",
      "color": "purple",
      "type": "medium",
      "always_market_price": true
    },
    {
      "float_percent": 50,
      "sym": "FECR",
      "name": "Florida East Coast Railway",
      "logo": "18_fl/FECR",
      "shares": [40, 20, 20, 20],
      "tokens": [
        0,
        20,
        20,
        20
      ],
      "coordinates": "K28",
      "color": "red",
      "type": "medium",
      "always_market_price": true
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": [
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay": 2,
           "visit": 2
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
     ],
      "price": 100,
      "rusts_on": "4",
      "num": 5
    },
    {
      "name": "3",
      "distance": [
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay": 3,
           "visit": 3
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
     ],
      "price": 200,
      "rusts_on": "6",
      "num": 4
    },
    {
      "name": "4",
      "distance": [
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay":4,
           "visit":4
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
     ],
      "price": 400,
      "rusts_on": "D",
      "num": 3
    },
    {
      "name": "5",
      "distance": [
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay": 5,
           "visit": 5
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
     ],
      "price": 500,
      "num": 2,
      "events":[
        {"type": "close_companies"},
        {"type": "close_port"},
        {"type": "forced_conversions"}
      ]
    },
    {
      "name": "6",
      "distance": [
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay": 6,
           "visit": 6
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
     ],
      "price": 600,
      "variants": [
        {
          "name": "3E",
          "distance":[
              {
                  "nodes":[
                      "city",
                      "offboard"
                  ],
                  "pay": 3,
                  "visit": 3,
                  "multiplier": 2
              },
              {
                  "nodes": [
                      "town"
                  ],
                  "pay": 99,
                  "visit": 99,
                  "multiplier": 0
              }
          ],
          "price": 600
        }
      ],
      "num": 7,
      "events": [
        {
          "type": "hurricane"
        }
      ]
    }
  ],
  "hexes": {
    "white": {
      "": [
        "B3", "B9", "B11", "B17", "B21",
        "C12", "C16", "C18", "C20", "C22",
        "D21",
        "E20", "E22", "E24",
        "F21", "F25",
        "G22", "G26",
        "H21"
      ],
      "upgrade=cost:40,terrain:swamp": [
        "G24",
        "H23",
        "I24",
        "J23", "J25",
        "K24"
      ],
      "upgrade=cost:40,terrain:swamp;border=edge:5,type:impassable;border=edge:4,type:impassable": [
        "H25"
      ],
      "upgrade=cost:40,terrain:swamp;border=edge:2,type:impassable;border=edge:3,type:impassable": [
        "I26"
      ],
      "border=edge:0,type:impassable;border=edge:1,type:impassable": [
        "H27"
      ],
      "upgrade=cost:40,terrain:swamp;border=edge:5,type:impassable": [
        "K26"
      ],
      "upgrade=cost:40,terrain:swamp;border=edge:2,type:impassable": [
        "L27"
      ],
      "city=revenue:0;label=FL": [
        "J27"
      ],
      "city=revenue:0;label=O": [
        "F23"
      ],
      "town=revenue:0": [
        "B7", "B13", "B19",
        "C14", "C24",
        "D19", "D23", "D25",
        "E26",
        "I22", "I28"
      ],
      "upgrade=cost:80,terrain:water": [
        "M26"
      ],
      "town=revenue:0;upgrade=cost:80,terrain:water": [
        "M24"
      ]
    },
    "yellow": {
      "city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;label=K;icon=image:port,sticky:1": [
        "B5"
      ],
      "city=revenue:20;path=a:1,b:_0;path=a:4,b:_0;path=a:6,b:_0;label=K": [
        "B15"
      ],
      "city=revenue:30;city=revenue:30;path=a:5,b:_0;path=a:6,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=Jax;icon=image:port,sticky:1": [
        "B23"
      ],
      "city=revenue:30;path=a:5,b:_0;path=a:3,b:_0;label=T;icon=image:port,sticky:1": [
        "G20"
      ],
      "city=revenue:30;path=a:6,b:_0;path=a:2,b:_0;label=T;icon=image:port,sticky:1": [
        "K28"
      ]
    },
    "red": {
      "offboard=revenue:yellow_30|brown_80;path=a:5,b:_0": [
        "A22"
      ],
      "offboard=revenue:yellow_40|brown_70;path=a:4,b:_0": [
        "B1"
      ],
      "offboard=revenue:yellow_60|brown_100;path=a:3,b:_0": [
        "N23"
      ]
    },
    "gray": {
      "": [
        "A2", "A8", "A10", "A12", "A14", "A16", "A18", "A20"
      ],
      "offboard=revenue:yellow_0,visit_cost:99;path=a:5,b:_0": [
        "A4"
      ],
      "offboard=revenue:yellow_0,visit_cost:99;path=a:6,b:_0": [
        "A6"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "train_limit": {
        "medium": 2
      },
      "tiles": [
        "yellow"
      ],
      "corporation_sizes": [5],
      "operating_rounds": 1
    },
    {
      "name": "3",
      "on": "3",
      "train_limit": {
        "medium": 2,
        "large": 4
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "corporation_sizes": [5, 10],
      "operating_rounds": 2,
      "status":[
        "may_convert"
      ]
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": {
        "medium": 1,
        "large": 3
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "corporation_sizes": [5, 10],
      "operating_rounds": 2,
      "status":[
        "may_convert"
      ]
    },
    {
      "name": "5",
      "on": "5",
      "train_limit": {
        "large": 2
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "corporation_sizes": [10],
      "operating_rounds": 3,
      "status":[
        "hotels_doubled"
      ]
    },
    {
      "name": "6",
      "on": ["6", "3E"],
      "train_limit": {
        "large": 2
      },
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "corporation_sizes": [10],
      "operating_rounds": 3,
      "status":[
        "hotels_doubled"
      ]
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
