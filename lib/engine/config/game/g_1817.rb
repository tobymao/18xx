# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1817
        JSON = <<-DATA
{
  "filename": "1817",
  "modulename": "1817",
  "currencyFormatStr": "$%d",
  "bankCash": 99999,
  "certLimit": {
    "3": 21,
    "4": 16,
    "5": 13,
    "6": 11,
    "7": 9
  },
  "startingCash": {
    "3": 420,
    "4": 315,
    "5": 252,
    "6": 210,
    "7": 180
  },
  "locationNames": {
    "A20": "Montréal",
    "A28": "Maritime Prov.",
    "B5": "Lansing",
    "B13": "Toronto",
    "B17": "Rochester",
    "C8": "Detroit",
    "C14": "Buffalo",
    "C22": "Albany",
    "C26": "Boston",
    "D1": "Chicago",
    "D7": "Toledo",
    "D9": "Cleveland",
    "D19": "Scranton",
    "F3": "Indianapolis",
    "F13": "Pittsburgh",
    "F19": "Philadelphia",
    "G6": "Cincinnati",
    "G18": "Baltimore",
    "H1": "St. Louis",
    "H3": "Louisville",
    "H9": "Charleston",
    "I12": "Blacksburg",
    "I16": "Richmond",
    "J7": "Atlanta",
    "J15": "Raleigh-Durham"
  },
  "tiles": {
    "5": 6,
    "6": 7,
    "7": 5,
    "8": 20,
    "9": 20,
    "14": 7,
    "15": 7,
    "54": 1,
    "57": 7,
    "62": 1,
    "63": 8,
    "80": 7,
    "81": 7,
    "82": 10,
    "83": 10,
    "448": 4,
    "544": 5,
    "545": 5,
    "546": 5,
    "592": 4,
    "593": 4,
    "597": 4,
    "611": 2,
    "619": 8,
    "X00": {
      "count": 1,
      "color": "yellow",
      "code": "c=r:30;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0;l=B"
    },
    "X30": {
      "count": 1,
      "color": "gray",
      "code": "c=r:100,s:4;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;l=NY"
    }
  },
  "market": [
    [
      "0",
      "40",
      "40",
      "40",
      "40",
      "45",
      "50",
      "55",
      "60",
      "65",
      "70",
      "80",
      "90",
      "100",
      "110",
      "120",
      "135",
      "150",
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
      "440",
      "490",
      "540",
      "600"
    ]
  ],
  "companies": [],
  "corporations": [
    {
      "float_percent": 20,
      "sym": "A&S",
      "name": "Alton & Southern Railway",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "pink"
    },
    {
      "float_percent": 20,
      "sym": "A&A",
      "name": "Arcade and Attica",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "gold"
    },
    {
      "float_percent": 20,
      "sym": "Belt",
      "name": "Belt Railway of Chicago",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "orange"
    },
    {
      "float_percent": 20,
      "sym": "Bess",
      "name": "Bessemer and Lake Erie Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "black"
    },
    {
      "float_percent": 20,
      "sym": "B&A",
      "name": "Boston and Albany Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "red"
    },
    {
      "float_percent": 20,
      "sym": "DL&W",
      "name": "Delaware, Lackawanna and Western Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "brown"
    },
    {
      "float_percent": 20,
      "sym": "J",
      "name": "Elgin, Joliet and Eastern Railway",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "green"
    },
    {
      "float_percent": 20,
      "sym": "GT",
      "name": "Grand Trunk Western Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "violet"
    },
    {
      "float_percent": 20,
      "sym": "H",
      "name": "Housatonic Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lightBlue"
    },
    {
      "float_percent": 20,
      "sym": "ME",
      "name": "Morristown and Erie Railway",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "yellow"
    },
    {
      "float_percent": 20,
      "sym": "NYOW",
      "name": "New York, Ontaria and Western Railway",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "turquoise"
    },
    {
      "float_percent": 20,
      "sym": "NYSW",
      "name": "New York, Susquehanna and Western Railway",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "white"
    },
    {
      "float_percent": 20,
      "sym": "PSNR",
      "name": "Pittsburg, Shawmut and Northern Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "brightGreen"
    },
    {
      "float_percent": 20,
      "sym": "PLE",
      "name": "Pittsburg and Lake Erie Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lime"
    },
    {
      "float_percent": 20,
      "sym": "PW",
      "name": "Providence and Worcester Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lightBrown"
    },
    {
      "float_percent": 20,
      "sym": "R",
      "name": "Rutland Railraod",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "blue"
    },
    {
      "float_percent": 20,
      "sym": "SR",
      "name": "Strasburg Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "natural"
    },
    {
      "float_percent": 20,
      "sym": "UR",
      "name": "Union Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "navy"
    },
    {
      "float_percent": 20,
      "sym": "WT",
      "name": "Warren & Trumbull Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lavender"
    },
    {
      "float_percent": 20,
      "sym": "WC",
      "name": "West Chester Railroad",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lavender"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 20
    },
    {
      "name": "2+",
      "distance": 2,
      "price": 100,
      "num": 4
    },
    {
      "name": "3",
      "distance": 3,
      "price": 250,
      "rusts_on": "6",
      "num": 12
    },
    {
      "name": "4",
      "distance": 4,
      "price": 400,
      "rusts_on": "8",
      "num": 8
    },
    {
      "name": "5",
      "distance": 5,
      "price": 600,
      "num": 5
    },
    {
      "name": "6",
      "distance": 6,
      "price": 750,
      "num": 4
    },
    {
      "name": "7",
      "distance": 7,
      "price": 900,
      "num": 3
    },
    {
      "name": "8",
      "distance": 8,
      "price": 1100,
      "num": 16
    }
  ],
  "hexes": {
    "red": {
      "o=r:yellow_20|green_30|brown_50|gray_60;p=a:4,b:_0;p=a:5,b:_0": [
        "A20"
      ],
      "o=r:yellow_20|green_30|brown_50|gray_60;p=a:5,b:_0": [
        "A28"
      ],
      "o=r:yellow_20|green_30|brown_50|gray_60;p=a:3,b:_0;p=a:4,b:_0": [
        "D1"
      ],
      "o=r:yellow_20|green_30|brown_50|gray_60;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0": [
        "H1"
      ],
      "o=r:yellow_20|green_30|brown_50|gray_60;p=a:1,b:_0;p=a:2,b:_0": [
        "J7",
        "J15"
      ]
    },
    "white": {
      "city": [
        "B5",
        "B17",
        "C14",
        "C22",
        "F3",
        "F13",
        "F19",
        "I16"
      ],
      "c=r:0;u=c:20,t:water": [
        "D7"
      ],
      "c=r:0;u=c:15,t:mountain": [
        "D19",
        "I12"
      ],
      "c=r:0;u=c:10,t:water": [
        "G6",
        "H3",
        "H9"
      ],
      "u=c:15,t:mountain": [
        "B25",
        "C20",
        "C24",
        "E16",
        "E18",
        "F15",
        "G12",
        "G14",
        "H11",
        "H13",
        "H15",
        "I8",
        "I10"
      ],
      "u=c:10,t:water": [
        "D13",
        "E12",
        "F11",
        "G4",
        "G10",
        "H7"
      ],
      "u=c:20,t:water": [
        "B9",
        "B27",
        "D25",
        "D27",
        "G20",
        "H17"
      ],
      "blank": [
        "B3",
        "B7",
        "B11",
        "B15",
        "B19",
        "B21",
        "B23",
        "C4",
        "C6",
        "C10",
        "C16",
        "C18",
        "D3",
        "D5",
        "D11",
        "D15",
        "D17",
        "D21",
        "D23",
        "E2",
        "E4",
        "E6",
        "E8",
        "E10",
        "E14",
        "E20",
        "F5",
        "F7",
        "F9",
        "F17",
        "F21",
        "G2",
        "G8",
        "G16",
        "H5",
        "I2",
        "I4",
        "I6",
        "I14"
      ]
    },
    "gray": {
      "o=r:yellow_20|green_30|brown_40;t=r:0;p=a:0,b:_0;p=a:3,b:_0;p=a:4,b:_0": [
        "B13"
      ],
      "o=r:yellow_30|green_40|brown_50|gray_60;c=r:0,s:2;p=a:4,b:_0;p=a:5,b:_0": [
        "D9"
      ],
      "p=a:3,b:j;p=a:4,b:j;p=a:5,b=j": [
        "F1"
      ]
    },
    "yellow": {
      "c=r:30;p=a:3,b:_0;p=a:5,b:_0;l=B;u=c:20,t:water": [
        "C8"
      ],
      "c=r:30;p=a:2,b:_0;p=a:4,b:_0;l=B": [
        "C26"
      ],
      "c=r:40;c=r:40;p=a:2,b:_0;p=a:5,b:_0;l=NY;u=c:20,t:water": [
        "E22"
      ],
      "c=r:30;p=a:3,b:_0;p=a:5,b:_0;l=B": [
        "G18"
      ]
    },
    "blue": {
      "blank": [
        "C12"
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
      "operating_rounds": 2
    },
    {
      "name": "2+",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 2
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
      "operating_rounds": 2
    },
    {
      "name": "6",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 2
    },
    {
      "name": "7",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 2
    },
    {
      "name": "8",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
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
