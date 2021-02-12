# frozen_string_literal:true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1893
        JSON = <<-'DATA'
{
  "filename": "1893",
  "modulename": "1893",
  "currencyFormatStr": "%dM",
  "bankCash": 7200,
  "certLimit": {
      "2": 18,
      "3": 12,
      "4": 9
  },
  "startingCash": {
     "2": 900,
     "3": 600,
     "4": 450
  },
  "capitalization": "full",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "B5": "Düseldorf & Neuss",
    "D5": "Benrath",
    "D7": "Solingen",
    "B9": "Wuppertal",
    "E2": "Grevenbroich",
    "E4": "DOrmagen",
    "G6": "Leverkusen",
    "I2": "Bergheim",
    "I8": "Bergisch-Gladbach",
    "L3": "Frechen",
    "L5": "Köln",
    "L9": "Gummersbach",
    "N1": "Aachen",
    "O2": "Düren",
    "O4": "Brühl",
    "O6": "Porz",
    "P7": "Troizdorf",
    "P9": "Siegen",
    "R7": "Bonn-Beuel",
    "S6": "Bonn",
    "T3": "Euskirchen",
    "U6": "Andernach",
    "U8": "Neuwied"
  },
  "tiles": {
    "3": 2,
    "4": 4,
    "5": 2,
    "6": 4,
    "7": 3,
    "8": 10,
    "9": 7,
    "14": 4,
    "15": 5,
    "16": 1,
    "19": 1,
    "20": 2,
    "23": 3,
    "24": 3,
    "25": 1,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "39": 1,
    "40": 2,
    "41": 1,
    "42": 1,
    "43": 1,
    "44": 1,
    "45": 1,
    "46": 1,
    "47": 1,
    "57": 3,
    "58": 4,
    "70": 1,
    "141": 2,
    "142": 2,
    "143": 2,
    "144": 2,
    "145": 1,
    "146": 1,
    "147": 1,
    "611": 4,
    "619": 3,
    "K1": {
      "count": 1,
      "color": "yellow",
      "code": "town=revenue:10;town=revenue:10;path=a:1,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:4;label=L"
    },
    "K5": {
      "count": 2,
      "color": "yellow",
      "code": "city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;label=BX"
    },
    "K6": {
      "count": 2,
      "color": "yellow",
      "code": "city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;label=BX"
    },
    "K14": {
      "count": 2,
      "color": "green",
      "code": "city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=BX"
    },
    "K15": {
      "count": 2,
      "color": "green",
      "code": "city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=BX"
    },
    "K57": {
      "count": 2,
      "color": "yellow",
      "code": "city=revenue:20;path=a:0,b:_0;path=a:_0,b:3;label=BX"
    },
    "K55": {
      "count": 1,
      "color": "yellow",
      "code": "town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;path=a:1,b:_1;path=a:_1,b:4;label=L"
    },
    "K170": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L"
    },
    "K201": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;label=K"
    },
    "K255": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K"
    },
    "K269": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K"
    },
    "K314": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=L"
    },
    "KV63": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S"
    },
    "KV201": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;upgrade=cost:40,terrain:water;label=K"
    },
    "KV255": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;upgrade=cost:60,terrain:water;label=K"
    },
    "KV259": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0"
    },
    "KV269": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K"
    },
    "KV333": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K"
    },
    "KV619": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S"
    }
  },
  "market": [
    [
      "",
      "",
      "100",
      "110",
      "120",
      "135",
      "150",
      "165",
      "180",
      "195",
      "210",
      "230",
      "250",
      "270",
      "300",
      "330"
    ],
    [
      "",
      "80",
      "90",
      "100p",
      "110",
      "120x",
      "135",
      "150",
      "165",
      "180",
      "195",
      "210",
      "230",
      "250"
    ],
    [
      "70",
      "75",
      "80",
      "90p",
      "100",
      "110",
      "120z",
      "135",
      "150",
      "165",
      "180"
    ],
    [
      "65",
      "70",
      "75",
      "80p",
      "90",
      "100",
      "110",
      "120"
    ],
    [
      "60",
      "65",
      "70p",
      "75",
      "80",
      "90"
    ],
    [
      "55",
      "60p",
      "65",
      "70",
      "75"
    ],
    [
      "50",
      "55",
      "60",
      "65"
    ]
  ],
  "companies": [
    {
      "sym":"FdSD",
      "name":"Fond de Stadt Düsseldorf",
      "value":190,
      "revenue":20,
      "desc":"May be exchanged against 20% shares of the Rheinbahn AG. This private cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"EVA",
      "name":"Eisenbehnverkehrsmittel Aktiengesellschaft",
      "value":150,
      "revenue":30,
      "desc":"Leaves the game after the purchase of the first 6-train. This private cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"HdSK",
      "name":"Häfen der Stadt Köln",
      "value":100,
      "revenue":10,
      "desc":"Exchange against 10% certificate of HGK. This private cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"EKB",
      "name":"Euskirchener Kreisbahn",
      "value":210,
      "revenue":0,
      "desc":"Buyer take control of minor with same name (EKB), and the price paid makes the minor's treasury. EKB minor and private are exchanged into the 20% president's certificate of AGV when AGV is formed. The private and minor cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"KFBE",
      "name":"Köln-Frechen-Benzelrather Eisenbahn",
      "value":200,
      "revenue":0,
      "desc":"Buyer take control of minor with same name (KFBE), and the price paid makes the minor's treasury. KFBE minor and private are exchanged into the 20% president's certificate of AGV when AGV is formed. The private and minor cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"KSZ",
      "name":"Klienahn Siegburg-Zündorf",
      "value":100,
      "revenue":0,
      "desc":"Buyer take control of minor with same name (KSZ), and the price paid makes the minor's treasury. KSZ minor and private are exchanged into a 10% certificate of AGV when AGV is formed. The private and minor cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"KBE",
      "name":"Köln-Bonner Eisenbahn",
      "value":220,
      "revenue":0,
      "desc":"Buyer take control of minor with same name (KBE), and the price paid makes the minor's treasury. KBE minor and private are exchanged into the 20% president's certificate of HGK when HGK is formed. The private and minor cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"BKB",
      "name":"Bergheimer Kreisbahn",
      "value":190,
      "revenue":0,
      "desc":"Buyer take control of minor with same name (BKB), and the price paid makes the minor's treasury. BKB minor and private are exchanged into a 20% certificate of AGV when AGV is formed. The private and minor cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    }
  ],
  "minors":[
    {
      "sym": "EKB",
      "name": "1 Euskirchener Kreisbahn",
      "type": "minor",
      "tokens": [
        0
      ],
      "logo": "1893/EKB",
      "coordinates": "T3",
      "city": 0,
      "color": "green"
    },
    {
      "sym": "KFBE",
      "name": "2 Köln-Frechen-Benzelrather E",
      "type": "minor",
      "tokens": [
        0
      ],
      "logo": "1893/KFBE",
      "coordinates": "L3",
      "city": 0,
      "color": "red"
    },
    {
      "sym": "KSZ",
      "name": "3 Kleinbagn Siegburg-Zündprf",
      "type": "minor",
      "tokens": [
        0
      ],
      "logo": "1893/KSZ",
      "coordinates": "P7",
      "city": 0,
      "color": "green"
    },
    {
      "sym": "KBE",
      "name": "4 Köln-Bonner Eisenbahn",
      "type": "minor",
      "tokens": [
        0
      ],
      "logo": "1893/KBE",
      "coordinates": "O4",
      "city": 0,
      "color": "red"
    },
    {
       "sym": "BKB",
       "name": "5 Bergerheimer Kreisbahn",
       "type": "minor",
       "tokens": [
         0
       ],
       "logo": "1893/BKB",
       "coordinates": "I2",
       "city": 0,
       "color": "green"
    }
  ],
  "corporations": [
    {
      "float_percent": 50,
      "float_excludes_market": true,
      "always_market_price": true,
      "name": "Dürener Eisenbahn",
      "sym": "DE",
      "tokens": [
        0,
        40,
        100
      ],
      "logo": "1893/DE",
      "color": "blue",
      "coordinates": "O2",
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unbuyable until all but one privates sold"
        }
      ]
    },
    {
      "name": "Rhein-Sieg Eisenbahn",
      "sym": "RSE",
      "float_percent": 50,
      "float_excludes_market": true,
      "always_market_price": true,
      "tokens": [
        0,
        40,
        100
      ],
      "logo": "1893/RSE",
      "color": "pink",
      "text_color": "black",
      "coordinates": "R7",
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unbuyable until all but one privates sold"
        }
      ]
    },
    {
      "name": "Rheinbahn AG",
      "sym": "RAG",
      "float_percent": 50,
      "float_excludes_market": true,
      "always_market_price": true,
      "tokens": [
        0,
        40,
        100
      ],
      "color": "gray70",
      "logo": "1893/RAG",
      "text_color": "black",
      "coordinates": "D5",
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unbuyable until all but one privates sold"
        }
      ]
    },
    {
      "name": "Anleihen der Stadt Köln",
      "sym": "AdSK",
      "float_percent": 101,
      "always_market_price": true,
      "max_ownership_percent": 100,
      "floatable": false,
      "tokens": [
      ],
      "shares":[0, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
      "logo": "1893/AdSK",
      "color": "gray",
      "text_color": "white",
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unbuyable until all but one privates sold"
        }
      ]
    },
    {
      "name": "AG für Verkehrswesen",
      "sym": "AGV",
      "float_percent": 50,
      "float_excludes_market": true,
      "always_market_price": true,
      "floatable": false,
      "tokens": [
        100,
        100
      ],
      "shares":[20, 10, 20, 10, 10, 10, 10, 10],
      "logo": "1893/AGV",
      "color": "green",
      "text_color": "black",
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unavailable in SR before phase 4"
        }
      ]
    },
    {
      "name": "Häfen und Güterverkehr Köln AG",
      "sym": "HGK",
      "float_percent": 50,
      "float_excludes_market": true,
      "always_market_price": true,
      "floatable": false,
      "tokens": [
        100,
        100
      ],
      "shares":[20, 10, 20, 10, 10, 10, 10, 10],
      "logo": "1893/HGK",
      "color": "red",
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unavailable in SR before phase 5"
        }
      ]
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "num": 8,
      "price": 80,
      "rusts_on": "4"
    },
    {
      "name": "3",
      "distance": 3,
      "num": 4,
      "price": 180,
      "rusts_on": "6",
      "discount": {
        "2": 40
      },
      "events": [
        {"type": "remove_tile_block"}
      ]
    },
    {
      "name": "4",
      "distance": 4,
      "num": 4,
      "price": 300,
      "rusts_on": "8+x",
      "discount": {
        "2": 40,
        "3": 90
      },
      "events": [
        {"type": "agv_buyable"}
      ]
    },
    {
      "name": "5",
      "distance": 5,
      "num": 3,
      "price": 450,
      "discount": {
        "3": 90,
        "4": 150
      },
      "events": [
        {"type": "agv_founded"},
        {"type": "hgk_buyable"},
        {"type": "bonds_exchanged"}
      ]
    },
    {
      "name": "6",
      "distance": 6,
      "num": 3,
      "price": 630,
      "discount": {
        "3": 90,
        "4": 150,
        "5": 225
      },
      "events": [
        {"type": "hgk_founded"},
        {"type": "eva_closed"}
      ]
    },
    {
      "name": "8+x",
      "distance":[
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay":8,
           "visit":8
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
      ],
      "num": 3,
      "price": 800,
      "available_on": "6",
      "discount": {
        "4": 150,
        "5": 225,
        "6": 315
      }
    }
  ],
  "hexes": {
  },
  "phases": [
    {
      "name": "2",
      "on": "2",
      "train_limit": {
        "minor":2,
        "corporation":3
      },
      "tiles": [
        "yellow"
      ],
      "status": [
        "rhine_impassible"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3",
      "on": "3",
      "train_limit": {
        "minor":2,
        "corporation":3
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_trains"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": {
        "minor":2,
        "corporation":3
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_trains",
        "may_found_agv"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5",
      "on": "5",
      "train_limit": {
        "minor":1,
        "corporation":2
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "status": [
        "can_buy_trains",
        "may_found_hgk"
      ],
      "operating_rounds": 2
    },
    {
      "name": "6",
      "on": "6",
      "train_limit": {
        "minor":1,
        "corporation":2
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "status": [
        "can_buy_trains"
      ],
      "operating_rounds": 2
    },
    {
      "name": "8+x",
      "on": "8+x",
      "train_limit": {
        "minor":1,
        "corporation":2
      },
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "status": [
        "can_buy_trains"
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
