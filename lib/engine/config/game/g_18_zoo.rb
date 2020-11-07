# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18ZOO
        JSON = <<-'DATA'
{
  "filename": "18_zoo",
  "modulename": "18ZOO",
  "currencyFormatStr": "$%d",
  "bankCash": 99999,
  "capitalization": "incremental",
  "layout": "flat",
  "axes": {
    "rows": "numbers",
    "columns": "letters"
  },
  "mustSellInBlocks": true,
  "certLimit": {
    "2": 0,
    "3": 0,
    "4": 0,
    "5": 0
  },
  "tiles": {
    "7": 6,
    "8": 16,
    "9": 11,
    "5": 2,
    "6": 2,
    "57": 2,
    "201": 2,
    "202": 2,
    "621": 2,
    "19": 1,
    "23": 2,
    "24": 2,
    "25": 2,
    "26": 2,
    "27": 2,
    "28": 1,
    "29": 1,
    "30": 1,
    "31": 1,
    "14": 2,
    "15": 2,
    "619": 2,
    "576": 1,
    "577": 1,
    "579": 1,
    "792": 1,
    "793": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "43": 1,
    "45": 1,
    "46": 1,
    "611": 3,
    "582": 3,
    "455": 3,
    "W7": {
      "count": 0,
      "color": "yellow",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:_0,b:1;upgrade=cost:0,terrain:water"
    },
    "W8": {
      "count": 0,
      "color": "blue",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:_0,b:2;upgrade=cost:0,terrain:water"
    },
    "W9": {
      "count": 0,
      "color": "blue",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;upgrade=cost:0,terrain:water"
    }
  },
  "market": [
    [
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
      "14",
      "15",
      "16",
      "20",
      "24"
    ],
    [
      "6",
      "7p",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
      "14"
    ],
    [
      "5",
      "6p",
      "7",
      "8",
      "9",
      "10",
      "11"
    ],
    [
      "4",
      "5p",
      "6",
      "7",
      "8"
    ],
    [
      "3",
      "4",
      "5"
    ],
    [
      "2",
      "3"
    ]
  ],
  "companies": [
    {
      "sym": "HOLIDAY",
      "name": "HOLIDAY",
      "value": 3,
      "desc": "Choose a family, its reputation mark goes one tick to the right."
    },
    {
      "sym": "MIDAS",
      "name": "MIDAS",
      "value": 2,
      "desc": "When turn order is appointed, seize the Priority (Squirrel 1)."
    },
    {
      "sym": "TOO MUCH RESPONSIBILITY",
      "name": "TOO MUCH RESPONSIBILITY",
      "value": 1,
      "desc": "Get 3$W."
    },
    {
      "sym": "LEPRECHAUN POT OF GOLD",
      "name": "LEPRECHAUN POT OF GOLD",
      "value": 2,
      "desc": "Earn 2$W now, and at the start of each SR."
    },
    {
      "sym": "IT’S ALL GREEK TO ME",
      "name": "IT’S ALL GREEK TO ME",
      "value": 2,
      "desc": "After your action in a SR, do another one."
    },
    {
      "sym": "WHATSUP",
      "name": "WHATSUP",
      "value": 3,
      "desc": "During SR, a family can buy the first available squirrel, deactivated. Reputation moves one tick."
    },
    {
      "sym": "RABBITS",
      "name": "RABBITS",
      "value": 3,
      "desc": "Two bonus upgrades, even illegal or before the phase."
    },
    {
      "sym": "MOLES",
      "name": "MOLES",
      "value": 3,
      "desc": "4 special tiles, that can upgrade any plain tiles, even illegal."
    },
    {
      "sym": "ANCIENT MAPS",
      "name": "ANCIENT MAPS",
      "value": 1,
      "desc": "Build two additional yellow tiles.",
      "abilities": [
        {
          "type": "tile_lay",
          "owner_type": "corporation",
          "count": 2,
          "free": true,
          "special": false,
          "reachable": true,
          "hexes": [
          ],
          "tiles": [
          ],
          "when":"track"
        }
      ]
    },
    {
      "sym": "HOLE",
      "name": "HOLE",
      "value": 2,
      "desc": "Mark two R areas anywhere on the map, so they are connected."
    },
    {
      "sym": "ON DIET",
      "name": "ON DIET",
      "value": 3,
      "desc": "Put a depot in addition to the allowed spaces."
    },
    {
      "sym": "SPARKLING GOLD",
      "name": "SPARKLING GOLD",
      "value": 1,
      "desc": "Get 2$W / 1$W when you build on a M / MM tile."
    },
    {
      "sym": "THAT’S MINE!",
      "name": "THAT’S MINE!",
      "value": 2,
      "desc": "Book anywhere an open place for a station tile."
    },
    {
      "sym": "WORK IN PROGRESS",
      "name": "WORK IN PROGRESS",
      "value": 2,
      "desc": "Block anywhere a free place of a station tile."
    },
    {
      "sym": "CORN",
      "name": "CORN",
      "value": 2,
      "desc": "Chooses a tile with its own depot; the station worths +30."
    },
    {
      "sym": "TWO BARRELS",
      "name": "TWO BARRELS",
      "value": 2,
      "desc": "Use twice, to double the value of all O tiles – don’t collect the O in treasury."
    },
    {
      "sym": "A SQUEEZE",
      "name": "A SQUEEZE",
      "value": 2,
      "desc": "Take an additional 3$W if at least one squirrel runs an O."
    },
    {
      "sym": "BANDAGE",
      "name": "BANDAGE",
      "value": 1,
      "desc": "Mark a squirrel – it runs as a 1S. It cannot be sold; but can be dismissed (otherwise family cannot purchase new squirrel)."
    },
    {
      "sym": "WINGS",
      "name": "WINGS",
      "value": 2,
      "desc": "During the run, a squirrel at will can skip a tokened-out station."
    },
    {
      "sym": "A SPOONFUL OF SUGAR",
      "name": "A SPOONFUL OF SUGAR",
      "value": 3,
      "desc": "A squirrel at will runs one more station - not applicable to 4J or 2J."
    }
  ],
  "corporations": [],
  "hexes": {},
  "trains": [
    {
      "name": "2S",
      "distance": 2,
      "price": 7,
      "rusts_on": "4S",
      "num": 1
    },
    {
      "name": "3S",
      "distance": 3,
      "price": 12,
      "rusts_on": "5S",
      "num": 4
    },
    {
      "name": "4S",
      "distance": 4,
      "price": 20,
      "rusts_on": "4J/2J",
      "num": 3
    },
    {
      "name": "5S",
      "distance": 5,
      "price": 30,
      "num": 2
    },
    {
      "name": "4J",
      "distance": 4,
      "price": 47,
      "num": 20
    },
    {
      "name": "2J",
      "distance": 2,
      "price": 37,
      "num": 20,
      "available_on": "4J"
    }
  ],
  "phases": [
    {
      "name": "2S",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "status": [
        "can_buy_companies", "can_buy_companies_from_other_players"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3S",
      "on": "3S",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_companies", "can_buy_companies_from_other_players"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4S",
      "on": "4S",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_companies"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5S",
      "on": "5S",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4J/2J",
      "on": "4J",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3
    }
  ]
}
        DATA

        JSON_MAP_SMALL = <<-'DATA'
{
  "certLimit": {
    "2": 10,
    "3": 7,
    "4": 5
  },
  "startingCash": {
    "2": 40,
    "3": 28,
    "4": 23
  }
}
        DATA

        JSON_MAP_LARGE = <<-'DATA'
{
  "certLimit": {
    "2": 12,
    "3": 9,
    "4": 7,
    "5": 6
  },
  "startingCash": {
    "2": 48,
    "3": 32,
    "4": 27,
    "5": 22
  }
}
        DATA

        JSON_MAP_A = <<-'DATA'
{
  "corporations": [
    {
      "sym": "GI",
      "float_percent": 40,
      "name": "GIRAFFES",
      "logo": "18_zoo/giraffe",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2
      ],
      "coordinates": "J9",
      "color": "#fff793",
      "text_color": "black"
    },
    {
      "sym": "PB",
      "float_percent": 40,
      "name": "POLAR BEARS",
      "logo": "18_zoo/polar-bear",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4,
        4
      ],
      "coordinates": "M10",
      "color": "#efebeb",
      "text_color": "black"
    },
    {
      "sym": "PE",
      "float_percent": 40,
      "name": "PENGUINS",
      "logo": "18_zoo/penguin",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4,
        4
      ],
      "coordinates": "J17",
      "color": "#55b7b7"
    },
    {
      "sym": "LI",
      "float_percent": 40,
      "name": "LIONS",
      "logo": "18_zoo/lion",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4
      ],
      "coordinates": "D15",
      "color": "#df251a"
    },
    {
      "sym": "TI",
      "float_percent": 40,
      "name": "TIGERS",
      "logo": "18_zoo/tiger",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2
      ],
      "coordinates": "G14",
      "color": "#ffa023"
    }
  ],
  "locationNames": {
    "B11": "O",
    "B13": "O",
    "E18": "O",
    "G10": "O",
    "H9": "O",
    "H11": "O",
    "I2": "O",
    "K14": "O",
    "M12": "O",
    "M14": "O",
    "D11": "MM",
    "E10": "MM",
    "F17": "MM",
    "G18": "MM",
    "J3": "MM",
    "K18": "MM",
    "M16": "MM",
    "C12": "M",
    "H15": "M",
    "I14": "M",
    "D17": "M"
  },
  "hexes": {
    "gray": {
      "": [
        "B9",
        "C8",
        "J5",
        "L13"
      ],
      "path=a:0,b:1": [
        "M8"
      ],
      "path=a:0,b:3": [
        "F9"
      ],
      "path=a:0,b:4": [
        "H3"
      ],
      "path=a:0,b:5": [
        "A10"
      ],
      "path=a:1,b:3": [
        "K6"
      ],
      "path=a:2,b:3": [
        "G20"
      ],
      "path=a:2,b:4": [
        "J19"
      ],
      "path=a:3,b:5": [
        "A12"
      ],
      "path=a:1,b:4;path=a:3,b:5": [
        "G16"
      ],
      "path=a:0,b:4;path=a:1,b:4": [
        "L15"
      ],
      "path=a:0,b:4;path=a:4,b:5": [
        "J7"
      ],
      "offboard=revenue:0,hide:1;path=a:0,b:_0": [
        "D7"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0": [
        "L3",
        "N9"
      ],
      "offboard=revenue:0,hide:1;path=a:2,b:_0": [
        "I6",
        "K10"
      ],
      "offboard=revenue:0,hide:1;path=a:3,b:_0": [
        "F21"
      ],
      "offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4": [
        "L9"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5": [
        "K8"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4": [
        "H13"
      ]
    },
    "red": {
      "offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R": [
        "L5",
        "M18"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R": [
        "E8"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R": [
        "B17"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R": [
        "H19"
      ]
    },
    "white": {
      "": [
        "I4",
        "H5",
        "F7",
        "H7",
        "G8",
        "I8",
        "C10",
        "I10",
        "F11",
        "J11",
        "L11",
        "E12",
        "G12",
        "I12",
        "K12",
        "D13",
        "F13",
        "J13",
        "C14",
        "E14",
        "B15",
        "F15",
        "C16",
        "E16",
        "I16",
        "K16",
        "H17",
        "L17",
        "I18"
      ],
      "city=revenue:0,slots:1": [
        "J9",
        "M10",
        "J17",
        "D15",
        "G14"
      ],
      "upgrade=cost:0,terrain:water": [
        "B11",
        "B13",
        "E18",
        "G10",
        "H9",
        "H11",
        "I2",
        "K14",
        "M12",
        "M14"
      ],
      "upgrade=cost:1,terrain:mountain": [
        "C12",
        "H15",
        "I14",
        "D17"
      ],
      "upgrade=cost:2,terrain:mountain": [
        "D11",
        "E10",
        "F17",
        "G18",
        "J3",
        "K18",
        "M16"
      ],
      "label=Y;city=revenue:yellow_30|green_40|brown_50,slots:1;offboard=revenue:yellow_20|brown_40,hide:1": [
        "D9",
        "F19",
        "J15",
        "K4"
      ]
    }
  }
}
        DATA

        JSON_MAP_B = <<-'DATA'
{
  "certLimit": {
    "2": 10,
    "3": 7,
    "4": 5
  },
  "startingCash": {
    "2": 40,
    "3": 28,
    "4": 23
  },
  "corporations":[],
  "hexes":{}
}
        DATA

        JSON_MAP_C = <<-'DATA'
{
  "certLimit": {
    "2": 10,
    "3": 7,
    "4": 5
  },
  "startingCash": {
    "2": 40,
    "3": 28,
    "4": 23
  },
  "corporations":[],
  "hexes":{}
}
        DATA

        JSON_MAP_D = <<-'DATA'
{
  "corporations": [
    {
      "sym": "CR",
      "float_percent": 40,
      "name": "CROCODILES",
      "logo": "18_zoo/crocodile",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "coordinates": "G3",
      "color": "#fff793",
      "text_color": "black"
    },
    {
      "sym": "GI",
      "float_percent": 40,
      "name": "GIRAFFES",
      "logo": "18_zoo/giraffe",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2
      ],
      "coordinates": "J10",
      "color": "#fff793",
      "text_color": "black"
    },
    {
      "sym": "PB",
      "float_percent": 40,
      "name": "POLAR BEARS",
      "logo": "18_zoo/polar-bear",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4,
        4
      ],
      "coordinates": "M11",
      "color": "#efebeb",
      "text_color": "black"
    },
    {
      "sym": "PE",
      "float_percent": 40,
      "name": "PENGUINS",
      "logo": "18_zoo/penguin",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4,
        4
      ],
      "coordinates": "J18",
      "color": "#55b7b7"
    },
    {
      "sym": "LI",
      "float_percent": 40,
      "name": "LIONS",
      "logo": "18_zoo/lion",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4
      ],
      "coordinates": "D16",
      "color": "#df251a"
    },
    {
      "sym": "TI",
      "float_percent": 40,
      "name": "TIGERS",
      "logo": "18_zoo/tiger",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2
      ],
      "coordinates": "G15",
      "color": "#ffa023"
    },
    {
      "sym": "BB",
      "float_percent": 40,
      "name": "BROWN BEAR",
      "logo": "18_zoo/brown-bear",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "coordinates": "H6",
      "color": "#ffa023"
    }
  ],
  "locationNames": {
    "B12": "O",
    "B14": "O",
    "E19": "O",
    "F2": "O",
    "G1": "O",
    "G11": "O",
    "H10": "O",
    "H12": "O",
    "I3": "O",
    "K15": "O",
    "M13": "O",
    "M15": "O",
    "C13": "M",
    "D18": "M",
    "H16": "M",
    "I15": "M",
    "J6": "M",
    "D12": "MM",
    "E11": "MM",
    "F18": "MM",
    "G19": "MM",
    "J4": "MM",
    "K7": "MM",
    "K19": "MM",
    "M17": "MM"
  },
  "hexes": {
    "gray": {
      "": [
        "B10",
        "C9",
        "L14"
      ],
      "path=a:0,b:1": [
        "F4",
        "H0",
        "M9"
      ],
      "path=a:0,b:3": [
        "F10"
      ],
      "path=a:0,b:5": [
        "A11","F0"
      ],
      "path=a:2,b:3": [
        "G21"
      ],
      "path=a:2,b:4": [
        "J20"
      ],
      "path=a:3,b:5": [
        "A13"
      ],
      "path=a:4,b:5": [
        "E5"
      ],
      "path=a:0,b:4;path=a:1,b:4": [
        "L16"
      ],
      "path=a:1,b:4;path=a:3,b:5": [
        "G17"
      ],
      "path=a:0,b:4;path=a:4,b:5": [
        "J8"
      ],
      "offboard=revenue:0,hide:1;path=a:0,b:_0;path=a:4,b:_0": [
        "D8"
      ],
      "junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0": [
        "H4"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0": [
        "L4", "N10"
      ],
      "offboard=revenue:0,hide:1;path=a:2,b:_0": [
        "K11"
      ],
      "offboard=revenue:0,hide:1;path=a:3,b:_0": [
        "F22"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5": [
        "K9"
      ],
      "offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4": [
        "L10"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4": [
        "H14"
      ]
    },
    "red": {
      "offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R": [
        "L6"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R": [
        "M19"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R": [
        "E9"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R": [
        "B18"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R": [
        "H20"
      ]
    },
    "white": {
      "": [
        "B16",
        "C11",
        "C15",
        "C17",
        "D14",
        "E7",
        "E13",
        "E15",
        "E17",
        "F8",
        "F12",
        "F14",
        "F16",
        "G5",
        "G7",
        "G9",
        "G13",
        "H2",
        "H8",
        "H18",
        "I5",
        "I7",
        "I9",
        "I11",
        "I13",
        "I17",
        "I19",
        "J12",
        "J14",
        "K13",
        "K17",
        "L12",
        "L18"
      ],
      "city=revenue:0,slots:1": [
        "D16",
        "G3",
        "G15",
        "H6",
        "J10",
        "J18",
        "M11"
      ],
      "upgrade=cost:0,terrain:water": [
        "B12",
        "B14",
        "E19",
        "F2",
        "G1",
        "G11",
        "H10",
        "H12",
        "I3",
        "K15",
        "M13",
        "M15"
      ],
      "upgrade=cost:1,terrain:mountain": [
        "C13",
        "D18",
        "H16",
        "I15",
        "J6"
      ],
      "upgrade=cost:2,terrain:mountain": [
        "D12",
        "E11",
        "F18",
        "G19",
        "J4",
        "K7",
        "K19",
        "M17"
      ],
      "label=Y;city=revenue:yellow_30|green_40|brown_50,slots:1;offboard=revenue:yellow_20|brown_40,hide:1": [
        "D10",
        "F6",
        "F20",
        "J16",
        "K5"
      ]
    }
  }
}
        DATA

        JSON_MAP_E = <<-'DATA'
{
  "certLimit": {
    "2": 12,
    "3": 9,
    "4": 7,
    "5": 6
  },
  "startingCash": {
    "2": 48,
    "3": 32,
    "4": 27,
    "5": 22
  },
  "corporations":[],
  "hexes":{}
}
        DATA

        JSON_MAP_F = <<-'DATA'
{
  "certLimit": {
    "2": 12,
    "3": 9,
    "4": 7,
    "5": 6
  },
  "startingCash": {
    "2": 48,
    "3": 32,
    "4": 27,
    "5": 22
  },
  "corporations":[],
  "hexes":{}
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
