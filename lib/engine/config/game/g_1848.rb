# coding: utf-8
# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1848
        JSON = <<-'DATA'
{
  "filename": "1848",
  "modulename": "1848",
  "currencyFormatStr": "£%d",
  "bankCash": 10000,
  "certLimit": {
    "3": 20,
    "4": 17,
    "5": 14,
    "6": 12
  },
  "startingCash": {
    "3": 840,
    "4": 630,
    "5": 510,
    "6": 430
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A4": "Alice Springs",
    "A6": "Alice Springs",
    "A18": "Cairns",
    "D1": "Perth",
    "F3": "Port Lincoln",
    "B17": "Toowoomba & Ipswich",
    "B19": "Brisbane",
    "F17": "Sydney",
    "G14": "Canberra",
    "H11": "Melbourne",
    "E4": "Port Augusta",
    "G6": "Adelaide",
    "C20": "Southport",
    "E18": "Newcastle",
    "E14": "Dubbo",
    "F13": "Wagga Wagga",
    "D9": "Broken Hill",
    "H9": "Geelong",
    "H7": "Mount Gambier",
    "F5": "Port Pirie",
    "E2": "Whyalla",
    "F15": "Orange & Bathurst",
    "G10": "Ballarat & Bendigo",
    "G16": "Wollongong"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "5": 3,
    "6": 4,
    "7": 4,
    "8": 9,
    "9": 12,
    "14": 3,
    "15": 6,
    "16": 1,
    "18": 1,
    "19": 1,
    "20": 1,
    "23": 2,
    "24": 2,
    "25": 2,
    "26": 1,
    "27": 1,
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
    "57": 3,
    "59": 2,
    "64": 1,
    "65": 1,
    "66": 1,
    "67": 1,
    "68": 1,
    "69": 1,
    "70": 1,
    "235": 3,
    "236": 2,
    "237": 1,
    "238": 1,
    "239": 3,
    "240": 2,
    "611": 4,
    "915": 1
  },
  "market": [
    [
      "[object Object]y",
      "70o",
      "80",
      "90",
      "100",
      "110",
      "120",
      "140",
      "160",
      "190",
      "220",
      "250",
      "280",
      "320",
      "360",
      "400",
      "450"
    ],
    [
      "",
      "60o",
      "70",
      "80",
      "90",
      "100p",
      "110",
      "130",
      "150",
      "180",
      "210",
      "240",
      "270",
      "310",
      "350",
      "390",
      "440o"
    ],
    [
      "",
      "50o",
      "60",
      "70",
      "80",
      "90p",
      "100",
      "120",
      "140",
      "170",
      "200",
      "230",
      "260",
      "300o"
    ],
    [
      "",
      "40o",
      "50",
      "60",
      "70",
      "80p",
      "90",
      "110",
      "130",
      "160",
      "190o"
    ],
    [
      "",
      "30o",
      "40",
      "50",
      "60",
      "70p",
      "80",
      "100",
      "120o"
    ],
    [
      "",
      "20o",
      "30",
      "40",
      "50",
      "60",
      "70o"
    ]
  ],
  "companies": [
    {
      "sym": "PX",
      "name": "Melbourne & Hobson's Bay Railway Company",
      "value": 40,
      "revenue": 5,
      "desc": "No special abilities."
    },
    {
      "sym": "P2",
      "name": "Sydney Railway Company",
      "value": 80,
      "revenue": 10,
      "desc": "If the company is owned by a Public Company or its Director, that company can, on one occasion, develop a cost-incurring desert hex for 40£ less than it would otherwise cost"
    },
    {
      "sym": "P3",
      "name": "Tasmanian Railways",
      "value": 140,
      "revenue": 15,
      "desc": "The Tasmania tile can be placed by a Public Company on one of the dark blue hexes. This is in addition to the company's normal build that turn."
    },
    {
      "sym": "P4",
      "name": "The Ghan",
      "value": 220,
      "revenue": 20,
      "desc": "The owner has a one-time discount of £100 on the purchase of a 2E train, 'The Ghan'"
    },
    {
      "sym": "P5",
      "name": "Trans-Australian Railway",
      "value": 0,
      "revenue": 25,
      "desc": "The owner receives in addition a 10% share in the QR."
    },
    {
      "sym": "P6",
      "name": "North Australian Railway",
      "value": 0,
      "revenue": 30,
      "desc": "The owner receives in addition the Director's Share share in the CAR, which must start at a par value of 100£."
    }
  ],
  "corporations": [
    {
      "sym": "BOE",
      "name": "Bank of England",
      "logo": "1848/BOE",
      "tokens": [],
      "color": "white"
    },
    {
      "sym": "CAR",
      "name": "Central Australian Railway",
      "logo": "1848/CAR",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "E4",
      "color": "black"
    },
    {
      "sym": "VR",
      "name": "Victorian Railways",
      "logo": "1848/VR",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "H11",
      "color": "yellow"
    },
    {
      "sym": "NSW",
      "name": "New South Wales Railways",
      "logo": "1848/NSW",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "F17",
      "color": "orange"
    },
    {
      "sym": "SAR",
      "name": "South Australian Railway",
      "logo": "1848/SAR",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "G6",
      "color": "purple"
    },
    {
      "sym": "CR",
      "name": "Commonwealth Railways",
      "logo": "1848/CR",
      "tokens": [
        0,
        0,
        100,
        100,
        100
      ],
      "color": "gray"
    },
    {
      "sym": "FT",
      "name": "Federal Territory Railway",
      "logo": "1848/FT",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "G14",
      "color": "blue"
    },
    {
      "sym": "WA",
      "name": "West Australian Railway",
      "logo": "1848/WA",
      "tokens": [
        0,
        40,
        100,
        100,
        100
      ],
      "coordinates": "D1",
      "color": "red"
    },
    {
      "sym": "QR",
      "name": "Queensland Gov't Railway",
      "logo": "1848/QR",
      "tokens": [
        0,
        40,
        100,
        100,
        100
      ],
      "coordinates": "B19",
      "color": "green"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 6
    },
    {
      "name": "2+",
      "distance": 2,
      "price": 120,
      "rusts_on": "4",
      "num": 6
    },
    {
      "name": "3",
      "distance": 3,
      "price": 200,
      "rusts_on": "6",
      "num": 5
    },
    {
      "name": "3+",
      "distance": 3,
      "price": 230,
      "rusts_on": "6",
      "num": 5
    },
    {
      "name": "4",
      "distance": 4,
      "price": 300,
      "rusts_on": "8",
      "num": 4
    },
    {
      "name": "4+",
      "distance": 4,
      "price": 340,
      "rusts_on": "8",
      "num": 4
    },
    {
      "name": "5",
      "distance": 5,
      "price": 500,
      "num": 3
    },
    {
      "name": "5+",
      "distance": 5,
      "price": 550,
      "num": 3
    },
    {
      "name": "6",
      "distance": 6,
      "price": 600,
      "num": 2
    },
    {
      "name": "6+",
      "distance": 6,
      "price": 660,
      "num": 2
    },
    {
      "name": "D",
      "distance": 999,
      "price": 1100,
      "num": 6,
      "discount": {
        "4": 300,
        "5": 300,
        "6": 300
      }
    },
    {
      "name": "8",
      "distance": 8,
      "price": 800,
      "num": 6
    },
    {
      "name": "2E",
      "distance": 2,
      "price": 200,
      "num": 6
    }
  ],
  "hexes": {
    "red": {
      "offboard=revenue:yellow_10|green_20|brown_40|gray_60;path=a:5,b:_0;path=a:0,b:_0;border=edge:4": [
        "A4"
      ],
      "offboard=revenue:yellow_10|green_20|brown_40|gray_60;path=a:5,b:_0;path=a:0,b:_0;border=edge:1": [
        "A6"
      ],
      "offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:5,b:_0;path=a:0,b:_0": [
        "A18"
      ],
      "city=revenue:yellow_20|green_40|brown_60|gray_80;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0;label=K": [
        "D1"
      ]
    },
    "blue": {
      "offboard=revenue:yellow_10|green_10|brown_20|gray_20;path=a:0,b:_0": [
        "B21"
      ],
      "offboard=revenue:yellow_10|green_10|brown_20|gray_20;path=a:2,b:_0": [
        "F3"
      ],
      "": [
        "I8",
        "I10"
      ]
    },
    "white": {
      "upgrade=cost:40,terrain:cactus": [
        "B3",
        "B7",
        "B9",
        "C2",
        "C4",
        "C8",
        "E6",
        "E8"
      ],
      "upgrade=cost:50,terrain:mountain": [
        "D17",
        "E16",
        "H15",
        "H13"
      ],
      "": [
        "B11",
        "B13",
        "B15",
        "B5",
        "C10",
        "C12",
        "C14",
        "C16",
        "C6",
        "D11",
        "D13",
        "D15",
        "D19",
        "D5",
        "D7",
        "E10",
        "E12",
        "F11",
        "F7",
        "F9",
        "G8"
      ],
      "city=revenue:0;city=revenue:0": [
        "B17",
        "G10"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:50,terrain:mountain": [
        "C18"
      ],
      "city=revenue:0;label=K": [
        "B19",
        "F17",
        "H11",
        "G6"
      ],
      "city=revenue:0": [
        "G14",
        "E4",
        "C20",
        "E18",
        "E14",
        "F13",
        "D9",
        "H9",
        "H7",
        "F5",
        "E2"
      ],
      "city=revenue:0;city=revenue:0;upgrade=cost:50,terrain:mountain": [
        "F15"
      ],
      "town=revenue:0;town=revenue:0": [
        "G12",
        "D3"
      ],
      "city=revenue:0;upgrade=cost:50,terrain:mountain": [
        "G16"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ]
    },
    {
      "name": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ]
    },
    {
      "name": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ]
    },
    {
      "name": "5",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "6",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "8",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ]
    },
    {
      "name": "2E",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
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
