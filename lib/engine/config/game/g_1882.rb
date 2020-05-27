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
  "locationNames": {
    "A9": "Western Canada",
    "B2": "Northern Alberta",
    "B12": "Lethbridge",
    "C3": "Lloydminster",
    "C7": "Kindersley",
    "C11": "Medicine Hat",
    "D4": "Maidstone",
    "E5": "North Battleford & Battleford",
    "E9": "Swift Current",
    "F4": "Spiritwood",
    "F14": "Shaunavon",
    "G7": "Saskatoon",
    "H4": "Prince Albert",
    "H10": "Moose Jaw",
    "H12": "Assiniboia",
    "I3": "Candle Lake",
    "I7": "Humboldt",
    "J10": "Pile o' Bones & Lumsden",
    "K1": "Sandy Bay",
    "K3": "Flin Flon",
    "K7": "Wadena",
    "K13": "Wayburn & Estevan",
    "K15": "USA",
    "L2": "Europe",
    "L10": "Moosomin",
    "L14": "Oxbow",
    "M9": "Eastern Canada",
    "M11": "Virden"
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
    "R861": {
      "count": 1,
      "color": "green",
      "code": "c=r:0;c=r:0;p=a:1,b:j;p=a:4,b:j;l=RE"
    },
    "R862": {
      "count": 1,
      "color": "brown",
      "code": "c=r:70,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;l=RE"
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
      "desc": "Blocks Flin Flon (K3)."
    },
    {
      "name": "Saskatchewan Central",
      "value": 50,
      "revenue": 10,
      "desc": "During a player's stock turn, in any phase, the player owning this private company can close it to \"convert\" to the 10-share public company SCR. This counts as a \"certificate purchase action\". SCR shares cannot be purchased by any player unless SC has been converted. The SCR floats using the same rules as other companies. If the private company is sold to a company, it no longer can be converted."
    },
    {
      "name": "North West Rebellion",
      "value": 80,
      "revenue": 15,
      "desc": "A public company owning this company may move one of its existing on-map station markers located in a non-NWR indicated city to any available NWR-indicated hex city (including OO). There is no cost to this move. There is no track connection requirement. This can occur in addition to, or after, a regular token purchase/placement for an operating round. If the company home token is moved, replace it with a neutral marker from the supply. A single tile lay or upgrade may be performed on the destination hex if a station was placed, this is in addition to a regular track lay or upgrade performed by the company."
    },
    {
      "name": "Trestle Bridge",
      "value": 140,
      "revenue": 0,
      "desc": "During setup, a 10% share certificate selected randomly (not SC) is placed with this private company. When purchased during the private auction, the player receives the private company and the certificate."
    },
    {
      "name": "Canadian Pacific",
      "value": 180,
      "revenue": 25,
      "desc": "When purchased during the private auction comes with the 20% president's certificate of the Canadian Pacific (CPR) public company. The buying player must immediately set the par price for the CPR to any par price. The Canadian Pacific private company cannot be purchased by a public company."
    }
  ],
  "corporations": [
    {
      "sym": "CN",
      "name": "Canadian National",
      "logo": "1882/CN",
      "tokens": [],
      "color": "gray"
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
      "color": "green"
    },
    {
      "sym": "HB",
      "name": "Hudson Bay Railway",
      "logo": "1882/HB",
      "tokens": [
        0,
        40,
        40
      ],
      "coordinates": "K7",
      "color": "yellow"
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
      "coordinates": "E9",
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
      "coordinates": "H12",
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
      "color": "brown"
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
      "o=r:yellow_40|brown_80;p=a:4,b:_0;p=a:5,b:_0": [
        "A9"
      ],
      "o=r:yellow_30|brown_60;p=a:0,b:_0;p=a:5,b:_0": [
        "B2"
      ],
      "o=r:yellow_30|brown_30;p=a:3,b:_0": [
        "K15"
      ],
      "o=r:yellow_40|brown_50;p=a:0,b:_0;p=a:1,b:_0": [
        "L2"
      ],
      "o=r:yellow_30|brown_40;p=a:1,b:_0;p=a:2,b:_0": [
        "M9"
      ]
    },
    "white": {
      "blank": [
        "B4",
        "B6",
        "B8",
        "B10",
        "C5",
        "C9",
        "D2",
        "D8",
        "D10",
        "D12",
        "E3",
        "E7",
        "E11",
        "E13",
        "F6",
        "F8",
        "F10",
        "F12",
        "G5",
        "G9",
        "G11",
        "G13",
        "H8",
        "I5",
        "I9",
        "I13",
        "J2",
        "J4",
        "J6",
        "J8",
        "J12",
        "K5",
        "K11",
        "L4",
        "L8"
      ],
      "city": [
        "C3",
        "C7",
        "C11",
        "D4",
        "E9",
        "F4",
        "G7",
        "H10",
        "H12",
        "I7",
        "K3",
        "K7",
        "L10"
      ],
      "t=r:0;u=c:40,t:mountain": [
        "C13"
      ],
      "town": [
        "D6",
        "L12"
      ],
      "t=r:0;t=r:0": [
        "H6",
        "I11",
        "K9"
      ]
    },
    "gray": {
      "c=r:40;p=a:4,b:_0;p=a:_0,b:5": [
        "B12"
      ],
      "c=r:30;p=a:2,b:_0;p=a:_0,b:4": [
        "F14"
      ],
      "p=a:0,b:1": [
        "G3"
      ],
      "c=r:30;p=a:0,b:_0;p=a:1,b:_0": [
        "H4"
      ],
      "p=a:3,b:4": [
        "H14"
      ],
      "t=r:10;p=a:0,b:_0;p=a:_0,b:4": [
        "I3"
      ],
      "p=a:2,b:4": [
        "J14"
      ],
      "t=r:10;p=a:0,b:_0;p=a:_0,b:1": [
        "K1"
      ],
      "t=r:10;p=a:2,b:_0;p=a:_0,b:3": [
        "L14"
      ],
      "c=r:20;p=a:2,b:_0": [
        "M11"
      ]
    },
    "yellow": {
      "c=r:0;c=r:0;l=OO": [
        "E5",
        "K13"
      ],
      "c=r:40;c=r:40;p=a:1,b:_0;p=a:4,b:_1;l=RE": [
        "J10"
      ],
      "p=a:1,b:3": [
        "L6"
      ]
    },
    "blue": {
      "o=r:yellow_20|brown_30;p=a:0,b:_0;p=a:1,b:_0": [
        "F2"
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
      "train_limit": 3,
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
      "name": "D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
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
