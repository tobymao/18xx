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
    "H2": "Holland",
    "P2": "Port Huron",
    "R2": "Sarnia",
    "E3": "Chicago Connections",
    "I3": "South Bend",
    "O3": "Detroit",
    "Q3": "Windsor",
    "N4": "Toledo",
    "T4": "Erie",
    "U3": "Buffalo",
    "V4": "Buffalo",
    "K5": "Fort Wayne",
    "Q5": "Cleveland",
    "U5": "Salamanca",
    "W5": "Binghamton",
    "C7": "Springfield",
    "G7": "Terre Haute",
    "I7": "Indianapolis",
    "M7": "Dayton",
    "O7": "Columbus",
    "S7": "Wheeling",
    "U7": "Pittsburgh",
    "V6": "Pittsburgh",
    "L8": "Cincinnati",
    "T6": "Homewood",
    "T8": "Cumberland",
    "A9": "St. Louis",
    "E9": "Centralia",
    "O9": "Huntington",
    "Q9": "Charleston",
    "J10": "Louisville",
    "C11": "Cairo"
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
      "desc": "Starts with $60 in treasury, a 2 train, and a token in Detroit (O3). Splits revenue evenly with owner."
    },
    {
      "name": "Big 4",
      "value": 40,
      "debt": 60,
      "revenue": 0,
      "desc": "Starts with $60 in treasury, a 2 train, and a token in Indianapolis (I7). Splits revenue evenly with owner."
    },
    {
      "name": "Chicago and Western Indiana",
      "value": 60,
      "revenue": 10,
      "desc": "Reserves a token slot in Chicago (F4), in which the owning corporation may place an extra token at no cost."
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
      "desc": "The owning corporation may place a $30 marker in either St. Louis (A9) or Chicago (F4), to add $30 to all routes run to this location."
    },
    {
      "name": "Steamboat Company",
      "value": 40,
      "revenue": 10,
      "desc": "Place or shift the port marker among port locations (H2, E3, N4, S7, A9). Add $20 per port symbol to all routes run to this location by the owning (or assigned) company."
    },
    {
      "name": "Lake Shore Line",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may make an extra $0 cost tile upgrade of either Cleveland (Q5) or Toledo (N4), but not both."
    },
    {
      "name": "Michigan Central",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may lay up to two extra $0 cost yellow tiles in the MC's reserved hexes (J2, L2)."
    },
    {
      "name": "Ohio & Indiana",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may lay up to two extra $0 cost yellow tiles in the O&I's reserved hexes (N6, P6)."
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
      "coordinates": "T6",
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
      "coordinates": "T4",
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
      "coordinates": "S7",
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
      "coordinates": "O9",
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
      "coordinates": "U5",
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
      "coordinates": "P2",
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
      "coordinates": "C11",
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
        "E7",
        "F8",
        "D10",
        "N2",
        "K3",
        "M3",
        "H4",
        "J4",
        "L4",
        "G5",
        "I5",
        "M5",
        "O5",
        "S5",
        "D6",
        "H6",
        "J6",
        "L6",
        "K7",
        "B8",
        "D8",
        "H8",
        "J8",
        "C9",
        "G9",
        "I9",
        "H10",
        "R4",
        "J2",
        "L2",
        "N6",
        "P6",
        "K9",
        "F10"
      ],
      "city": [
        "P2",
        "I3",
        "N4",
        "K5",
        "C7",
        "G7",
        "I7",
        "M7",
        "O7"
      ],
      "c=r:0;l=Z": [
        "Q5",
        "L8"
      ],
      "u=c:40,t:mountain": [
        "R6",
        "Q7",
        "P8"
      ],
      "u=c:60,t:mountain": [
        "N8"
      ]
    },
    "gray": {
      "p=a:5,b:0": [
        "O1",
        "G3"
      ],
      "c=r:10;p=a:1,b:_0;p=a:2,b:_0;p=a:4,b:_0;p=a:5,b:_0": [
        "T6"
      ],
      "c=r:10,s:2;p=a:1,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:0,b:_0": [
        "E9"
      ],
      "c=r:20;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0": [
        "O9"
      ],
      "c=r:20;p=a:3,b:_0": [
        "C11"
      ]
    },
    "red": {
      "o=r:yellow_40|brown_10;p=a:4,b:_0": [
        "H2"
      ],
      "o=r:yellow_30|brown_50;p=a:1,b:_0;l=E": [
        "R2"
      ],
      "o=r:yellow_20|brown_40;p=a:5,b:_0;l=W": [
        "E3"
      ],
      "o=r:yellow_40|brown_60;p=a:1,b:_0;l=E": [
        "Q3"
      ],
      "o=r:yellow_30|brown_60;p=a:0,b:_0;l=E": [
        "U3"
      ],
      "o=r:yellow_30|brown_60;p=a:1,b:_0;l=E": [
        "V4"
      ],
      "o=r:yellow_20|brown_50;p=a:1,b:_0;l=E": [
        "W5",
        "Q9"
      ],
      "o=r:yellow_30|brown_70;p=a:1,b:_0;l=E": [
        "V6"
      ],
      "o=r:yellow_30|brown_70;p=a:1,b:_0;p=a:2,b:_0;l=E": [
        "U7"
      ],
      "o=r:yellow_20|brown_40;p=a:2,b:_0;l=E": [
        "T8"
      ],
      "o=r:yellow_50|brown_70;p=a:3,b:_0;p=a:4,b:_0;l=W": [
        "A9"
      ],
      "o=r:yellow_50|brown_70;p=a:2,b:_0;p=a:3,b:_0": [
        "J10"
      ]
    },
    "yellow": {
      "c=r:40,s:2;p=a:1,b:_0;p=a:3,b:_0;l=Z;u=c:40,t:water": [
        "O3"
      ],
      "c=r:10;c=r:10;c=r:10;c=r:10;p=a:3,b:_0;p=a:4,b:_1;p=a:5,b:_2;p=a:0,b:_3;l=Chi": [
        "F4"
      ],
      "c=r:10,s:2;p=a:1,b:_0;p=a:3,b:_0;p=a:0,b:_0": [
        "T4"
      ],
      "c=r:10;p=a:1,b:_0;p=a:2,b:_0;p=a:4,b:_0": [
        "U5"
      ],
      "c=r:10;p=a:5,b:_0": [
        "S7"
      ]
    },
    "blue": {
      "blank": [
        "S3",
        "P4"
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
