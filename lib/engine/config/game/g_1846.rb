# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1846
        JSON = <<-'DATA'
{
  "filename": "1846",
  "modulename": "1846",
  "currencyFormatStr": "$%d",
  "bankCash": {
    "2": 7000,
    "3": 6500,
    "4": 7500,
    "5": 9000
  },
  "certLimit": {
    "2": 19,
    "3": 14,
    "4": 12,
    "5": 11
  },
  "startingCash": {
    "2": 600,
    "3": 400,
    "4": 400,
    "5": 400
  },
  "capitalization": "incremental",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "B8": "Holland",
    "B16": "Port Huron",
    "B18": "Sarnia",
    "C5": "Chicago Connections",
    "C9": "South Bend",
    "C15": "Detroit",
    "C17": "Windsor",
    "D14": "Toledo",
    "D20": "Erie",
    "D22": "Buffalo",
    "E11": "Fort Wayne",
    "E17": "Cleveland",
    "E21": "Salamanca",
    "E23": "Binghamton",
    "F20": "Homewood",
    "G3": "Springfield",
    "G7": "Terre Haute",
    "G9": "Indianapolis",
    "G13": "Dayton",
    "G15": "Columbus",
    "G19": "Wheeling",
    "G21": "Pittsburgh",
    "H12": "Cincinnati",
    "H20": "Cumberland",
    "I1": "St. Louis",
    "I5": "Centralia",
    "I15": "Huntington",
    "I17": "Charleston",
    "J10": "Louisville",
    "K3": "Cairo"
  },
  "tiles": {
    "5": 3,
    "6": 4,
    "7": 5,
    "8": 16,
    "9": 16,
    "14": 4,
    "15": 5,
    "16": 2,
    "17": 1,
    "18": 1,
    "19": 2,
    "20": 2,
    "21": 1,
    "22": 1,
    "23": 4,
    "24": 4,
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
    "51": 2,
    "57": 4,
    "70": 1,
    "290": 1,
    "291": 1,
    "292": 1,
    "293": 1,
    "294": 2,
    "295": 2,
    "296": 1,
    "297": 2,
    "298": 1,
    "299": 1,
    "300": 1,
    "611": 4,
    "619": 3
  },
  "market": [
    [
      "Closed",
      "10",
      "20",
      "30",
      "40p",
      "50p",
      "60p",
      "70p",
      "80p",
      "90p",
      "100p",
      "112p",
      "124p",
      "137p",
      "150p",
      "165",
      "180",
      "195",
      "212",
      "230",
      "250",
      "270",
      "295",
      "320",
      "345",
      "375",
      "405",
      "440",
      "475",
      "510",
      "550"
    ]
  ],
  "companies": [
    {
      "name": "Michigan Southern",
      "value": 60,
      "debt": 80,
      "revenue": 0,
      "desc": "Starts with $60 in treasury, a 2 train, and a token in Detroit (C15). Splits revenue evenly with owner."
    },
    {
      "name": "Big 4",
      "value": 40,
      "debt": 60,
      "revenue": 0,
      "desc": "Starts with $60 in treasury, a 2 train, and a token in Indianapolis (G9). Splits revenue evenly with owner."
    },
    {
      "name": "Chicago and Western Indiana",
      "value": 60,
      "revenue": 10,
      "desc": "Reserves a token slot in Chicago (D6), in which the owning corporation may place an extra token at no cost."
    },
    {
      "name": "Mail Contract",
      "value": 80,
      "revenue": 0,
      "desc": "Adds $10 per location visited by any one train of the owning corporation. Never closes once purchased by a corporation."
    },
    {
      "name": "Tunnel Blasting Company",
      "value": 60,
      "revenue": 20,
      "desc": "Reduces, for the owning corporation, the cost of laying all mountain tiles and tunnel/pass hexsides by $20."
    },
    {
      "name": "Meat Packing Company",
      "value": 60,
      "revenue": 15,
      "desc": "The owning corporation may place a $30 marker in either St. Louis (I1) or Chicago (D6), to add $30 to all routes run to this location."
    },
    {
      "name": "Steamboat Company",
      "value": 40,
      "revenue": 10,
      "desc": "Place or shift the port marker among port locations (B8, C5, D14, G19, I1). Add $20 per port symbol to all routes run to this location by the owning (or assigned) company."
    },
    {
      "name": "Lake Shore Line",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may make an extra $0 cost tile upgrade of either Cleveland (E17) or Toledo (D14), but not both."
    },
    {
      "name": "Michigan Central",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may lay up to two extra $0 cost yellow tiles in the MC's reserved hexes (B10, B12)."
    },
    {
      "name": "Ohio & Indiana",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may lay up to two extra $0 cost yellow tiles in the O&I's reserved hexes (F14, F16)."
    }
  ],
  "corporations": [
    {
      "float_percent": 20,
      "sym": "PRR",
      "name": "Pennsylvania",
      "logo": "1846/PRR",
      "tokens": [
        0,
        80,
        80,
        80,
        0
      ],
      "coordinates": "F20",
      "color": "red"
    },
    {
      "float_percent": 20,
      "sym": "NYC",
      "name": "New York Central",
      "logo": "1846/NYC",
      "tokens": [
        0,
        80,
        80,
        80
      ],
      "coordinates": "D20",
      "color": "black"
    },
    {
      "float_percent": 20,
      "sym": "B&O",
      "name": "Baltimore & Ohio",
      "logo": "1846/BO",
      "tokens": [
        0,
        80,
        80,
        0
      ],
      "coordinates": "G19",
      "color": "blue"
    },
    {
      "float_percent": 20,
      "sym": "C&O",
      "name": "Chesapeake & Ohio",
      "logo": "1846/CO",
      "tokens": [
        0,
        80,
        80,
        80
      ],
      "coordinates": "I15",
      "color": "lightBlue",
      "text_color": "black"
    },
    {
      "float_percent": 20,
      "sym": "ERIE",
      "name": "Erie",
      "logo": "1846/ERIE",
      "tokens": [
        0,
        80,
        80,
        0
      ],
      "coordinates": "E21",
      "color": "yellow",
      "text_color": "black"
    },
    {
      "float_percent": 20,
      "sym": "GT",
      "name": "Grand Trunk",
      "logo": "1846/GT",
      "tokens": [
        0,
        80,
        80
      ],
      "coordinates": "B16",
      "color": "orange"
    },
    {
      "float_percent": 20,
      "sym": "IC",
      "name": "Illinois Central",
      "logo": "1846/IC",
      "tokens": [
        0,
        80,
        80,
        0
      ],
      "coordinates": "K3",
      "color": "green"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 0,
      "rusts_on": [
        "6",
        "7/8"
      ],
      "num": 1
    },
    {
      "name": "2",
      "distance": 2,
      "price": 0,
      "rusts_on": [
        "6",
        "7/8"
      ],
      "num": 1
    },
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": [
        "6",
        "7/8"
      ],
      "num": 7
    },
    {
      "name": "3/5",
      "distance": 3,
      "price": 160,
      "num": 6
    },
    {
      "name": "4",
      "distance": 4,
      "price": 180,
      "num": 6
    },
    {
      "name": "4/6",
      "distance": 4,
      "price": 450,
      "num": 5
    },
    {
      "name": "5",
      "distance": 5,
      "price": 500,
      "num": 5
    },
    {
      "name": "6",
      "distance": 6,
      "price": 800,
      "num": 9
    },
    {
      "name": "7/8",
      "distance": 7,
      "price": 900,
      "num": 9
    }
  ],
  "hexes": {
    "white": {
      "blank": [
        "E5",
        "F6",
        "G5",
        "H6",
        "J4",
        "B14",
        "C11",
        "C13",
        "D8",
        "D10",
        "D12",
        "E7",
        "E9",
        "E13",
        "E15",
        "E19",
        "F4",
        "F8",
        "F10",
        "F12",
        "G11",
        "H2",
        "H4",
        "H8",
        "H10",
        "I3",
        "I7",
        "I9",
        "J8",
        "D18",
        "B10",
        "B12",
        "F14",
        "F16",
        "I11",
        "J6"
      ],
      "city": [
        "B16",
        "C9",
        "D14",
        "E11",
        "G3",
        "G7",
        "G9",
        "G13",
        "G15"
      ],
      "c=r:0;l=Z": [
        "E17",
        "H12"
      ],
      "u=c:40,t:mountain": [
        "F18",
        "G17",
        "H16"
      ],
      "u=c:60,t:mountain": [
        "H14"
      ]
    },
    "gray": {
      "p=a:0,b:5": [
        "A15",
        "C7"
      ],
      "c=r:10;p=a:1,b:_0;p=a:2,b:_0;p=a:4,b:_0;p=a:5,b:_0": [
        "F20"
      ],
      "c=r:10,s:2;p=a:1,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:0,b:_0": [
        "I5"
      ],
      "c=r:20;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0": [
        "I15"
      ],
      "c=r:20;p=a:3,b:_0": [
        "K3"
      ]
    },
    "red": {
      "o=r:yellow_40|brown_10;p=a:4,b:_0": [
        "B8"
      ],
      "o=r:yellow_30|brown_50;p=a:1,b:_0;l=E": [
        "B18"
      ],
      "o=r:yellow_20|brown_40;p=a:5,b:_0;l=W": [
        "C5"
      ],
      "o=r:yellow_40|brown_60;p=a:1,b:_0;l=E": [
        "C17"
      ],
      "o=r:yellow_30|brown_60,h:1;p=a:0,b:_0;l=E;b=e:5": [
        "C21"
      ],
      "o=r:yellow_30|brown_60;p=a:1,b:_0;b=e:2": [
        "D22"
      ],
      "o=r:yellow_20|brown_50;p=a:1,b:_0;l=E": [
        "E23",
        "I17"
      ],
      "o=r:yellow_30|brown_70,h:1;p=a:1,b:_0;l=E;b=e:0": [
        "F22"
      ],
      "o=r:yellow_30|brown_70;p=a:1,b:_0;p=a:2,b:_0;b=e:3": [
        "G21"
      ],
      "o=r:yellow_20|brown_40;p=a:2,b:_0;l=E": [
        "H20"
      ],
      "o=r:yellow_50|brown_70;p=a:3,b:_0;p=a:4,b:_0;l=W": [
        "I1"
      ],
      "o=r:yellow_50|brown_70;p=a:2,b:_0;p=a:3,b:_0": [
        "J10"
      ]
    },
    "yellow": {
      "c=r:40,s:2;p=a:1,b:_0;p=a:3,b:_0;l=Z;u=c:40,t:water": [
        "C15"
      ],
      "c=r:10;c=r:10;c=r:10;c=r:10;p=a:0,b:_0;p=a:3,b:_1;p=a:4,b:_2;p=a:5,b:_3;l=Chi": [
        "D6"
      ],
      "c=r:10,s:2;p=a:1,b:_0;p=a:3,b:_0;p=a:0,b:_0": [
        "D20"
      ],
      "c=r:10;p=a:1,b:_0;p=a:2,b:_0;p=a:4,b:_0": [
        "E21"
      ],
      "c=r:10;p=a:5,b:_0": [
        "G19"
      ]
    },
    "blue": {
      "blank": [
        "C19",
        "D16"
      ]
    }
  },
  "phases": [
    {
      "name": "1",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ]
    },
    {
      "name": "2",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ]
    },
    {
      "name": "3",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "events": {
        "close_companies": true
      }
    },
    {
      "name": "4",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "events": {
        "remove_tokens": true
      }
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
