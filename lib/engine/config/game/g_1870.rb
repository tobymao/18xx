# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1870
        JSON = <<-'DATA'
{
  "filename": "1870",
  "modulename": "1870",
  "currencyFormatStr": "$%d",
  "bankCash": 12000,
  "certLimit": {
    "2": "28 / 24",
    "3": "20 / 17",
    "4": "16 / 14",
    "5": "13 / 11",
    "6": "11 / 9"
  },
  "startingCash": {
    "2": 1050,
    "3": 700,
    "4": 525,
    "5": 420,
    "6": 350
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A2": "Denver",
    "A22": "Chicago",
    "N1": "Southwest",
    "M22": "Southeast",
    "B9": "Topeka",
    "B11": "Kansas City",
    "E12": "Springfield",
    "H17": "Memphis",
    "C18": "St. Louis",
    "J3": "Fort Worth",
    "J5": "Dallas",
    "K16": "Jackson",
    "M20": "Mobile",
    "N17": "New Orleans"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 3,
    "4": 6,
    "5": 2,
    "6": 2,
    "7": 9,
    "8": 22,
    "9": 23,
    "14": 4,
    "15": 4,
    "16": 2,
    "17": 2,
    "18": 2,
    "19": 2,
    "20": 2,
    "23": 4,
    "24": 4,
    "25": 3,
    "26": 2,
    "27": 2,
    "28": 2,
    "29": 2,
    "39": 1,
    "40": 2,
    "41": 3,
    "42": 3,
    "43": 2,
    "44": 1,
    "45": 2,
    "46": 2,
    "47": 2,
    "55": 1,
    "56": 1,
    "57": 5,
    "58": 4,
    "63": 5,
    "69": 1,
    "70": 2,
    "141": 2,
    "142": 2,
    "143": 1,
    "144": 1,
    "145": 2,
    "146": 2,
    "147": 2,
    "170": 4,
    "171": 1,
    "172": 1
  },
  "market": [
    [
      "64y",
      "68",
      "72",
      "76",
      "82",
      "90",
      "100p",
      "110",
      "120",
      "140",
      "160",
      "180",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325",
      "350",
      "375",
      "400"
    ],
    [
      "60y",
      "64y",
      "68",
      "72",
      "76",
      "82",
      "90p",
      "100",
      "110",
      "120",
      "140",
      "160",
      "180",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325",
      "350",
      "375"
    ],
    [
      "55y",
      "60y",
      "64y",
      "68",
      "72",
      "76",
      "82p",
      "90",
      "100",
      "110",
      "120",
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
    ],
    [
      "50o",
      "55y",
      "60y",
      "64y",
      "68",
      "72",
      "76p",
      "82",
      "90",
      "100",
      "110",
      "120",
      "140",
      "160",
      "180",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325"
    ],
    [
      "40b",
      "50o",
      "55y",
      "60y",
      "64",
      "68",
      "72p",
      "76",
      "82",
      "90",
      "100",
      "110",
      "120",
      "140",
      "160",
      "180"
    ],
    [
      "30b",
      "40o",
      "50o",
      "55y",
      "60y",
      "64",
      "68p",
      "72",
      "76",
      "82",
      "90",
      "100",
      "110"
    ],
    [
      "20b",
      "30b",
      "40o",
      "50o",
      "55y",
      "60y",
      "64",
      "68",
      "72",
      "76",
      "82"
    ],
    [
      "10b",
      "20b",
      "30b",
      "40o",
      "50y",
      "55y",
      "60y",
      "64",
      "68",
      "72"
    ],
    [
      "[object Object]",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y",
      "55y",
      "60",
      "64"
    ],
    [
      "[object Object]",
      "[object Object]",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y"
    ],
    [
      "[object Object]",
      "[object Object]",
      "[object Object]",
      "10b",
      "20b",
      "30b",
      "40o"
    ]
  ],
  "companies": [
    {
      "name": "Great River Shipping Company",
      "value": 20,
      "revenue": 5,
      "desc": "No special abilities."
    },
    {
      "name": "Mississippi River Bridge Company",
      "value": 40,
      "revenue": 10,
      "desc": "No special abilities."
    },
    {
      "name": "The Southern Cattle Company",
      "value": 50,
      "revenue": 10,
      "desc": "This company has a token that may be placed on any city west of the Mississippi River. Cities located in the same hex as any portion of the Mississippi are not eligible for this placement. This increases the value of that city by $10 for that company only. Placing the token does not close the company."
    },
    {
      "name": "The Gulf Shipping Company",
      "value": 80,
      "revenue": 15,
      "desc": "No special abilities."
    },
    {
      "name": "St. Louis-San Francisco Railway",
      "value": 140,
      "revenue": 0,
      "desc": "This is the President's certificate of the St.Louis-San Francisco Railway. The purchaser sets the par value of the railway. Unlike other companies, this company may operate with just 20% sold. It may not be purchased by another public company."
    },
    {
      "name": "Missouri-Kansas-Texas Railroad",
      "value": 160,
      "revenue": 20,
      "desc": "Comes with a 10% share of the Missouri-Kansas-Texas Railroad."
    }
  ],
  "corporations": [
    {
      "sym": "SP",
      "name": "Southern Pacific Railroad",
      "logo": "1870/SP",
      "tokens": [
        0,
        0,
        40,
        100
      ],
      "color": "orange"
    },
    {
      "sym": "MKT",
      "name": "Missouri Kansas Texas Railroad",
      "logo": "1870/MKT",
      "tokens": [
        0,
        0,
        40,
        100
      ],
      "color": "green"
    },
    {
      "sym": "FW",
      "name": "Fort Worth & Denver City Railway",
      "logo": "1870/FW",
      "tokens": [
        0,
        0,
        40
      ],
      "color": "brightGreen"
    },
    {
      "sym": "MP",
      "name": "Missouri Pacific Railroad",
      "logo": "1870/MP",
      "tokens": [
        0,
        0,
        40,
        100
      ],
      "color": "brown"
    },
    {
      "sym": "GMO",
      "name": "Gulf, Mobile & Ohio Railroad",
      "logo": "1870/GMO",
      "tokens": [
        0,
        0,
        40
      ],
      "color": "pink"
    },
    {
      "sym": "TP",
      "name": "Texas & Pacific Railway",
      "logo": "1870/TP",
      "tokens": [
        0,
        0,
        40
      ],
      "color": "black"
    },
    {
      "sym": "SSW",
      "name": "St. Louis Southwestern Railway",
      "logo": "1870/SSW",
      "tokens": [
        0,
        0,
        40
      ],
      "color": "blue"
    },
    {
      "sym": "IC",
      "name": "Illinois Central Railroad",
      "logo": "1870/IC",
      "tokens": [
        0,
        0,
        40
      ],
      "coordinates": "K16",
      "color": "yellow"
    },
    {
      "sym": "ATSF",
      "name": "Atchison, Topeka & Santa Fe",
      "logo": "1870/ATSF",
      "tokens": [
        0,
        0,
        40,
        100
      ],
      "color": "brightBlue"
    },
    {
      "sym": "SLSF",
      "name": "St. Louis-San Francisco Railway",
      "logo": "1870/SLSF",
      "tokens": [
        0,
        0,
        40,
        100
      ],
      "color": "red"
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
      "rusts_on": "8",
      "num": 5
    },
    {
      "name": "5",
      "distance": 5,
      "price": 450,
      "rusts_on": "12",
      "num": 4
    },
    {
      "name": "6",
      "distance": 6,
      "price": 630,
      "num": 3
    },
    {
      "name": "8",
      "distance": 8,
      "price": 800,
      "num": 3
    },
    {
      "name": "10",
      "distance": 10,
      "price": 950,
      "num": 2
    },
    {
      "name": "12",
      "distance": 12,
      "price": 1100,
      "num": 6
    }
  ],
  "hexes": {
    "red": {
      "offboard=revenue:white_30|black_40|white_50;path=a:4,b:_0;path=a:5,b:_0": [
        "A2"
      ],
      "offboard=revenue:white_40|black_50|white_60;path=a:1,b:_0;path=a:0,b:_0": [
        "A22"
      ],
      "city=revenue:white_20|black_40|white_50;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "N1"
      ],
      "offboard=revenue:white_20|black_30|white_50;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0": [
        "M22"
      ]
    },
    "white": {
      "town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:water": [
        "A16"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:60,terrain:water": [
        "E20",
        "I10"
      ],
      "city=revenue:0": [
        "B9",
        "K16",
        "M20",
        "B19",
        "D5",
        "F5",
        "H13",
        "M2",
        "M6"
      ],
      "city=revenue:0;label=P;upgrade=cost:40,terrain:water": [
        "B11",
        "C18"
      ],
      "city=revenue:0;upgrade=cost:60,terrain:mountain": [
        "E12"
      ],
      "city=revenue:0;upgrade=cost:60,terrain:water": [
        "H17",
        "L11"
      ],
      "city=revenue:0;label=P": [
        "J3",
        "J5"
      ],
      "city=revenue:0;upgrade=cost:80,terrain:water": [
        "M14",
        "N7"
      ],
      "city=revenue:0;label=P;upgrade=cost:80,terrain:water": [
        "N17"
      ],
      "town=revenue:0;upgrade=cost:80,terrain:water": [
        "N21",
        "K14"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:water": [
        "A10",
        "B13",
        "D17",
        "H3"
      ],
      "upgrade=cost:60,terrain:mountain": [
        "D13",
        "D15",
        "E14",
        "E16",
        "F11",
        "F13",
        "F15"
      ],
      "upgrade=cost:40,terrain:water": [
        "B17",
        "C14",
        "C16",
        "G2",
        "H5"
      ],
      "upgrade=cost:60,terrain:water": [
        "E18",
        "F19",
        "G18",
        "H7",
        "I8",
        "I16",
        "J11",
        "J15",
        "K10",
        "O2"
      ],
      "upgrade=cost:80,terrain:water": [
        "L13",
        "O4",
        "O6",
        "N9",
        "N11",
        "N13",
        "N15",
        "N19"
      ],
      "upgrade=cost:100,terrain:water": [
        "O14",
        "O16",
        "O18"
      ],
      "town=revenue:0": [
        "B7",
        "D9",
        "D21",
        "E8",
        "F9",
        "G10",
        "G20",
        "H21",
        "I14",
        "J9",
        "K4",
        "K20",
        "M8",
        "M10"
      ],
      "": [
        "A4",
        "A6",
        "A8",
        "A12",
        "A14",
        "A18",
        "A20",
        "B3",
        "B5",
        "B15",
        "B21",
        "C2",
        "C4",
        "C6",
        "C8",
        "C10",
        "C12",
        "C20",
        "D1",
        "D3",
        "D7",
        "D11",
        "D19",
        "E2",
        "E4",
        "E6",
        "E10",
        "F1",
        "F3",
        "F7",
        "F17",
        "F21",
        "G4",
        "G6",
        "G8",
        "G12",
        "G14",
        "G16",
        "H1",
        "H9",
        "H11",
        "H15",
        "H19",
        "I2",
        "I4",
        "I6",
        "I12",
        "I18",
        "I20",
        "J1",
        "J7",
        "J13",
        "J17",
        "J19",
        "J21",
        "K2",
        "K6",
        "K8",
        "K12",
        "K18",
        "L1",
        "L3",
        "L5",
        "L7",
        "L9",
        "L15",
        "L17",
        "L19",
        "L21",
        "M4",
        "M12",
        "M16",
        "M18",
        "N3",
        "N5"
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
        "brown",
        "gray"
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
      "name": "10",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ]
    },
    {
      "name": "12",
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
