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
  "currencyFormatStr": "%d$N",
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
      "24e"
    ],
    [
      "6",
      "7x",
      "8",
      "9z",
      "10",
      "11",
      "12w",
      "13",
      "14"
    ],
    [
      "5",
      "6x",
      "7",
      "8",
      "9",
      "10",
      "11"
    ],
    [
      "4",
      "5x",
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
      "name": "Holiday (SR)",
      "value": 3,
      "desc": "Choose a family, its reputation mark goes one tick to the right.",
      "abilities": [{
        "type": "no_buy",
        "owner_type": "player"
      }]
    },
    {
      "sym": "MIDAS",
      "name": "Midas (SR)",
      "value": 2,
      "desc": "When turn order is appointed, seize the Priority (Squirrel 1).",
      "abilities": [{
        "type": "no_buy",
        "owner_type": "player"
      }]
    },
    {
      "sym": "TOO_MUCH_RESPONSIBILITY",
      "name": "Too much responsibility (SR)",
      "value": 1,
      "desc": "Get 3$N.",
      "abilities": [{
        "type": "no_buy",
        "owner_type": "player"
      },{
        "type": "description",
        "description": "Get 3$N",
        "when": "any"
      }]
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
      "desc": "After your action in a SR, do another one.",
      "abilities": [{
        "type": "no_buy",
        "owner_type": "player"
      }]
    },
    {
      "sym": "WHATSUP",
      "name": "Whatsup (SR)",
      "value": 3,
      "desc": "During SR, a family can buy the first available squirrel, deactivated. Reputation moves one tick.",
      "abilities": [{
        "type": "no_buy",
        "owner_type": "player"
      }]
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
  ],
  "certLimit": {
    "2": { "5": 10, "7": 12 },
    "3": { "5": 7, "7": 9 },
    "4": { "5": 5, "7": 7 },
    "5": { "5": 0, "7": 6 }
  },
  "startingCash": {},
  "locationNames": {},
  "corporations": [
    {
      "sym": "CR",
      "float_percent": 20,
      "name": "(H1) CROCODILES",
      "logo": "18_zoo/crocodile",
      "shares": [40,20,20,20,20],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [0,2,4,4],
      "color": "#00af14"
    },
    {
      "sym": "GI",
      "float_percent": 20,
      "name": "(H2) GIRAFFES",
      "logo": "18_zoo/giraffe",
      "shares": [40,20,20,20,20],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [0,2],
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
      "tokens": [0,2,4,4],
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
      "tokens": [0,2,4,4],
      "color": "#55b7b7"
    },
    {
      "sym": "LI",
      "float_percent": 20,
      "name": "(H5) LIONS",
      "logo": "18_zoo/lion",
      "shares": [40,20,20,20,20],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [0,2,4],
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
      "tokens": [0,2],
      "color": "#ffa023"
    },
    {
      "sym": "BB",
      "float_percent": 20,
      "name": "(H7) BROWN BEAR",
      "logo": "18_zoo/brown-bear",
      "shares": [40,20,20,20,20],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [0,2,4],
      "color": "#ae6d1d"
    },
    {
      "sym": "EL",
      "float_percent": 20,
      "name": "(H8) ELEPHANT",
      "logo": "18_zoo/elephant",
      "shares": [40,20,20,20,20],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [0,2,4],
      "color": "#858585"
    }
  ],
  "hexes": {}
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
