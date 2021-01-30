# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1861
        JSON = <<-'DATA'
{
  "filename": "1861",
  "modulename": "1861",
  "currencyFormatStr": "$%d",
  "bankCash": 15000,
  "certLimit": {
    "3": 21,
    "4": 16,
    "5": 13,
    "6": 11
  },
  "startingCash": {
    "3": 420,
    "4": 315,
    "5": 252,
    "6": 210
  },
  "capitalization": "incremental",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "D2": "Timmins ($80 if includes T/M/Q)",
    "D8": "Sudbury",
    "F8": "North Bay",
    "E13": "Barrie",
    "E15": "Guelph",
    "E17": "Hamilton",
    "D16": "Berlin",
    "C17": "London",
    "G15": "Peterborough",
    "I15": "Kingston",
    "J12": "Ottawa",
    "M9": "Trois-Rivières",
    "O7": "Quebec",
    "N12": "Sherbrooke",
    "C15": "Goderich",
    "B18": "Sarnia",
    "H14": "Belleville",
    "H10": "Pembroke",
    "K13": "Cornwall",
    "L10": "St. Jerome",
    "M13": "Granby",
    "L12": "Montreal",
    "F16": "Toronto",
    "A7": "Sault Ste. Marie",
    "F18": "Buffalo",
    "M15": "New England",
    "O13": "Maine",
    "P8": "Maritime Provinces",
    "A19": "Detroit"
  },
  "tiles": {
    "3": 2,
    "4": 4,
    "5": 2,
    "6": 2,
    "7": "unlimited",
    "8": "unlimited",
    "9": "unlimited",
    "14": 2,
    "15": 2,
    "16": 2,
    "17": 2,
    "18": 2,
    "19": 2,
    "20": 2,
    "21": 2,
    "22": 2,
    "23": 5,
    "24": 5,
    "25": 4,
    "26": 2,
    "27": 2,
    "28": 2,
    "29": 2,
    "30": 2,
    "31": 2,
    "39": 2,
    "40": 2,
    "41": 2,
    "42": 2,
    "43": 2,
    "44": 2,
    "45": 2,
    "46": 2,
    "47": 2,
    "57": 2,
    "58": 4,
    "63": 3,
    "87": 2,
    "88": 2,
    "201": 3,
    "202": 3,
    "204": 2,
    "207": 5,
    "208": 2,
    "611": 3,
    "619": 2,
    "621": 2,
    "622": 2,
    "623": 3,
    "624": 1,
    "625": 1,
    "626": 1,
    "635": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40,loc:0.5;city=revenue:40,loc:2.5;city=revenue:40,loc:4.5;path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;path=a:2,b:_1;path=a:_1,b:3;label=K"
    },
    "636": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K"
    },
    "637":  {
      "count": 1,
      "color": "green",
      "code": "city=revenue:50,loc:0.5;city=revenue:50,loc:2.5;city=revenue:50,loc:4.5;path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;path=a:2,b:_1;path=a:_1,b:3;label=M"
    },
    "638":  {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M"
    },
    "639": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=M"
    },
    "640": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Kh"
    },
    "641": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=S"
    },
    "642": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=S"
    },
    "801": 2,
    "911": 3
  },
  "market": [
    [
      "",
      "",
      "",
      "",
      "135",
      "150",
      "165mC",
      "180",
      "200z",
      "220",
      "245",
      "270",
      "300",
      "330",
      "360",
      "400",
      "440",
      "490",
      "540"
    ],
    [
      "",
      "",
      "",
      "110",
      "120",
      "135",
      "150mC",
      "165z",
      "180z",
      "200",
      "220",
      "245",
      "270",
      "300",
      "330",
      "360",
      "400",
      "440",
      "490"
    ],
    [
      "",
      "",
      "90",
      "100",
      "110",
      "120",
      "135pmC",
      "150z",
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
      "440"
    ],
    [
      "",
      "70",
      "80",
      "90",
      "100",
      "110p",
      "120pmC",
      "135",
      "150",
      "165",
      "180",
      "200"
    ],
    [
      "60",
      "65",
      "70",
      "80",
      "90p",
      "100p",
      "110mC",
      "120",
      "135",
      "150"
    ],
    [
      "55",
      "60",
      "65",
      "70p",
      "80p",
      "90",
      "100mC",
      "110"
    ],
    [
      "50",
      "55",
      "60x",
      "65x",
      "70",
      "80"
    ],
    [
      "45",
      "50x",
      "55x",
      "60",
      "65"
    ],
    [
      "40",
      "45",
      "50",
      "55"
    ],
    [
      "35",
      "40",
      "45"
    ]
  ],
  "companies": [
    {
      "name": "rules until start of phase 3",
      "sym": "3",
      "value": 3,
      "revenue": 0,
      "desc": "Hidden corporation",
      "abilities": [
        {
        "type": "blocks_hexes",
        "hexes": [
          "M13"
        ]
      }]
    },
    {
      "name": "Tsarskoye Selo Railway",
      "sym": "TSR",
      "value": 30,
      "revenue": 10,
      "discount": 10,
      "desc": "No special abilities."
    },
    {
      "name": "Black Sea Shipping Company",
      "sym": "BSS",
      "value": 45,
      "revenue": 15,
      "discount": 15,
      "desc": "When owned by a corporation, they gain $10 extra revenue for each of their routes that include Odessa",
      "abilities": [
        {
        "type": "hex_bonus",
        "owner_type": "corporation",
        "hexes": [
          "D20"
        ],
        "amount": 10
      }]
    },
    {
      "name": "Moskow - Yaroslavl Railway",
      "sym": "MYR",
      "value": 60,
      "revenue": 20,
      "discount": 20,
      "desc": "When owned by a corporation, they gain $10 extra revenue for each of their routes that include Moskow",
      "abilities": [
        {
        "type": "hex_bonus",
        "owner_type": "corporation",
        "hexes": [
          "H8"
        ],
        "amount": 10
      }]
    },
    {
      "name": "Moskow - Ryazan Railway",
      "sym": "MRR",
      "value": 75,
      "revenue": 25,
      "discount": 25,
      "desc": "When owned by a corporation, they gain $10 extra revenue for each of their routes that include Moskow",
      "abilities": [
        {
        "type": "hex_bonus",
        "owner_type": "corporation",
        "hexes": [
          "H8"
        ],
        "amount": 10
      }]
    },
    {
      "name": "Warsaw - Vienna Railway",
      "sym": "MVR",
      "value": 90,
      "revenue": 30,
      "discount": 30,
      "desc": "When owned by a corporation, they gain $10 extra revenue for each of their routes that include Poland",
      "abilities": [
        {
        "type": "hex_bonus",
        "owner_type": "corporation",
        "hexes": [
          "A9", "A11", "A13", "A15"
        ],
        "amount": 10
      }]
    }
  ],
  "corporations": [
    {
      "sym": "NW",
      "name": "North Western Railway",
      "logo": "1861/NW",
      "float_percent": 20,
      "always_market_price": true,
      "tokens": [
        0,
        20,
        40
      ],
      "type": "major",
      "color": "navy"
    },
    {
      "sym": "SW",
      "name": "Southwestern Railway",
      "logo": "1861/SW",
      "float_percent": 20,
      "always_market_price": true,
      "tokens": [
        0,
        20,
        40
      ],
      "type": "major",
      "color": "orange"
    },
    {
      "sym": "SE",
      "name": "Southeastern Railway",
      "logo": "1861/SE",
      "float_percent": 20,
      "always_market_price": true,
      "tokens": [
        0,
        20,
        40
      ],
      "type": "major",
      "color": "purple"
    },
    {
      "sym": "MVR",
      "name": "Moskow, Vindava & Rybinsk Railway",
      "logo": "1861/MVR",
      "float_percent": 20,
      "always_market_price": true,
      "tokens": [
        0,
        20,
        40
      ],
      "type": "major",
      "color": "olive"
    },
    {
      "sym": "MK",
      "name": "Moskow & Kazan Railway",
      "logo": "1861/MK",
      "float_percent": 20,
      "always_market_price": true,
      "tokens": [
        0,
        20,
        40
      ],
      "type": "major",
      "color": "green"
    },
    {
      "sym": "GR",
      "name": "Grand Russian Railway",
      "logo": "1861/GR",
      "float_percent": 20,
      "always_market_price": true,
      "tokens": [
        0,
        20,
        40
      ],
      "type": "major",
      "color": "red"
    },
    {
      "sym": "MKN",
      "name": "Moskow, Kursk & Nizhnii Novgorod",
      "logo": "1861/MKN",
      "float_percent": 20,
      "always_market_price": true,
      "tokens": [
        0,
        20,
        40
      ],
      "type": "major",
      "color": "blue"
    },
    {
      "sym": "MKR",
      "name": "Moskow, Kiev & Voronezh Railway",
      "logo": "1861/MKR",
      "float_percent": 20,
      "always_market_price": true,
      "tokens": [
        0,
        20,
        40
      ],
      "type": "major",
      "color": "brown"
    },
    {
      "sym": "RO",
      "name": "Riga-Orel Railway",
      "logo": "1861/RO",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "type": "minor",
      "shares": [100],
      "max_ownership_percent": 100,
      "color": "teal"
    },
    {
      "sym": "KB",
      "name": "Kiev-Brest Railway",
      "logo": "1861/KB",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "lightBlue"
    },
    {
      "sym": "OK",
      "name": "Odessa-Kiev Railway",
      "logo": "1861/OK",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "lightishBlue"
    },
    {
      "sym": "KK",
      "name": "Kiev-Kursk Railway",
      "logo": "1861/KK",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "lightishBlue"
    },
    {
      "sym": "SPW",
      "name": "St. Petersburg Warsaw",
      "logo": "1861/SPW",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "blue"
    },
    {
      "sym": "MB",
      "name": "Moskow-Brest Railway",
      "logo": "1861/KP",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "blue"
    },
    {
      "sym": "KR",
      "name": "Kharkiv-Rostov Railway",
      "logo": "1861/KR",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "purple"
    },
    {
      "sym": "N",
      "name": "Nikolaev Railway",
      "logo": "1861/N",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "magenta"
    },
    {
      "sym": "Y",
      "name": "Yuzovka Railway",
      "logo": "1861/Y",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "red"
    },
    {
      "sym": "MKu",
      "name": "Moskow-Kursk Railway",
      "logo": "1861/MKu",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "orange"
    },
    {
      "sym": "MNN",
      "name": "Moskow-Nizhnii Novgorod",
      "logo": "1861/MNN",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "red"
    },
    {
      "sym": "MV",
      "name": "Moskow-Voronezh Railway",
      "logo": "1861/MV",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "red"
    },
    {
      "sym": "V",
      "name": "Vladikavkaz Railway",
      "logo": "1861/V",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "gray"
    },
    {
      "sym": "TR",
      "name": "Tsaritsyn-Riga Railway",
      "logo": "1861/TR",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "gray"
    },
    {
      "sym": "SV",
      "name": "Samara-Vyazma Railway",
      "logo": "1861/SV",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "gray"
    },
    {
      "sym": "E",
      "name": "Ekaterinin Railway",
      "logo": "1861/E",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "color": "gray"
    },
    {
      "sym": "RSR",
      "name": "Russian State Railway",
      "logo": "1861/RSR",
      "tokens": [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ],
      "shares": [100],
      "hide_shares": true,
      "type": "national",
      "color": "red"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": [
        {
          "nodes": ["city", "offboard"],
          "pay": 2,
          "visit": 2
        },
        {
          "nodes": ["town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "price": 100,
      "rusts_on": "4",
      "num": 10
    },
    {
      "name": "3",
      "distance": [
        {
          "nodes": ["city", "offboard"],
          "pay": 3,
          "visit": 3
        },
        {
          "nodes": ["town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "price": 225,
      "rusts_on": "6",
      "num": 7,
      "events":[
        {"type": "green_minors_available"}
      ]
    },
    {
      "name": "4",
      "distance": [
        {
          "nodes": ["city", "offboard"],
          "pay": 4,
          "visit": 4
        },
        {
          "nodes": ["town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "price": 350,
      "rusts_on": "8",
      "num": 4,
      "events":[
        {"type": "majors_can_ipo"},
        {"type": "trainless_nationalization"}
      ]
    },
    {
      "name": "5",
      "distance": [
        {
          "nodes": ["city", "offboard"],
          "pay": 5,
          "visit": 5
        },
        {
          "nodes": ["town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "price": 550,
      "num": 4,
      "events":[
        {"type": "minors_cannot_start"}
      ]

    },
    {
      "name": "6",
      "distance": [
        {
          "nodes": ["city", "offboard"],
          "pay": 6,
          "visit": 6
        },
        {
          "nodes": ["town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "price": 650,
      "num": 2,
      "events":[
        {"type": "nationalize_companies"},
        {"type": "trainless_nationalization"}
      ]
    },
    {
      "name": "7",
      "distance": [
        {
          "nodes": ["city", "offboard"],
          "pay": 7,
          "visit": 7
        },
        {
          "nodes": ["town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "price": 800,
      "num": 2
    },
    {
      "name": "8",
      "distance": [
        {
          "nodes": ["city", "offboard"],
          "pay": 8,
          "visit": 8
        },
        {
          "nodes": ["town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "price": 1000,
      "num": 6,
      "events": [
        {"type": "signal_end_game"},
        {"type": "minors_nationalized"},
        {"type": "trainless_nationalization"},
        {"type": "train_trade_allowed"}
      ],
      "discount": {
        "5": 275,
        "6": 325,
        "7": 400,
        "8": 500,
        "2+2": 300,
        "5+5E": 750
      }
    },
    {
      "name": "2+2",
      "distance": [
        {
          "nodes": ["city", "offboard"],
          "pay": 2,
          "visit": 2
        },
        {
          "nodes": ["town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "multiplier":2,
      "price": 600,
      "num": 20,
      "available_on": "8",
      "discount": {
        "5": 275,
        "6": 325,
        "7": 400,
        "8": 500,
        "2+2": 300,
        "5+5E": 750
      }
    },
    {
      "name": "5+5E",
      "distance": [
        {
          "nodes": ["offboard"],
          "pay": 5,
          "visit": 5
        },
        {
          "nodes": ["city", "town"],
          "pay": 0,
          "visit": 99
        }
      ],
      "multiplier": 2,
      "price": 1500,
      "num": 20,
      "available_on": "8",
      "discount": {
        "5": 275,
        "6": 325,
        "7": 400,
        "8": 500,
        "2+2": 300,
        "5+5E": 750
      }
    }
  ],
  "hexes": {
    "white": {
      "": [
        "B6",
        "B8",
        "C5",
        "C7",
        "C19",
        "D4",
        "D6",
        "D14",
        "E3",
        "E5",
        "E7",
        "E9",
        "F2",
        "F4",
        "F6",
        "F10",
        "F12",
        "F14",
        "G3",
        "G5",
        "G7",
        "G9",
        "G11",
        "G13",
        "H4",
        "H6",
        "H8",
        "H12",
        "I5",
        "I7",
        "I9",
        "I11",
        "I13",
        "J6",
        "J8",
        "J10",
        "J14",
        "K5",
        "K7",
        "K9",
        "L6",
        "L8",
        "M5",
        "M7",
        "N6",
        "O11"
      ],
      "border=edge:5,type:impassable":[
        "D18"
      ],
      "border=edge:0,type:impassable;border=edge:5,type:impassable":[
        "C9"
      ],
      "border=edge:2,type:impassable;border=edge:1,type:impassable;border=edge:0,type:impassable;border=edge:5,type:impassable":[
        "D10"
      ],
      "border=edge:2,type:impassable;border=edge:1,type:impassable":[
        "E11"
      ],
      "border=edge:0,type:impassable;border=edge:3,type:impassable;border=edge:4,type:impassable":[
        "C11"
      ],
      "border=edge:3,type:impassable;border=edge:4,type:impassable":[
        "D12"
      ],
      "border=edge:3,type:impassable":[
        "C13"
      ],
      "upgrade=cost:20,terrain:water": [
        "K11"
      ],
      "border=edge:0,type:water,cost:80;border=edge:5,type:water,cost:80": [
        "N8"
      ],
      "border=edge:2,type:water,cost:80;border=edge:3,type:water,cost:80": [
        "N10",
        "M11"
      ],
      "border=edge:2,type:water,cost:80": [
        "O9"
      ],
      "city=revenue:0;border=edge:5,type:water,cost:80;border=edge:0,type:water,cost:80": [
        "M9"
      ],
      "city=revenue:0": [
        "D8",
        "F8",
        "E13",
        "E15",
        "C17",
        "I15",
        "N12"
      ],
      "city=revenue:0;stub=edge:1": [
        "G15"
      ],
      "city=revenue:0;label=Y": [
        "E17",
        "D16",
        "O7"
      ],
      "city=revenue:0;label=Y;label=O;upgrade=cost:20,terrain:water": [
        "J12"
      ],
      "town=revenue:0;border=edge:5,type:water,cost:80;stub=edge:0": [
        "L10"
      ],
      "town=revenue:0;border=edge:0,type:impassable": [
        "H14"
      ],
      "town=revenue:0": [
        "C15",
        "B18",
        "H10",
        "M13"
      ],
      "town=revenue:0;stub=edge:4": [
        "K13"
      ]
    },
    "gray": {
      "city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:1;border=edge:4": [
        "D2"
      ],
      "path=a:0,b:4;border=edge:4": [
        "C3"
      ],
      "path=a:1,b:5;border=edge:1": [
        "E1"
      ],
      "path=a:0,b:5": [
        "B16"
      ],
      "path=a:2,b:3": [
        "L14"
      ]
    },
    "yellow": {
      "city=revenue:40;city=revenue:40;city=revenue:40,loc:5;path=a:1,b:_0;path=a:3,b:_1;label=M;upgrade=cost:20,terrain:water": [
        "L12"
      ],
      "city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=T": [
        "F16"
      ]
    },
    "red": {
      "offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:4,b:_0;path=a:5,b:_0": [
        "A7"
      ],
      "offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0": [
        "F18"
      ],
      "offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:3,b:_0": [
        "M15"
      ],
      "offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:2,b:_0;path=a:3,b:_0": [
        "O13"
      ],
      "offboard=revenue:yellow_30|green_30|brown_40|gray_40;path=a:2,b:_0;path=a:1,b:_0": [
        "P8"
      ],
      "offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Detroit;path=a:5,b:_0;border=edge:0": [
        "A17"
      ],
      "offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Detroit;path=a:4,b:_0;border=edge:3": [
        "A19"
      ]
    },
    "blue": {
      "offboard=revenue:10;path=a:3,b:_0;border=edge:2,type:impassable": [
        "E19"
      ],
      "offboard=revenue:10;path=a:2,b:_0;path=a:4,b:_0;border=edge:3,type:impassable": [
        "H16"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "train_limit": {
        "minor": 2
      },
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3",
      "train_limit": {
        "minor": 2,
        "major": 4
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "status":[
        "can_buy_companies"
      ],
      "on": "3",
      "operating_rounds": 2
    },
    {
      "name": "4",
      "train_limit": {
        "minor": 1,
        "major": 3,
        "national": 99
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "status":[
        "can_buy_companies",
        "national_operates"
      ],
      "on": "4",
      "operating_rounds": 2
    },
    {
      "name": "5",
      "train_limit": {
        "minor": 1,
        "major": 3,
        "national": 99
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "status":[
        "can_buy_companies",
        "national_operates"
      ],
      "on": "5",
      "operating_rounds": 2
    },
    {
      "name": "6",
      "train_limit": {
        "minor": 1,
        "major": 2,
        "national": 99
      },
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "on": "6",
      "operating_rounds": 2,
      "status":["national_operates"]
    },
    {
      "name": "7",
      "train_limit": {
        "minor": 1,
        "major": 2,
        "national": 99
      },
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "on": "7",
      "operating_rounds": 2,
      "status":["national_operates"]
    },
    {
      "name": "8",
      "train_limit":  {
        "major": 2,
        "national": 99
      },
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "on": "8",
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
