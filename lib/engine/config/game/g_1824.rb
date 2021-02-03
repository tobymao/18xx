# frozen_string_literal:true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1824
        JSON = <<-'DATA'
{
  "filename": "1824",
  "modulename": "1824",
  "currencyFormatStr": "%dG",
  "bankCash": 12000,
  "certLimit": {
      "2": 14,
      "3": 21,
      "4": 16,
      "5": 13,
      "6": 11
  },
  "startingCash": {
     "2": 680,
     "3": 820,
     "4": 680,
     "5": 560,
     "6": 460
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A4": "Dresden",
    "A18": "Krakau",
    "A24": "Kiew",
    "B5": "Pilsen",
    "B9": "Prag",
    "B15": "Mährisch-Ostrau",
    "B23": "Lemberg",
    "C12": "Brünn",
    "C26": "Tarnopol",
    "D19": "Kaschau",
    "E8": "Linz",
    "E12": "Wien",
    "E14": "Preßburg",
    "E26": "Czernowitz",
    "F7": "Salzbug",
    "F17": "Buda Pest",
    "F23": "Klausenburg",
    "G4": "Innsbruck",
    "G10": "Graz",
    "G18": "Szegedin",
    "G26": "Kronstadt",
    "H1": "Mailand",
    "H3": "Bozen",
    "H15": "Fünfkirchen",
    "H23": "Hermannstadt",
    "H27": "Bukarest",
    "I8": "Triest",
    "J13": "Sarajevo"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 4,
    "4": 6,
    "5": 5,
    "6": 5,
    "7": 5,
    "8": 10,
    "9": 10,
    "14": 4,
    "15": 8,
    "16": 1,
    "17": 1,
    "18": 1,
    "19": 1,
    "20": 1,
    "23": 3,
    "24": 3,
    "25": 2,
    "26": 2,
    "27": 2,
    "28": 1,
    "29": 1,
    "30": 1,
    "31": 1,
    "39": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "43": 1,
    "44": 1,
    "45": 1,
    "46": 1,
    "47": 1,
    "55": 1,
    "56": 1,
    "57": 5,
    "58": 8,
    "69": 1,
    "70": 1,
    "87": 3,
    "88": 3,
    "126": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Bu"
    },
    "401": {
      "count": 3,
      "color": "yellow",
      "code": "city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;label=T"
    },
    "405": {
      "count": 3,
      "color": "green",
      "code": "city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T"
    },
    "447": {
      "count": 2,
      "color": "yellow",
      "code": "city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=T"
    },
    "490": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Bu"
    },
    "491": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_2;path=a:4,b:_1;label=W"
    },
    "493": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:70;city=revenue:70,slots:3;path=a:0,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1;path=a:1,b:_1;label=W"
    },
    "494": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T"
    },
    "495": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Bu"
    },
    "496": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=W"
    },
    "497": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T"
    },
    "498": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:30;city=revenue:30;path=a:2,b:_1;path=a:3,b:_1;path=a:0,b:_0;path=a:5,b:_0;label=Bu"
    },
    "499": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:4,b:_1;label=W"
    },
    "611": 6,
    "619": 4,
    "630": 1,
    "631": 1
  },
  "market": [
    [
      "100",
      "110",
      "120",
      "130",
      "140",
      "155",
      "170",
      "190",
      "210",
      "235",
      "260",
      "290",
      "320",
      "350"
    ],
    [
      "90",
      "100",
      "110",
      "120",
      "130",
      "145",
      "160",
      "180",
      "200",
      "225",
      "250",
      "280",
      "310",
      "340"
    ],
    [
      "80",
      "90",
      "100p",
      "110",
      "120",
      "135",
      "150",
      "170",
      "190",
      "215",
      "240",
      "270",
      "300",
      "330"
    ],
    [
      "70",
      "80",
      "90p",
      "100",
      "110",
      "125",
      "140",
      "160",
      "180",
      "200",
      "220"
    ],
    [
      "60",
      "70",
      "80p",
      "90",
      "100",
      "115",
      "130",
      "150",
      "170"
    ],
    [
      "50",
      "60",
      "70p",
      "80",
      "90",
      "105",
      "120"
    ],
    [
      "40",
      "50",
      "60p",
      "70",
      "80"
    ]
  ],
  "companies": [
    {
      "sym":"EPP",
      "name":"C1 Eisenbahn Pilsen - Priesen",
      "value":200,
      "interval": [120, 140, 160, 180, 200],
      "revenue":0,
      "desc":"Buyer take control of minor Coal Railway EPP (C1), which can be exchanged for the Director's certificate of Regional Railway BK during SRs in phase 3 or 4, or automatically when phase 5 starts. BK floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"EOD",
      "name":"C2 Eisenbahn Oderberg - Dombran",
      "value":200,
      "interval": [120, 140, 160, 180, 200],
      "revenue":0,
      "desc":"Buyer take control of minor Coal Railway EOD (C2), which can be exchanged for the Director's certificate of Regional Railway MS during SRs in phase 3 or 4, or automatically when phase 5 starts. MS floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"MLB",
      "name":"C3 Mosty - Lemberg Bahn",
      "value":200,
      "interval": [120, 140, 160, 180, 200],
      "revenue":0,
      "desc":"Buyer take control of minor Coal Railway MLB (C3), which can be exchanged for the Director's certificate of Regional Railway CL during SRs in phase 3 or 4, or automatically when phase 5 starts. CL floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"SPB",
      "name":"C4 Simeria-Petrosani Bahn",
      "value":200,
      "interval": [120, 140, 160, 180, 200],
      "revenue":0,
      "desc":"Buyer take control of minor Coal Railway SPB (C4), which can be exchanged for the Director's certificate of Regional Railway SB during SRs in phase 3 or 4, or automatically when phase 5 starts. SB floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"S1",
      "name":"S1 Wien-Gloggnitzer Eisenbahngesellschaft",
      "value":240,
      "revenue":0,
      "desc":"Buyer take control of pre-staatsbahn S1, which will be exchanged for the Director's certificate of SD when the first 4 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"S2",
      "name":"S2 Kärntner Bahn",
      "value":120,
      "revenue":0,
      "desc":"Buyer take control of pre-staatsbahn S2, which will be exchanged for a 10% share of SD when the first 4 train is sold. Pre-Staatsbahnen starts in Graz (G10). Cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"S3",
      "name":"S3 Nordtiroler Staatsbahn",
      "value":120,
      "revenue":0,
      "desc":"Buyer take control of pre-staatsbahn S3, which will be exchanged for a 10% share of SD when the first 4 train is sold. Pre-Staatsbahnen starts in Innsbruck (G4). Cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"U1",
      "name":"U1 Eisenbahn Pest - Waitzen",
      "value":240,
      "revenue":0,
      "desc":"Buyer take control of pre-staatsbahn U1, which will be exchanged for the Director's certificate of UG when the first 5 train is sold. Pre-Staatsbahnen starts in Pest (F17) in base 1824 and in Budapest (G12) for 3 players on the Cislethania map. Cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"U2",
      "name":"U2 Mohacs-Fünfkirchner Bahn",
      "value":120,
      "revenue":0,
      "desc":"Buyer take control of pre-staatsbahn U2, which will be exchanged for a 10% share of UG when the first 5 train is sold. Pre-Staatsbahnen starts in Fünfkirchen (H15). Cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"K1",
      "name":"K1 Kaiserin Elisabeth-Bahn",
      "value":240,
      "revenue":0,
      "desc":"Buyer take control of pre-staatsbahn K1, which will be exchanged for the Director's certificate of KK when the first 6 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.",
      "abilities": [
        {
          "type": "no_buy",
          "owner_type": "player"
        }
      ]
    },
    {
      "sym":"K2",
      "name":"K2 Kaiser Franz Joseph-Bahn",
      "value":120,
      "revenue":0,
      "desc":"Buyer take control of pre-staatsbahn K2, which will be exchanged for a 10% share of KK when the first 6 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.",
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
      "sym": "EPP",
      "name": "C1 Eisenbahn Pilsen - Priesen",
      "type": "Coal",
      "tokens": [
        0
      ],
      "logo": "1824/C1",
      "coordinates": "C6",
      "city": 0,
      "color": "gray50"
    },
    {
      "sym": "EOD",
      "name": "C2 Eisenbahn Oderberg - Dombran",
      "type": "Coal",
      "tokens": [
        0
      ],
      "logo": "1824/C2",
      "coordinates": "A12",
      "city": 0,
      "color": "gray50"
    },
    {
      "float_percent": 100,
      "sym": "MLB",
      "name": "C3 Mosty - Lemberg Bahn",
      "type": "Coal",
      "tokens": [
        0
      ],
      "logo": "1824/C3",
      "coordinates": "A22",
      "city": 0,
      "color": "gray50"
    },
    {
      "sym": "SPB",
      "name": "C4 Simeria-Petrosani Bahn",
      "type": "Coal",
      "tokens": [
        0
      ],
      "logo": "1824/C4",
      "coordinates": "H25",
      "city": 0,
      "color": "gray50"
    },
    {
       "sym": "S1",
       "name": "S1 Wien-Gloggnitzer Eisenbahngesellschaft",
       "type": "PreStaatsbahn",
       "tokens": [
         0
       ],
       "logo": "1824/S1",
       "coordinates": "E12",
       "city": 0,
       "color": "orange"
    },
    {
      "sym": "S2",
      "name": "S2 Kärntner Bahn",
      "type": "PreStaatsbahn",
      "tokens": [
        0
      ],
      "logo": "1824/S2",
      "coordinates": "G10",
      "city": 0,
      "color": "orange"
    },
    {
      "sym": "S3",
      "name": "S3 Nordtiroler Staatsbahn",
      "type": "PreStaatsbahn",
      "tokens": [
        0
      ],
      "logo": "1824/S3",
      "coordinates": "G4",
      "city": 0,
      "color": "orange"
    },
    {
      "sym": "U1",
      "name": "U1 Eisenbahn Pest - Waitzen",
      "type": "PreStaatsbahn",
      "tokens": [
        0
      ],
      "logo": "1824/U1",
      "coordinates": "F17",
      "city": 1,
      "color": "purple"
    },
    {
      "sym": "U2",
      "name": "U2 Mohacs-Fünfkirchner Bahn",
      "type": "PreStaatsbahn",
      "tokens": [
        0
      ],
      "logo": "1824/U2",
      "coordinates": "H15",
      "city": 0,
      "color": "purple"
    },
    {
      "sym": "K1",
      "name": "K1 Kaiserin Elisabeth-Bahn",
      "type": "PreStaatsbahn",
      "tokens": [
          0
      ],
      "coordinates": "E12",
      "city": 1,
      "color": "brown",
      "logo": "1824/K1"
    },
    {
      "sym": "K2",
      "name": "K2 Kaiser Franz Joseph-Bahn",
      "type": "PreStaatsbahn",
      "tokens": [
        0
      ],
      "logo": "1824/K2",
      "coordinates": "E12",
      "city": 2,
      "color": "brown"
    }
  ],
  "corporations": [
    {
      "float_percent": 50,
      "name": "Böhmische Kommerzbahn",
      "sym": "BK",
      "type": "Regional",
      "tokens": [
        0,
        40,
        60,
        80
      ],
      "logo": "1824/BK",
      "simple_logo": "1824/BK.alt",
      "color": "blue",
      "coordinates": "B9"
    },
    {
      "name": "Mährisch-Schlesische Eisenbahn",
      "sym": "MS",
      "type": "Regional",
      "float_percent": 50,
      "tokens": [
        0,
        40,
        60,
        80
      ],
      "logo": "1824/MS",
      "simple_logo": "1824/MS.alt",
      "color": "yellow",
      "text_color": "black",
      "coordinates": "C12"
    },
    {
      "name": "Carl Ludwigs-Bahn",
      "sym": "CL",
      "type": "Regional",
      "float_percent": 50,
      "tokens": [
        0,
        40,
        60,
        80
      ],
      "color": "gray70",
      "logo": "1824/CL",
      "simple_logo": "1824/CL.alt",
      "coordinates": "B23"
    },
    {
      "name": "Siebenbürgische Bahn",
      "sym": "SB",
      "type": "Regional",
      "float_percent": 50,
      "tokens": [
        0,
        40,
        60,
        80
      ],
      "logo": "1824/SB",
      "simple_logo": "1824/SB.alt",
      "color": "green",
      "text_color": "black",
      "coordinates": "G26"
    },
    {
      "name": "Bosnisch-Herzegowinische Landesbahn",
      "sym": "BH",
      "type": "Regional",
      "float_percent": 50,
      "tokens": [
        0,
        40,
        100
      ],
      "logo": "1824/BH",
      "simple_logo": "1824/BH.alt",
      "color": "red",
      "coordinates": "J13"
    },
    {
      "name": "Südbahn",
      "sym": "SD",
      "type": "Staatsbahn",
      "float_percent": 10,
      "tokens": [
        100,
        100
      ],
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unavailable in SR before phase 4"
        }
      ],
      "logo": "1824/SD",
      "simple_logo": "1824/SD.alt",
      "color": "orange",
      "text_color": "black"
    },
    {
      "name": "Ungarische Staatsbahn",
      "sym": "UG",
      "type": "Staatsbahn",
      "float_percent": 10,
      "tokens": [
        100,
        100,
        100
      ],
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unavailable in SR before phase 5"
        }
      ],
      "logo": "1824/UG",
      "simple_logo": "1824/UG.alt",
      "color": "purple"
    },
    {
      "name": "k&k Staatsbahn",
      "sym": "KK",
      "type": "Staatsbahn",
      "float_percent": 10,
      "tokens": [
        40,
        100,
        100,
        100
      ],
      "abilities": [
        {
            "type": "no_buy",
            "description": "Unavailable in SR before phase 6"
        }
      ],
      "logo": "1824/KK",
      "simple_logo": "1824/KK.alt",
      "color": "brown"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "num": 9,
      "price": 80,
      "rusts_on": "4"
    },
    {
      "name": "1g",
      "distance":[
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay":2,
           "visit":2
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
      ],
      "num": 6,
      "price": 120,
      "available_on": "2",
      "rusts_on": "3g"
    },
    {
      "name": "3",
      "distance": 3,
      "num": 7,
      "price": 180,
      "rusts_on": "6",
      "discount": {
        "2": 40
      }
    },
    {
      "name": "2g",
      "distance":[
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay":3,
           "visit":3
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
      ],
      "num": 5,
      "price": 240,
      "available_on": "3",
      "rusts_on": "4g",
      "discount": {
        "1g": 60
      }
    },
    {
      "name": "4",
      "distance": 4,
      "num": 4,
      "price": 300,
      "rusts_on": "8",
      "events": [
        {"type": "close_mountain_railways"},
        {"type": "sd_formation"}
      ],
      "discount": {
        "3": 90
      }
    },
    {
      "name": "3g",
      "distance":[
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
      "num": 4,
      "price": 360,
      "available_on": "4",
      "rusts_on": "5g",
      "discount": {
        "2g": 120
      }
    },
    {
      "name": "5",
      "distance": 5,
      "num": 3,
      "price": 450,
      "rusts_on": "10",
      "events": [
        {"type": "close_coal_railways"},
        {"type": "ug_formation"}
      ],
      "discount": {
        "4": 140
      }
    },
    {
      "name": "6",
      "distance": 6,
      "num": 3,
      "price": 630,
      "events": [
        {"type": "kk_formation"}
      ],
      "discount": {
        "5": 200
      }
    },
    {
      "name": "4g",
      "distance":[
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay":5,
           "visit":5
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
      "price": 600,
      "available_on": "6",
      "discount": {
        "3g": 180
      }
    },
    {
      "name": "8",
      "distance": 8,
      "num": 3,
      "price": 800,
      "discount": {
        "6": 300
      }
    },
    {
      "name": "5g",
      "distance":[
        {
           "nodes":[
              "city",
              "offboard"
           ],
           "pay":6,
           "visit":6
        },
        {
           "nodes":[
              "town"
           ],
           "pay":99,
           "visit":99
        }
      ],
      "num": 2,
      "price": 800,
      "available_on": "8",
      "discount": {
        "4g": 300
      }
    },
    {
      "name": "10",
      "distance": 10,
      "num": 20,
      "price": 950,
      "discount": {
        "8": 400
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
        "PreStaatsbahn":2,
        "Coal":2,
        "Regional":4
      },
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "3",
      "on": "3",
      "train_limit": {
        "PreStaatsbahn":2,
        "Coal":2,
        "Regional":4
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_trains",
        "may_exchange_coal_railways",
        "may_exchange_mountain_railways"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": {
        "PreStaatsbahn":2,
        "Coal":2,
        "Regional":3
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_trains",
        "may_exchange_coal_railways"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5",
      "on": "5",
      "train_limit": {
        "PreStaatsbahn":2,
        "Regional":3,
        "Staatsbahn":4
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "status": [
        "can_buy_trains"
      ],
      "operating_rounds": 3
    },
    {
      "name": "6",
      "on": "6",
      "train_limit": {
        "Regional":2,
        "Staatsbahn":3
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "status": [
        "can_buy_trains"
      ],
      "operating_rounds": 3
    },
    {
      "name": "8",
      "on": "8",
      "train_limit": {
        "Regional":2,
        "Staatsbahn":3
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
      "operating_rounds": 3
    },
    {
      "name": "10",
      "on": "10",
      "train_limit": {
        "Regional":2,
        "Staatsbahn":3
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
      "operating_rounds": 3
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
