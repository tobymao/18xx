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
  "currencyFormatStr": "%d₽",
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
    "A9": "Poland",
    "B4": "Riga",
    "B8": "Vilna",
    "B18": "Romania",
    "C5": "Dünaberg",
    "C9": "Minsk",
    "D14": "Kiev",
    "D20": "Odessa",
    "E1": "St. Petersburg",
    "E9": "Smolensk",
    "E11": "Gomel",
    "E13": "Chernigov",
    "F18": "Ekaterinoslav",
    "G5": "Tver",
    "G13": "Kursk",
    "G15": "Kharkov",
    "G19": "Alexandrovsk",
    "H8": "Moscow",
    "H10": "Tula",
    "H18": "Yuzovka",
    "I5": "Yaroslav",
    "I13": "Voronezh",
    "I17": "Lugansk",
    "I19": "Rostov",
    "J20": "Caucasus",
    "K7": "Nizhnii Novgorod",
    "K11": "Penza",
    "K17": "Tsaritsyn",
    "L12": "Saratov",
    "M7": "Kazan",
    "M9": "Simbirsk",
    "M19": "Astrakhan",
    "N10": "Samara",
    "P0": "Perm",
    "P8": "Ufa",
    "Q3": "Ekaterinburg (₽80 if includes M)",
    "Q11": "Central Asia"
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
      "code": "city=revenue:40,loc:0.5;city=revenue:40,loc:2.5;city=revenue:40,loc:4.5;path=a:0,b:_0;path=a:_0,b:1;path=a:4,b:_2;path=a:_2,b:5;path=a:2,b:_1;path=a:_1,b:3;label=K;upgrade=cost:40,terrain:water"
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
          "E3", "H6", "I5", "I9", "J10"
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
      "desc": "When owned by a corporation, they gain 10₽ extra revenue for each of their routes that include Odessa",
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
      "name": "Moscow - Yaroslavl Railway",
      "sym": "MYR",
      "value": 60,
      "revenue": 20,
      "discount": 20,
      "desc": "When owned by a corporation, they gain 10₽ extra revenue for each of their routes that include Moscow",
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
      "name": "Moscow - Ryazan Railway",
      "sym": "MRR",
      "value": 75,
      "revenue": 25,
      "discount": 25,
      "desc": "When owned by a corporation, they gain 10₽ extra revenue for each of their routes that include Moscow",
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
      "desc": "When owned by a corporation, they gain 10₽ extra revenue for each of their routes that include Poland",
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
      "name": "Moscow, Vindava & Rybinsk Railway",
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
      "name": "Moscow & Kazan Railway",
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
      "name": "Moscow, Kursk & Nizhnii Novgorod",
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
      "name": "Moscow, Kiev & Voronezh Railway",
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
      "coordinates": "B4",
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
      "coordinates": "D14",
      "city": 1,
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
      "coordinates": "D20",
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
      "coordinates": "D14",
      "city": 2,
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
      "coordinates": "E1",
      "city": 0,
      "color": "blue"
    },
    {
      "sym": "MB",
      "name": "Moscow-Brest Railway",
      "logo": "1861/MB",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "coordinates": "E9",
      "color": "navy",
      "reservation_color": "lightGreen"
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
      "coordinates": "G15",
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
      "coordinates": "H8",
      "city": 1,
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
      "coordinates": "H18",
      "color": "coral",
      "reservation_color": "lightGreen"
    },
    {
      "sym": "M-K",
      "name": "Moscow-Kursk Railway",
      "logo": "1861/M-K",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "coordinates": "H8",
      "city": 0,
      "color": "orange"
    },
    {
      "sym": "MNN",
      "name": "Moscow-Nizhnii Novgorod",
      "logo": "1861/MNN",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "coordinates": "H8",
      "city": 2,
      "color": "red"
    },
    {
      "sym": "MV",
      "name": "Moscow-Voronezh Railway",
      "logo": "1861/MV",
      "float_percent": 100,
      "always_market_price": true,
      "tokens": [
        0
      ],
      "shares": [100],
      "max_ownership_percent": 100,
      "type": "minor",
      "coordinates": "I13",
      "color": "rose"
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
      "coordinates": "I19",
      "color": "gray",
      "reservation_color": "lightGreen"
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
      "coordinates": "K17",
      "color": "gray",
      "reservation_color": "lightGreen"
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
      "coordinates": "N10",
      "color": "gray",
      "reservation_color": "lightGreen"
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
      "coordinates": "Q3",
      "color": "navy",
      "reservation_color": "lightGreen"
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
      "coordinates": "E1",
      "city": 1,
      "color": "cream",
      "text_color": "black"
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
      "num": 20,
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
        "B6","B10", "B12", "B14", "B16",
        "C3", "C13", "C15",
        "D6", "D8", "D16", "D18",
        "E3", "E5", "E7", "E17",
        "F6", "F8", "F10", "F12", "F14", "F20",
        "G3", "G9", "G11", "G17",
        "H2", "H4", "H6", "H12", "H14", "H16", "H20",
        "I3", "I7", "I9", "I11",
        "J2", "J4", "J8", "J10", "J12", "J14",
        "K3", "K5", "K9", "K13", "K15", "K19",
        "L2", "L4", "L8", "L10", "L14", "L18", "L20",
        "M3", "M5",
        "N2", "N4", "N8", "N12","N20",
        "O1", "O3", "O7", "O9", "O11",
        "P6", "P10", "P12"
      ],
      "town=revenue:0": [
        "B8", "C9", "E11", "E13", "G19", "G13", "H10", "I17", "K11"
      ],
      "town=revenue:0;upgrade=cost:20,terrain:water": [
        "I5"
      ],
      "town=revenue:0;upgrade=cost:80,terrain:water": [
        "M9"
      ],
      "city=revenue:0": [
        "E9", "H18", "I13", "I19", "K17", "L12", "P8"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:water": [
        "P2"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:water": [
        "F18", "M7"
      ],
      "city=revenue:0;label=Y": [
        "B4", "D20", "M19", "N10"
      ],
      "city=revenue:0;label=Y;label=Kh": [
        "G15"
      ],
      "upgrade=cost:80,terrain:water": [
        "C11", "D12", "M11"
      ],
      "upgrade=cost:40,terrain:water": [
        "E15", "E19", "F16", "I15", "J16", "J18"
      ],
      "upgrade=cost:20,terrain:water": [
        "C17", "C19", "D10", "J6", "L6", "N6", "O5", "P4"
      ]
    },
    "gray": {
      "path=a:4,b:5": [
        "A5"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:5,b:_0;path=a:0,b:4": [
        "C5"
      ],
      "path=a:4,b:3": [
        "C21"
      ],
      "path=a:3,b:2": [
        "M21"
      ],
      "path=a:0,b:1": [
        "P0"
      ],
      "path=a:1,b:2": [
        "Q7"
      ],
      "path=a:3,b:2;path=a:3,b:1": [
        "Q5"
      ],
      "city=revenue:40;path=a:2,b:_0;path=a:1,b:_0;path=a:0,b:_0": [
        "Q3"
      ]
    },
    "yellow": {
      "path=a:3,b:1": [
        "C7", "D4"
      ],
      "path=a:3,b:5": [
        "F4", "G7"
      ],
      "path=a:0,b:4": [
        "D2"
      ],
      "path=a:0,b:2": [
        "F2"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:0,b:_0": [
        "G5"
      ],
      "city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=M": [
        "H8"
      ],
      "city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=K": [
        "D14"
      ],
      "city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;label=Y;upgrade=cost:20,terrain:water": [
        "K7"
      ]
    },
    "green": {
      "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_1,b:5;label=S":[
        "E1"
     ]
    },
    "red": {
      "offboard=revenue:yellow_30|green_40|brown_50|gray_70,groups:Poland;path=a:5,b:_0;path=a:4,b:_0;border=edge:0": [
        "A9"
      ],
      "offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Poland;path=a:5,b:_0;path=a:4,b:_0;border=edge:3;border=edge:0": [
        "A11", "A13"
      ],
      "offboard=revenue:yellow_30|green_40|brown_50|gray_70,hide:1,groups:Poland;path=a:5,b:_0;path=a:4,b:_0;border=edge:3": [
        "A15"
      ],
      "offboard=revenue:yellow_10|green_20|brown_30|gray_30,groups:Romania;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:0": [
        "B18"
      ],
      "offboard=revenue:yellow_10|green_20|brown_30|gray_30,hide:1,groups:Romania;path=a:4,b:_0;border=edge:3": [
        "B20"
      ],
      "offboard=revenue:yellow_10|green_20|brown_40|gray_60,groups:Caucasus;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1;border=edge:5": [
        "J20"
      ],
      "offboard=revenue:yellow_10|green_20|brown_40|gray_60,hide:1,groups:Caucasus;path=a:3,b:_0;border=edge:4": [
        "I21"
      ],
      "offboard=revenue:yellow_10|green_20|brown_40|gray_60,hide:1,groups:Caucasus;path=a:3,b:_0;path=a:4,b:_0;border=edge:2": [
        "K21"
      ],
      "offboard=revenue:yellow_10|green_20|brown_30|gray_40,groups:CentralAsia;path=a:1,b:_0;path=a:2,b:_0;border=edge:0": [
        "Q11"
      ],
      "offboard=revenue:yellow_10|green_20|brown_30|gray_40,hide:1,groups:CentralAsia;path=a:2,b:_0;border=edge:3": [
        "Q13"
      ]
    },
    "blue": {
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
