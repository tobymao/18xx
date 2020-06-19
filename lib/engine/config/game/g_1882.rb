# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1882
        JSON = <<-'DATA'
{
  "filename": "1882",
  "modulename": "1882",
  "currencyFormatStr": "$%d",
  "bankCash": 9000,
  "certLimit": {
    "2": 20,
    "3": 14,
    "4": 11,
    "5": 10,
    "6": 9
  },
  "startingCash": {
    "2": 900,
    "3": 600,
    "4": 450,
    "5": 360,
    "6": 300
  },
  "capitalization": "full",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "I1": "Western Canada (HB +100)",
    "B2": "Northern Alberta (HB +100)",
    "L2": "Lethbridge",
    "C3": "Lloydminster",
    "G3": "Kindersley",
    "K3": "Medicine Hat",
    "M3": "Elkwater",
    "D4": "Maidstone",
    "F4": "Wilkie",
    "E5": "North Battleford & Battleford",
    "I5": "Swift Current",
    "D6": "Spiritwood",
    "N6": "Shaunavon",
    "G7": "Saskatoon",
    "D8": "Prince Albert",
    "F8": "Rosthern & Melfort",
    "J8": "Moose Jaw",
    "L8": "Assiniboia",
    "C9": "Candle Lake",
    "G9": "Humboldt",
    "K9": "Rouleau & Mossbank",
    "J10": "Pile o' Bones & Lumsden",
    "A11": "Sandy Bay",
    "C11": "Flin Flon",
    "G11": "Wadena",
    "I11": "Melville & Fort Qu'Appelle",
    "M11": "Wayburn & Estevan",
    "O11": "USA",
    "B12": "Hudson Bay",
    "J12": "Moosomin",
    "L12": "Carlyle",
    "N12": "Oxbow",
    "I13": "Eastern Canada",
    "K13": "Virden"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 1,
    "4": 1,
    "7": 5,
    "8": 10,
    "9": 10,
    "14": 3,
    "15": 2,
    "18": 1,
    "19": 1,
    "20": 1,
    "23": 3,
    "24": 3,
    "26": 1,
    "27": 1,
    "41": 2,
    "42": 2,
    "43": 2,
    "44": 1,
    "45": 2,
    "46": 2,
    "47": 1,
    "55": 1,
    "56": 1,
    "57": 4,
    "58": 1,
    "59": 1,
    "63": 3,
    "66": 1,
    "67": 1,
    "68": 1,
    "69": 1,
    "R1": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=R"
    },
    "R2": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=R"
    }
  },
  "market": [
    [
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
      "350"
    ],
    [
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
      "50y",
      "58y",
      "65",
      "67p",
      "71",
      "75",
      "80"
    ],
    [
      "45o",
      "54y",
      "63",
      "67",
      "69",
      "70"
    ],
    [
      "40o",
      "50y",
      "60y",
      "67",
      "68"
    ],
    [
      "30b",
      "40o",
      "50y",
      "60y"
    ],
    [
      "20b",
      "30b",
      "40o",
      "50y"
    ],
    [
      "10b",
      "20b",
      "30b",
      "40o"
    ]
  ],
  "companies": [
    {
      "name": "Hudson Bay",
      "value": 20,
      "revenue": 5,
      "desc": "Blocks Flin Flon (C11).",
      "sym": "HB",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "C11"
          ]
        }
      ]
    },
    {
      "name": "Saskatchewan Central",
      "value": 50,
      "revenue": 10,
      "desc": "During a player's stock turn, in any phase, the player owning this company can close it to \"convert\" to the 10-share corporation SC. This counts as a \"certificate purchase action\". SC shares cannot be purchased by any player unless SC has been converted. The SC floats using the same rules as other corporation. If the private company is sold to a corporation, it no longer can be converted.",
      "sym": "SC",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "H4"
          ]
        }
      ]
    },
    {
      "name": "North West Rebellion",
      "value": 80,
      "revenue": 15,
      "desc": "A corporation owning this company may move one of its existing on-map station markers located in a non-NWR indicated city to any available NWR-indicated hex city (including OO). There is no cost to this move. There is no track connection requirement. This can occur in addition to, or after, a regular token purchase/placement for an operating round. If the corporation home token is moved, replace it with a neutral marker from the supply. A single tile lay or upgrade may be performed on the destination hex if a station was placed; this is in addition to a regular track lay or upgrade performed by the corporation.",
      "sym": "NWR"
    },
    {
      "name": "Trestle Bridge",
      "value": 140,
      "revenue": 0,
      "desc": "Earns $10 every time a corporation adds track over a river. During setup, a 10% share certificate selected randomly from the corporations (excluding SC) is placed with this company. When purchased during the private auction, the player receives both the company and the certificate.",
      "sym": "TB",
      "abilities": [
        {
          "type": "share",
          "share": "random_share",
          "corporations": [
            "CNR",
            "CPR",
            "GT",
            "HBR",
            "QLL"
          ]
        },
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "G9"
          ]
        }
      ]
    },
    {
      "name": "Canadian Pacific",
      "value": 180,
      "revenue": 25,
      "desc": "When purchased during the private auction, this company comes with the 20% president's certificate of the Canadian Pacific (CPR) corporation. The buying player must immediately set the par price for the CPR to any par price. The Canadian Pacific company cannot be purchased by a corporation.",
      "sym": "CP",
      "abilities": [
        {
          "type": "share",
          "share": "CPR_0"
        }
      ]
    }
  ],
  "corporations": [
    {
      "sym": "CN",
      "name": "Canadian National",
      "logo": "1882/CN",
      "tokens": [

      ],
      "color": "orange",
      "text_color": "black"
    },
    {
      "sym": "CNR",
      "name": "Canadian Northern",
      "logo": "1882/CNR",
      "tokens": [
        0,
        40,
        40
      ],
      "coordinates": "D8",
      "color": "green"
    },
    {
      "sym": "HBR",
      "name": "Hudson Bay Railway",
      "logo": "1882/HBR",
      "tokens": [
        0,
        40,
        40
      ],
      "coordinates": "G11",
      "color": "gold",
      "text_color": "black"
    },
    {
      "sym": "CPR",
      "name": "Canadian Pacific Railway",
      "logo": "1882/CPR",
      "tokens": [
        0,
        40,
        40,
        40
      ],
      "coordinates": "I5",
      "color": "red"
    },
    {
      "sym": "GT",
      "name": "Grand Trunk Pacific",
      "logo": "1882/GT",
      "tokens": [
        0,
        40,
        40
      ],
      "coordinates": "L8",
      "color": "black"
    },
    {
      "sym": "SC",
      "name": "Saskatchewan Central Railroad",
      "logo": "1882/SC",
      "tokens": [
        0
      ],
      "color": "blue"
    },
    {
      "sym": "QLL",
      "name": "Qu'Appelle, Long Lake Railroad Co.",
      "logo": "1882/QLL",
      "tokens": [
        0,
        40
      ],
      "coordinates": "J10",
      "color": "purple"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": "4",
      "num": 6
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
      "num": 4
    },
    {
      "name": "5",
      "distance": 5,
      "price": 450,
      "num": 3
    },
    {
      "name": "6",
      "distance": 6,
      "price": 630,
      "num": 2
    },
    {
      "name": "D",
      "distance": 999,
      "price": 1100,
      "num": 9,
      "discount": {
        "4": 300,
        "5": 300,
        "6": 300
      }
    }
  ],
  "hexes": {
    "red": {
      "offboard=revenue:yellow_40|brown_80;path=a:4,b:_0;path=a:5,b:_0": [
        "I1"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:5,b:_0": [
        "B2"
      ],
      "offboard=revenue:yellow_30|brown_30;path=a:3,b:_0": [
        "O11"
      ],
      "offboard=revenue:yellow_40|brown_50;path=a:0,b:_0;path=a:1,b:_0": [
        "B12"
      ],
      "offboard=revenue:yellow_30|brown_40;path=a:1,b:_0;path=a:2,b:_0": [
        "I13"
      ]
    },
    "white": {
      "": [
        "D2",
        "F2",
        "H2",
        "J2",
        "E3",
        "I3",
        "B4",
        "H4",
        "J4",
        "L4",
        "C5",
        "G5",
        "K5",
        "M5",
        "F6",
        "H6",
        "J6",
        "L6",
        "E7",
        "I7",
        "K7",
        "M7",
        "H8",
        "E9",
        "I9",
        "M9",
        "B10",
        "D10",
        "F10",
        "H10",
        "L10",
        "E11",
        "K11",
        "D12",
        "H12"
      ],
      "city=revenue:0": [
        "C3",
        "G3",
        "K3",
        "D4",
        "I5",
        "D6",
        "G7",
        "J8",
        "L8",
        "G9",
        "C11",
        "G11",
        "J12"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:mountain": [
        "M3"
      ],
      "town=revenue:0": [
        "F4",
        "L12"
      ],
      "town=revenue:0;town=revenue:0": [
        "F8",
        "K9",
        "I11"
      ]
    },
    "gray": {
      "city=revenue:40;path=a:4,b:_0;path=a:_0,b:5": [
        "L2"
      ],
      "city=revenue:30;path=a:2,b:_0;path=a:_0,b:4": [
        "N6"
      ],
      "path=a:0,b:1": [
        "C7"
      ],
      "city=revenue:30;path=a:0,b:_0;path=a:1,b:_0": [
        "D8"
      ],
      "path=a:3,b:4": [
        "N8"
      ],
      "town=revenue:10;path=a:0,b:_0;path=a:_0,b:4": [
        "C9"
      ],
      "path=a:2,b:4": [
        "N10"
      ],
      "town=revenue:10;path=a:0,b:_0;path=a:_0,b:1": [
        "A11"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:_0,b:3": [
        "N12"
      ],
      "city=revenue:20;path=a:2,b:_0": [
        "K13"
      ]
    },
    "yellow": {
      "city=revenue:0;city=revenue:0;label=OO": [
        "E5",
        "M11"
      ],
      "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_1;label=R": [
        "J10"
      ],
      "path=a:1,b:3": [
        "F12"
      ]
    },
    "blue": {
      "offboard=revenue:yellow_20|brown_30;path=a:0,b:_0;path=a:1,b:_0": [
        "B6"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "6",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
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
