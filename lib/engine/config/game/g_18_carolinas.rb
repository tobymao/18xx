# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18Carolinas
        JSON = <<-'DATA'
{
  "filename": "18_carolinas",
  "modulename": "18Carolinas",
  "currencyFormatStr": "$%d",
  "bankCash": 6000,
  "certLimit": {
    "2": 24,
    "3": 20,
    "4": 16,
    "5": 13,
    "6": 11
  },
  "startingCash": {
    "2": 1200,
    "3": 800,
    "4": 600,
    "5": 480,
    "6": 400
  },
  "capitalization": "full",
  "layout": "pointy",
  "axes": {
    "rows": "numbers",
    "columns": "letters"
  },
  "mustSellInBlocks": false,
  "locationNames": {
    "A7": "Knoxville",
    "A23": "Richmond",
    "B20": "Weldon",
    "C13": "Greensboro",
    "C15": "Durham & Cary",
    "C17": "Raleigh",
    "C21": "Greenville",
    "D4": "Asheville",
    "C9": "Statesville",
    "D10": "Charlotte",
    "D12": "Concord",
    "D8": "Gastonia",
    "E15": "Fayetteville",
    "E5": "Greenville",
    "E7": "Spartanburg & Gaffney",
    "E9": "Rock Hill",
    "F20": "Jacksonville",
    "G1": "Atlanta",
    "G11": "Camden",
    "G13": "Florence",
    "G19": "Wilmington",
    "G9": "Columbia",
    "H12": "Santee",
    "H16": "Myrtle Beach",
    "H6": "Augusta",
    "I11": "St George",
    "I15": "Georgetown",
    "J10": "Beaufort",
    "J12": "Charleston"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 2,
    "4": 3,
    "5": 4,
    "6": 4,
    "7": 3,
    "8": 13,
    "9": 10,
    "55": 1,
    "56": 1,
    "57": 4,
    "58": 2,
    "12": 3,
    "13": 3,
    "14": 3,
    "15": 4,
    "16": 1,
    "19": 1,
    "20": 1,
    "23": 3,
    "24": 3,
    "25": 2,
    "26": 1,
    "27": 1,
    "28": 2,
    "29": 2,
    "87": 3,
    "88": 2,
    "38": 4,
    "39": 1,
    "40": 1,
    "42": 1,
    "43": 1,
    "44": 1,
    "45": 1,
    "46": 1,
    "47": 1,
    "70": 1
  },
  "market": [
    [
      "0",
      "10",
      "20",
      "30",
      "40",
      "50",
      "60p",
      "70p",
      "80p",
      "90p",
      "100",
      "110",
      "125",
      "140",
      "160",
      "180",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325",
      "350"
    ]
  ],
  "companies": [
    {
      "name": "South Carolina Canal and Rail Road Company",
      "value": 30,
      "revenue": 5,
      "desc": "Sell to the bank for $30 less than face value.",
      "sym": "SCCRR"
    },
    {
      "name": "Halifax & Weldon Railroad",
      "value": 75,
      "revenue": 12,
      "desc": "Sell to the bank for $30 less than face value.",
      "sym": "HWR"
    },
    {
      "name": "Louisville, Cincinnati, and Charleston Railroad",
      "value": 130,
      "revenue": 20,
      "desc": "Sell to the bank for $30 less than face value.",
      "sym": "LCCR"
    }

    ,
    {
      "name": "Wilmington and Raleigh Railroad",
      "value": 210,
      "revenue": 30,
      "desc": "Sell to the bank for $30 less than face value.",
      "sym": "WRR"
    }
  ],
  "corporations": [
    {
      "float_percent": 60,
      "sym": "NCR",
      "name": "North Carolina Railroad",
      "logo": "18_carolinas/NCR",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "C13",
      "color": "red"
    },
    {
      "float_percent": 60,
      "sym": "WM",
      "name": "Wilmington and Manchester Railroad",
      "logo": "18_carolinas/WM",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "H16",
      "color": "deepPink"
    },
    {
      "float_percent": 60,
      "sym": "WNC",
      "name": "Western North Carolina Railroad",
      "logo": "18_carolinas/WNC",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "D8",
      "color": "orange"
    },
    {
      "float_percent": 60,
      "sym": "SR",
      "name": "Southern Railway",
      "logo": "18_carolinas/SR",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "J12",
      "color": "green"
    },
    {
      "float_percent": 60,
      "sym": "WW",
      "name": "Wilmington and Weldon Railroad",
      "logo": "18_carolinas/WW",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "C21",
      "color": "yellow",
      "text_color": "black"
    },
    {
      "float_percent": 60,
      "sym": "CSC",
      "name": "Charlotte and South Carolina Railroad",
      "logo": "18_carolinas/CSC",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "D10",
      "color": "black"
    },
    {
      "float_percent": 60,
      "sym": "SEA",
      "name": "Seaboard and Roanoke Railroad",
      "logo": "18_carolinas/SEA",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "J6",
      "color": "DeepSkyBlue",
      "text_color": "black"

    },
    {
      "float_percent": 60,
      "sym": "CAR",
      "name": "Columbia and Augusta Railroad",
      "logo": "18_carolinas/CAR",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "G9",
      "color": "DarkBlue"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": "4",
      "num": 7
    },
    {
      "name": "3",
      "distance": 3,
      "price": 180,
      "rusts_on": "6",
      "num": 6
    },
    {
      "name": "4",
      "distance": 4,
      "price": 300,
      "rusts_on": "D",
      "num": 5
    },
    {
      "name": "5",
      "distance": 5,
      "price": 500,
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
      "price": 900,
      "num": 20,
      "available_on": "6",
      "discount": {
        "4": 200,
        "5": 200,
        "6": 200
      }
    }
  ],
  "hexes": {
    "white": {
      "blank": [
        "B6",
        "B8",
        "B10",
        "B12",
        "B14",
        "B16",
        "B18",
        "B22",
        "C5",
        "C7",
        "C11",
        "C19",
        "C23",
        "D6",
        "D14",
        "D16",
        "D18",
        "D20",
        "D22",
        "E3",
        "E11",
        "E13",
        "E17",
        "E19",
        "E21",
        "E23",
        "F2",
        "F6",
        "F8",
        "F10",
        "F12",
        "F14",
        "F16",
        "F18",
        "G3",
        "G7",
        "G15",
        "G17",
        "H2",
        "H4",
        "H8",
        "H10",
        "H14",
        "I3",
        "I5",
        "I7",
        "I9",
        "I13",
        "J8"
      ],
      "c=r:0;u=c:40,t:water": [
        "C17",
        "G9",
        "H6"
      ],
      "c=r:0;u=c:40,t:water;l=C": [
        "D10"
      ],
      "u=c:40,t:water": [
        "G5",
        "F4"
      ],
      "t=r:0;t=r:0": [
        "C15",
        "E7"
      ],
      "city": [
        "B20",
        "C13",
        "C21",
        "D4",
        "D8",
        "E9",
        "E15",
        "E5",
        "G13",
        "H16",
        "I11"
      ],
      "town": [
        "C9",
		"D12",
		"F20",
		"G11",
		"I15",
		"J10"
      ],
      "t=r:0;u=c:40,t:water": [
        "H12"
      ],
      "c=r:0;l=C": [
        "J12",
        "G19"
      ]
    },
    "red": {
      "o=r:yellow_30|green_40|brown_60|gray_80;p=a:0,b:_0": [
        "A7"
      ],
      "o=r:yellow_40|green_50|brown_60|gray_80;p=a:0,b:_0": [
        "A23"
      ],
      "o=r:yellow_40|green_60|brown_80|gray_100;p=a:4,b:_0": [
        "G1"
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
      "on": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "buy_companies": true
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "buy_companies": true
    },
    {
      "name": "5",
      "on": "5",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3,
      "events": {
        "close_companies": true
      }
    },
    {
      "name": "6",
      "on": "6",
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
      "on": "D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
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
