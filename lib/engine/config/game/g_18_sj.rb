# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18SJ
        JSON = <<-'DATA'
{
  "filename": "18_sj",
  "modulename": "18SJ",
  "currencyFormatStr": "%dkr",
  "bankCash": 12000,
  "certLimit": {
    "2": 28,
    "3": 20,
    "4": 16,
    "5": 13,
    "6": 11
  },
  "startingCash": {
    "2": 1200,
    "3": 800,
    "4": 600,
    "5": 480,
    "6": 400
  },
  "capitalization": "incremental",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A2": "Malmö",
    "A6": "Halmstad",
    "A10": "Göteborg",
    "A16": "Oslo",
    "B5": "Hässleholm",
    "B11": "Alingsås",
    "B31": "Narvik",
    "C2": "Ystad",
    "C8": "Jönköping",
    "C12": "Skövde",
    "C16": "Karlstad",
    "C24": "Östersund",
    "D5": "Kalmar",
    "D11": "Katrineholm",
    "D15": "Köping",
    "D19": "Bergslagen",
    "D21": "Sveg",
    "D29": "Malmfälten",
    "E8": "Norrköping",
    "E12": "Västerås",
    "E20": "Ånge",
    "F13": "Uppsala",
    "F19": "Sundsvall",
    "F23": "Umeå",
    "G10": "Stockholm",
    "G26": "Luleå",
    "H9": "Stockholms hamn"
  },
  "tiles": {
    "5": 4,
    "6": 4,
    "7": 20,
    "8": 20,
    "9": 20,
    "14": 4,
    "15": 4,
    "16": 2,
    "17": 1,
    "18": 1,
    "19": 2,
    "20": 2,
    "21": 1,
    "22": 1,
    "23": 3,
    "24": 3,
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
    "57": 5,
    "63": 2,
    "70": 1,
    "131": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:90,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S"
    },
    "172": 2,
    "298SJ": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=S"
    },
    "299SJ": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:2;path=a:4,b:_2;path=a:_2,b:2;path=a:5,b:_3;path=a:_3,b:2;label=S"
    },
    "440": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y"
    },
    "466": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y"
    },
    "611": 2,
    "619": 3
  },
  "market": [
    [
      "60y",
      "67",
      "71",
      "76",
      "82",
      "90",
      "100p",
      "112",
      "126",
      "142",
      "160",
      "180",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325",
      "350",
      "375e",
      "400e"
    ],
    [
      "53y",
      "60y",
      "66",
      "70",
      "76",
      "82",
      "90p",
      "100",
      "112",
      "126",
      "142",
      "160",
      "180",
      "200",
      "220",
      "240",
      "260",
      "280",
      "300"
    ],
    [
      "46y",
      "55y",
      "60y",
      "65",
      "70",
      "76",
      "82p",
      "90",
      "100",
      "111",
      "125",
      "140",
      "155",
      "170",
      "185",
      "200"
    ],
    [
      "39o",
      "48y",
      "54y",
      "60y",
      "66",
      "71",
      "76p",
      "82",
      "90",
      "100",
      "110",
      "120",
      "130"
    ],
    [
      "32o",
      "41o",
      "48y",
      "55y",
      "62",
      "67",
      "71p",
      "76",
      "82",
      "90",
      "100"
    ],
    [
      "25b",
      "34o",
      "42o",
      "50y",
      "58y",
      "65",
      "67p",
      "71",
      "75",
      "80"
    ],
    [
      "18b",
      "27b",
      "36o",
      "45o",
      "54y",
      "63",
      "67",
      "69",
      "70"
    ],
    [
      "10b",
      "12b",
      "30b",
      "40o",
      "50y",
      "60y",
      "67",
      "68"
    ],
    [
      "",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y",
      "60y"
    ],
    [
      "",
      "",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y"
    ],
    [
      "",
      "",
      "",
      "10b",
      "20b",
      "30b",
      "40o"
    ]
  ],
  "companies": [
    {
      "name": "Frykstadsbanan",
      "value": 20,
      "revenue": 5,
      "desc": "Blocks hex B17 if owned by a player.",
      "sym": "FRY",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "B17"
          ]
        }
      ]
    },
    {
      "name": "Nässjö-Oskarshamns järnväg",
      "value": 20,
      "revenue": 5,
      "desc": "Blocks hex D9 if owned by a player.",
      "sym": "NOJ",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "D9"
          ]
        }
      ]
    },
    {
      "name": "Göta kanalbolag",
      "value": 40,
      "revenue": 10,
      "desc": "Owning corporation may add a hex bonus to each train visit to any of the hexes E8, C8 and C16 in three different ORs. Each train can receive the bonus multiple times. The bonus are 50kr the first time this ability is used, 30kr the second and 20kr the third and last time. Using this ability will not close the prive.",
      "sym": "GKB",
      "abilities": [
        {
        "type": "hex_bonus",
        "owner_type": "corporation",
        "hexes": [
          "C8",
          "C16",
          "E8"
        ],
        "count": 3,
        "amount": 50,
        "when": "route"
      }]
    },
    {
      "name": "Sveabolaget",
      "value": 45,
      "revenue": 15,
      "desc": "May lay or shift port token in Halmstad (A6), Ystad(C2), Kalmar (D5), Sundsvall (F19), Umeå (F23), and Luleå (G26).  Add 30 kr/symbol to all routes run to this location by owning company.",
      "sym": "SB",
      "abilities": [
        {
          "type": "assign_hexes",
          "when": "owning_corp_or_turn",
          "hexes": [
            "A6",
            "C2",
            "D5",
            "F19",
            "F23",
            "G26"
          ],
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "The Gellivare Company",
      "value": 70,
      "revenue": 15,
      "desc": "Two extra track lays in hex E28 and F27.  Blocks hexes E28 and F27 if owned by a player. Reduce terrain cost in D29 and C30 to 25 kr for mountains and 50 kr for the Narvik border.",
      "sym": "GC",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "E28",
            "F27"
          ]
        },
        {
          "type": "tile_lay",
          "owner_type": "corporation",
          "hexes": [
            "E28",
            "F27"
          ],
          "tiles": [
            "7",
            "8",
            "9"
          ],
          "when": ["track", "owning_corp_or_turn"],
          "count": 2
        },
        {
          "type": "tile_discount",
          "discount" : 50,
          "terrain": "mountain",
          "owner_type": "corporation",
          "hexes": [
            "C30",
            "D29"
          ]
        },
        {
          "type": "tile_discount",
          "discount" : 100,
          "terrain": "water",
          "owner_type": "corporation",
          "hexes": [
            "C30"
          ]
        }
      ]
    },
    {
      "name": "Motala Verkstad",
      "value": 90,
      "revenue": 15,
      "desc": "Owning corporation may do a premature buy of one or more trains, just before Run Routes. These trains can be run even if they have run earlier in the OR. If ability is used the owning corporation cannot buy any trains later in the same OR.",
      "sym": "MV",
      "abilities": [
        {
           "type": "train_buy",
           "description": "Buy trains before instead of after Run Routes",
           "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Nydqvist och Holm AB",
      "value": 90,
      "revenue": 20,
      "desc": "May buy one train at half price (one time during the game).",
      "sym": "NOHAB",
      "abilities": [
        {
          "type": "train_discount",
          "discount": 0.50,
          "owner_type": "corporation",
          "trains": [
             "3",
             "4",
             "5"
          ],
          "count": 1,
          "closed_when_used_up": false,
          "when": "buying_train"
        }
     ]
    },
    {
      "name": "Köping-Hults järnväg",
      "value": 140,
      "revenue": 0,
      "desc": "Buy gives control to minor corporation with same name. The minor starts with a 2 train and a home token and splits revenue evenly with owner. The minor may never buy or sell trains.",
      "sym": "KHJ"
    },
    {
      "name": "Nils Ericson",
      "value": 220,
      "revenue": 25,
      "desc": "Receive president's share in a corporation randomly determined before auction. Buying player may once during the game take the priority deal at the beginning of one stock round (and this ability is not lost even if this private is closed). Cannot be bought by any corporation. Closes when the connected corporation buys its first train.",
      "sym": "NE",
      "abilities": [
        {
          "type": "shares",
          "shares": "random_president"
        },
        {
           "type":"no_buy"
        }
      ]
    },
    {
      "name": "Nils Ericson Första Tjing",
      "value": 0,
      "revenue": 0,
      "desc": "This represents the ability to once during the game take over the priority deal at the beginning of a stock round. Cannot be bought by any corporation. This 'company' remains through the whole game, or until the ability is used.",
      "sym": "NEFT",
      "abilities": [
        {
           "type":"no_buy"
        },
        {
          "type": "close",
          "on_phase": "never",
          "owner_type": "player"
        }
      ]
    },
    {
      "name": "Adolf Eugene von Rosen",
      "value": 220,
      "revenue": 30,
      "desc": "Receive president's share in ÖKJ. Cannot be bought by any corporation. Closes when ÖKJ buys its first train.",
      "sym": "AEvR",
      "abilities": [
        {
          "type": "shares",
          "shares": "ÖKJ_0"
        },
        {
           "type":"close",
           "when":"bought_train",
           "corporation":"ÖKJ"
        },
        {
           "type":"no_buy"
        }
      ]
    }
  ],
  "minors":[
    {
       "sym":"KHJ",
       "name":"Köping-Hults järnväg",
       "logo":"18_sj/KHJ",
       "tokens":[
          0
       ],
       "coordinates":"D15",
       "color":"white",
       "text_color":"black"
    }
  ],
  "corporations": [
    {
      "float_percent": 60,
      "sym": "BJ",
      "name": "Bergslagernas järnvägar AB",
      "logo": "18_sj/BJ",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "A10",
      "color": "brown",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "KFJ",
      "name": "Kil-Fryksdalens Järnväg",
      "logo": "18_sj/KFJ",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "C16",
      "color": "pink",
      "text_color":"black",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "MYJ",
      "name": "Malmö-Ystads järnväg",
      "logo": "18_sj/MYJ",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "A2",
      "color": "yellow",
      "text_color":"black",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "MÖJ",
      "name": "Mellersta Östergötlands Järnvägar",
      "logo": "18_sj/MOJ",
      "tokens": [
        0,
        40
      ],
      "coordinates": "E8",
      "color": "turquoise",
      "text_color":"black",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "SNJ",
      "name": "The Swedish-Norwegian Railroad Company ltd",
      "logo": "18_sj/SNJ",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "G26",
      "color": "blue",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "STJ",
      "name": "Sundsvall-Torphammars järnväg",
      "logo": "18_sj/STJ",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "F19",
      "color": "black",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "SWB",
      "name": "Stockholm-Västerås-Bergslagens Järnvägar",
      "logo": "18_sj/SWB",
      "tokens": [
        0,
        40
      ],
      "coordinates": "G10",
      "city": 2,
      "color": "green",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "TGOJ",
      "name": "Trafikaktiebolaget Grängesberg-Oxelösunds järnvägar",
      "logo": "18_sj/TGOJ",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "D19",
      "color": "orange",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "UGJ",
      "name": "Uppsala-Gävle järnväg",
      "logo": "18_sj/UGJ",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "F13",
      "color": "lime",
      "text_color":"black",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "ÖKJ",
      "name": "Örebro-Köpings järnvägsaktiebolag",
      "logo": "18_sj/OKJ",
      "tokens": [
        0,
        40
      ],
      "coordinates": "C12",
      "color": "purple",
      "always_market_price": true
    },
    {
      "float_percent": 60,
      "sym": "ÖSJ",
      "name": "Östra Skånes Järnvägsaktiebolag",
      "logo": "18_sj/OSJ",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "C2",
      "color": "red",
      "always_market_price": true
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": "4",
      "num": 7
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
      "num": 4,
      "events":[
        {"type": "nationalization"}
      ]
    },
    {
      "name": "5",
      "distance": 5,
      "price": 450,
      "num": 3,
      "events":[
        {"type": "close_companies"},
        {"type": "full_cap"}
      ]
    },
    {
      "name": "6",
      "distance": 6,
      "price": 630,
      "num": 2,
      "events":[
        {"type": "nationalization"}
      ]
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
      },
      "variants": [
        {
          "name": "E",
          "price": 1300
        }
      ],
      "events":[
        {"type": "nationalization"}
      ]
    }
  ],
  "hexes": {
    "red": {
      "city=revenue:yellow_20|green_40|brown_50;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;icon=image:18_sj/V,sticky:1": [
        "A2"
      ],
      "city=revenue:yellow_20|green_40|brown_70;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;path=a:0,b:_0,terminal:1;icon=image:18_sj/V,sticky:1;icon=image:18_sj/b_lower_case,sticky:1": [
        "A10"
      ],
      "offboard=revenue:yellow_20|green_30|brown_70;path=a:0,b:_0;icon=image:18_sj/N,sticky:1;icon=image:18_sj/m_lower_case,sticky:1;border=edge:0,type:water,cost:150": [
        "B31"
      ],
      "offboard=revenue:green_30|brown_40;path=a:3,b:_0;icon=image:18_sj/O,sticky:1;icon=image:18_sj/b_lower_case,sticky:1": [
        "H9"
      ]
    },
    "gray": {
      "city=revenue:20;path=a:5,b:_0;path=a:0,b:_0;icon=image:port;icon=image:port": [
        "A6"
      ],
      "city=revenue:yellow_50|green_40|brown_20;path=a:1,b:_0;path=a:5,b:_0;path=a:0,b:_0": [
        "A16"
      ],
      "city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;icon=image:port": [
        "D5"
      ],
      "city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;icon=image:port": [
        "F19"
      ],
      "city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;icon=image:port;icon=image:port": [
        "F23"
      ],
      "city=revenue:20,slots:2;path=a:2,b:_0;path=a:3,b:_0;icon=image:18_sj/m_lower_case,sticky:1;icon=image:port": [
        "G26"
      ]
    },
    "blue": {
      "path=a:4,b:5": [
        "B1"
      ],
      "path=a:3,b:4": [
        "G8"
      ],
      "": [
        "B13",
        "C14"
      ]
    },
    "white": {
      "icon=image:18_sj/M-S,sticky:1": [
        "A4",
        "C6",
        "D7"
      ],
      "icon=image:18_sj/G-S,sticky:1": [
        "D13"
      ],
      "icon=image:18_sj/L-S,sticky:1": [
        "E14",
        "E16",
        "E18",
        "E22",
        "E24",
        "F25",
        "G12"
      ],
      "city=revenue:0;icon=image:18_sj/M-S,sticky:1": [
        "B5"
      ],
      "city=revenue:0;icon=image:18_sj/M-S,sticky:1;icon=image:18_sj/GKB,sticky:1": [
        "E8"
      ],
      "city=revenue:0;icon=image:18_sj/G-S,sticky:1": [
        "E12"
      ],
      "city=revenue:0;icon=image:18_sj/L-S,sticky:1": [
        "F13",
        "E20"
      ],
      "city=revenue:0;border=edge:2,type:mountain,cost:75;icon=image:18_sj/G-S,sticky:1": [
        "C12"
      ],
      "city=revenue:0;border=edge:5,type:mountain,cost:75;icon=image:18_sj/G-S,sticky:1": [
        "B11"
      ],
      "upgrade=cost:75,terrain:mountain": [
        "A12",
        "B19",
        "B21",
        "B23",
        "B25",
        "B27",
        "B29"
      ],
      "upgrade=cost:75,terrain:mountain;border=edge:3,type:water,cost:150": [
        "C30"
      ],
      "border=edge:2,type:impassable;border=edge:3,type:impassable": [
        "D9"
      ],
      "": [
        "B17",
        "A8",
        "A14",
        "B3",
        "B7",
        "B9",
        "B15",
        "C4",
        "C18",
        "C20",
        "C22",
        "C26",
        "C28",
        "D17",
        "D23",
        "D25",
        "D27",
        "D31",
        "E10",
        "E26",
        "E28",
        "E30",
        "F15",
        "F17",
        "F21",
        "F29",
        "G14",
        "G28",
        "F27"
      ],
      "border=edge:0,type:impassable;border=edge:5,type:impassable": [
        "C10"
      ],
      "city=revenue:0": [
        "C24",
        "D21"
      ],
      "city=revenue:0;icon=image:18_sj/GKB,sticky:1": [
        "C16"
      ],
      "city=revenue:0;border=edge:2,type:impassable": [
        "D11"
      ],
      "city=revenue:0;upgrade=cost:75,terrain:mountain;icon=image:18_sj/M,sticky:1": [
        "D29"
      ],
      "upgrade=cost:150,terrain:mountain;icon=image:18_sj/M-S,sticky:1": [
        "F9"
      ],
      "upgrade=cost:75,terrain:mountain;icon=image:18_sj/G-S,sticky:1": [
        "F11"
      ]
    },
    "yellow": {
      "city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y;icon=image:port,sticky:1": [
        "C2"
      ],
      "city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;border=edge:5,type:impassable;icon=image:18_sj/GKB,sticky:1": [
        "C8"
      ],
      "city=revenue:20;path=a:1,b:_0;path=a:5,b:_0": [
        "D15"
      ],
      "city=revenue:20;path=a:5,b:_0;path=a:0,b:_0;icon=image:18_sj/B,sticky:1": [
        "D19"
      ],
      "city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;label=S;icon=image:18_sj/S,sticky:1": [
        "G10"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "on": "2",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1,
      "status":[
        "incremental"
      ]
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
      "status":[
        "incremental",
        "can_buy_companies"
      ]
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
      "status":[
        "incremental",
        "can_buy_companies"
      ]
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
      "status":[
        "fullcap"
      ]
    },
    {
      "name": "6",
      "on": "6",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3,
      "status":[
        "fullcap"
      ]
    },
    {
      "name": "D",
      "on": "D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3,
      "status":[
        "fullcap"
      ]
    },
    {
      "name": "E",
      "on": "E",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3,
      "status":[
        "fullcap"
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
