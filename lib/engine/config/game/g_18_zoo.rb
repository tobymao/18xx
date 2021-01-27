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
    "455": 3
  },
  "market": [
    [
      ["7",100,[1]],
      ["8",150,[2]],
      ["9",150,[2]],
      ["10",200,[2,1]],
      ["11",200,[2,2]],
      ["12",250,[3,2]],
      ["13",250,[3,2]],
      ["14",300,[3,2]],
      ["15",350,[3,3]],
      ["16",400,[4]],
      ["20",450,[5]],
      ["24e",0,[6]]
    ],
    [
      ["6",100,[1]],
      ["7x",100,[1]],
      ["8",150,[2]],
      ["9z",150,[2]],
      ["10",200,[2]],
      ["11",200,[2]],
      ["12w",250,[3]],
      ["13",250,[3]],
      ["14",300,[3]]
    ],
    [
      ["5",80,[1]],
      ["6x",100,[1]],
      ["7",100,[2]],
      ["8",150,[2]],
      ["9",150,[2]],
      ["10",200,[2]],
      ["11",200,[2]]
    ],
    [
      ["4",50,[1]],
      ["5x",80,[1]],
      ["6",100,[1]],
      ["7",100,[2]],
      ["8",150,[2]]
    ],
    [
      ["3",40,[0]],
      ["4",50,[1]],
      ["5",80,[1]]
    ],
    [
      ["2",30,[0]],
      ["3",40,[0]]
    ]
  ],
  "companies": [
    {
      "sym": "HOLIDAY",
      "name": "Holiday (SR)",
      "value": 3,
      "desc": "Choose a family, its reputation mark goes one tick to the right."
    },
    {
      "sym": "MIDAS",
      "name": "Midas (SR)",
      "value": 2,
      "desc": "When turn order is appointed, seize the Priority (Squirrel 1)."
    },
    {
      "sym": "TOO_MUCH_RESPONSIBILITY",
      "name": "Too much responsibility (SR)",
      "value": 1,
      "desc": "Get 3$N.",
      "abilities": [
          {
              "type": "description",
              "description": "Get 3$N",
              "when": "any"
          }
      ]
    },
    {
      "sym": "LEPRECHAUN_POT_OF_GOLD",
      "name": "Leprechaun pot of gold (SR)",
      "value": 2,
      "desc": "Earn 2$N now, and at the start of each SR.",
      "abilities": [{
        "type": "no_buy",
        "owner_type": "player"
      }]
    },
    {
      "sym": "IT_S_ALL_GREEK_TO_ME",
      "name": "It’s all greek to me (SR)",
      "value": 2,
      "desc": "After your action in a SR, do another one."
    },
    {
      "sym": "WHATSUP",
      "name": "Whatsup (SR)",
      "value": 3,
      "desc": "During SR, a family can buy the first available squirrel, deactivated. Reputation moves one tick."
    },
    {
      "sym": "RABBITS",
      "name": "Rabbits (OR)",
      "value": 3,
      "desc": "Two bonus upgrades, even illegal or before the phase."
    },
    {
      "sym": "MOLES",
      "name": "Moles (OR)",
      "value": 3,
      "desc": "4 special tiles, that can upgrade any plain tiles, even illegal."
    },
    {
      "sym": "ANCIENT_MAPS",
      "name": "Ancient maps (OR)",
      "value": 1,
      "desc": "Build two additional yellow tiles.",
      "abilities": [{
        "type": "tile_lay",
        "owner_type": "corporation",
        "connect": false,
        "count": 2,
        "free": true,
        "special": false,
        "reachable": true,
        "must_lay_together": true,
        "when":"owning_corp_or_turn",
        "tiles": ["7","8","9","5","6","57","201","202","621"],
        "hexes":[]
      }]
    },
    {
      "sym": "HOLE",
      "name": "Hole (OR)",
      "value": 2,
      "desc": "Mark two R areas anywhere on the map, so they are connected."
    },
    {
      "sym": "ON_DIET",
      "name": "On diet (OR)",
      "value": 3,
      "desc": "Put a depot in addition to the allowed spaces."
    },
    {
      "sym": "SPARKLING_GOLD",
      "name": "Sparkling gold (OR)",
      "value": 1,
      "desc": "Get 2$N / 1$N when you build on a M / MM tile.",
      "abilities": [{
        "type":"tile_discount",
        "discount": 3,
        "terrain": "mountain",
        "count": 1,
        "owner_type": "corporation"
      }, {
        "type": "assign_corporation",
        "when": "sold",
        "count": 1,
        "owner_type": "corporation"
      }]
    },
    {
      "sym": "THAT_S_MINE",
      "name": "That's mine! (OR)",
      "value": 2,
      "desc": "Book anywhere an open place for a station tile."
    },
    {
      "sym": "WORK_IN_PROGRESS",
      "name": "Work in progress (OR)",
      "value": 2,
      "desc": "Block anywhere a free place of a station tile."
    },
    {
      "sym": "CORN",
      "name": "Corn (OR)",
      "value": 2,
      "desc": "Chooses a tile with its own depot; the station worths +30."
    },
    {
      "sym": "TWO_BARRELS",
      "name": "Two barrels (OR)",
      "value": 2,
      "desc": "Use twice, to double the value of all O tiles – don’t collect the O in treasury."
    },
    {
      "sym": "A_SQUEEZE",
      "name": "A squeeze (OR)",
      "value": 2,
      "desc": "Take an additional 3$N if at least one squirrel runs an O."
    },
    {
      "sym": "BANDAGE",
      "name": "Bandage (OR)",
      "value": 1,
      "desc": "Mark a squirrel – it runs as a 1S. It cannot be sold; but can be dismissed (otherwise family cannot purchase new squirrel)."
    },
    {
      "sym": "WINGS",
      "name": "Wings (OR)",
      "value": 2,
      "desc": "During the run, a squirrel at will can skip a tokened-out station."
    },
    {
      "sym": "A_SPOONFUL_OF_SUGAR",
      "name": "A spoonful of sugar (OR)",
      "value": 3,
      "desc": "A squirrel at will runs one more station - not applicable to 4J or 2J."
    }
  ],
  "hexes": {},
  "trains": [
    {
      "name": "2S",
      "distance": [
        {
          "nodes":["city", "offboard"],
          "pay": 2,
          "visit": 2,
          "multiplier": 1
        },
        {
          "nodes": ["town"],
          "pay": 99,
          "visit": 99,
          "multiplier": 1
        }
      ],
      "price": 7,
      "rusts_on": "4S"
    },
    {
      "name": "3S",
      "distance": [
        {
          "nodes":["city", "offboard"],
          "pay": 3,
          "visit": 3,
          "multiplier": 1
        },
        {
          "nodes": ["town"],
          "pay": 99,
          "visit": 99,
          "multiplier": 1
        }
      ],
      "price": 12,
      "rusts_on": "5S",
      "num": 3,
      "events":[
        {"type": "new_train"}
      ]
    },
    {
      "name": "3S Long",
      "distance": [
        {
          "nodes":["city", "offboard"],
          "pay": 3,
          "visit": 3,
          "multiplier": 1
        },
        {
          "nodes": ["town"],
          "pay": 99,
          "visit": 99,
          "multiplier": 1
        }
      ],
      "price": 12,
      "rusts_on": "4J",
      "num": 1
    },
    {
      "name": "4S",
      "distance": [
        {
          "nodes":["city", "offboard"],
          "pay": 4,
          "visit": 4,
          "multiplier": 1
        },
        {
          "nodes": ["town"],
          "pay": 99,
          "visit": 99,
          "multiplier": 1
        }
      ],
      "price": 20,
      "obsolete_on": "4J",
      "num": 3,
      "events":[
        {"type": "new_train"}
      ]
    },
    {
      "name": "5S",
      "distance": [
        {
          "nodes":["city", "offboard"],
          "pay": 5,
          "visit": 5,
          "multiplier": 1
        },
        {
          "nodes": ["town"],
          "pay": 99,
          "visit": 99,
          "multiplier": 1
        }
      ],
      "price": 30,
      "num": 2,
      "events":[
        {"type": "new_train"}
      ]
    },
    {
      "name": "4J",
      "distance": [
        {
          "nodes":["city", "offboard","town"],
          "pay": 4,
          "visit": 4,
          "multiplier": 2
        }
      ],
      "price": 47,
      "num": 99,
      "events":[
        {"type": "new_train"}
      ]
    },
    {
      "name": "2J",
      "distance": [
        {
          "nodes":["city", "offboard","town"],
          "pay": 2,
          "visit": 2,
          "multiplier": 2
        }
      ],
      "price": 37,
      "num": 99,
      "available_on": "4J/2J",
      "events":[
        {"type": "new_train"}
      ]
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
        "can_buy_companies"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3S",
      "on": "3S",
      "train_limit": 4,
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
      "status": [
        "can_buy_companies"
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
      "status": [
        "can_buy_companies"
      ],
      "operating_rounds": 3
    }
  ]
}
        DATA

        JSON_CERT_LIMIT_MAP_SMALL = <<-'DATA'
{
  "certLimit": {
    "2": 10,
    "3": 7,
    "4": 5
  }
}
        DATA

        JSON_STARTING_CASH_MAP_SMALL = <<-'DATA'
{
  "startingCash": {
    "2": 40,
    "3": 28,
    "4": 23
  }
}
        DATA

        JSON_CERT_LIMIT_MAP_LARGE = <<-'DATA'
{
  "certLimit": {
    "2": 12,
    "3": 9,
    "4": 7,
    "5": 6
  }
}
        DATA

        JSON_STARTING_CASH_MAP_LARGE = <<-'DATA'
{
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
  "corporations": [
    {
      "sym": "GI",
      "float_percent": 20,
      "name": "(H2) GIRAFFES",
      "logo": "18_zoo/giraffe",
      "shares": [40,20,20,20,20],
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
      "float_percent": 20,
      "name": "(H3) POLAR BEARS",
      "logo": "18_zoo/polar-bear",
      "shares": [40,20,20,20,20],
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
      "float_percent": 20,
      "name": "(H4) PENGUINS",
      "logo": "18_zoo/penguin",
      "shares": [40,20,20,20,20],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4,
        4
      ],
      "coordinates": "J17",
      "color": "#55b7b7",
      "text_color": "black"
    },
    {
      "sym": "LI",
      "float_percent": 20,
      "name": "(H5) LIONS",
      "logo": "18_zoo/lion",
      "shares": [40,20,20,20,20],
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
      "float_percent": 20,
      "name": "(H6) TIGERS",
      "logo": "18_zoo/tiger",
      "shares": [40,20,20,20,20],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2
      ],
      "coordinates": "G14",
      "color": "#ffa023",
      "text_color": "black"
    }
  ],
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
{}
        DATA

        JSON_MAP_C = <<-'DATA'
{}
        DATA

        JSON_MAP_D = <<-'DATA'
{}
        DATA

        JSON_MAP_E = <<-'DATA'
{}
        DATA

        JSON_MAP_F = <<-'DATA'
{}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
