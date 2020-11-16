# frozen_string_literal: true

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
    "2": {
      "10" : 28,
      "9" : 24
    },
    "3": {
      "10" : 20,
      "9" : 17
    },
    "4": {
      "10" : 16,
      "9" : 14
    },
    "5": {
      "10" : 13,
      "9" : 11
    },
    "6": {
      "10" : 11,
      "9" : 9
    }
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
  "mustSellInBlocks": true,
  "locationNames": {
    "A2": "Denver",
    "A22": "Chicago",
    "B9": "Topeka",
    "B11": "Kansas City",
    "B19": "Springfield, IL",
    "C18": "St. Louis",
    "D5": "Wichita",
    "E12": "Springfield, MO",
    "F5": "Oklahoma City",
    "H13": "Little Rock",
    "H17": "Memphis",
    "J3": "Fort Worth",
    "J5": "Dallas",
    "K16": "Jackson",
    "L11": "Alexandria",
    "M2": "Austin",
    "M6": "Houston",
    "M14": "Baton Rouge",
    "M20": "Mobile",
    "M24": "Southeast",
    "N1": "Southwest",
    "N7": "Galveston",
    "N17": "New Orleans"
  },
  "tiles": {
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
    "69": 1,
    "141": 2,
    "142": 2,
    "143": 1,
    "144": 1,
    "145": 2,
    "146": 2,
    "147": 2,
    "170": 1,
    "171": 1,
    "172": 1
  },
  "market": [
    [
      "64y",
      "68",
      "72",
      "78",
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
      "285",
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
      "78",
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
      "285",
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
      "78",
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
      "285",
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
      "78p",
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
      "285",
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
      "78",
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
      "78",
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
      "78",
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
      "0c",
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
      "0c",
      "0c",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y"
    ],
    [
      "0c",
      "0c",
      "0c",
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
      "desc": "The GRSC has no special features.",
      "sym": "GRSC"
    },
    {
      "name": "Mississippi River Bridge Company",
      "value": 30,
      "revenue": 5,
      "desc": "Until this company is closed or sold to a public company, no company may bridge the Mississippi River. A company may lay track along the river, but may not lay track to cross the river, or do an upgrade that would cause track to cross the river. The public company that purchases the Mississippi River Bridge Company may build in one of the hexes along the Mississippi River for a $40 discount. This company may be purchased by one of the two companies on the Mississippi River (Missouri Pacific or St.Louis Southwestern) in phase one for $20 to $40. If one of these two public companies purchases this private company during their first operating round, that company can lay a tile at its starting city for no cost and in addition to its normal tile lay(s). The company cannot lay a tile in their starting city and upgrade it during the same operating round.",
      "sym": "MRBC",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "N10"
          ]
        },
        {
          "type":"tile_discount",
          "discount": 40,
          "terrain": "river",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "The Southern Cattle Company",
      "value": 50,
      "revenue": 10,
      "desc": "This company has a token that may be placed on any city west of the Mississippi River. Cities located in the same hex as any portion of the Mississippi are not eligible for this placement. This increases the value of that city by $10 for that company only. Placing the token does not close the company.",
      "sym": "SCC",
      "abilities": [
        {
          "type": "assign_hexes",
          "hexes": [
            "A2",
            "B5",
            "B6",
            "D3",
            "E7",
            "F4",
            "H7",
            "J2",
            "J3",
            "L6",
            "M2",
            "M4",
            "N1",
            "N4"
          ],
          "count": 1,
          "owner_type": "corporation"
        },
        {
          "type": "assign_corporation",
          "when": "sold",
          "count": 1,
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "The Gulf Shipping Company",
      "value": 80,
      "revenue": 15,
      "desc": "This company has two tokens. One represents an open port and the other is a closed port. One (but not both) of these tokens may be placed on one of the cities: Memphis (H17), Baton Rouge (M14), Mobile (M20), Galveston (N7) and New Orleans (N17). Either token increases the value of the city for the owning company by $20. The open port token also increases the value of the city for all other companies by $10. If the president of the owning company places the closed port token, the private company is closed. If the open port token is placed, it may be replaced in a later operating round by the closed port token, closing the company.",
      "sym": "GSC",
      "abilities": [
        {
          "type": "assign_hexes",
          "hexes": [
            "H17",
            "M14",
            "M20",
            "N7",
            "N17"
          ],
          "count": 1,
          "owner_type": "corporation"
        },
        {
          "type": "assign_corporation",
          "when": "sold",
          "count": 1,
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "St.Louis-San Francisco Railway",
      "value": 140,
      "revenue": 0,
      "desc": "This is the President's certificate of the St.Louis-San Francisco Railway. The purchaser sets the par value of the railway. Unlike other companies, this company may operate with just 20% sold. It may not be purchased by another public company.",
      "sym": "SLSF",
      "abilities": [
        {
          "type": "shares",
          "shares": "SLSF_0"
        },
        {
          "type": "close"
        }
      ]
    },
    {
      "name": "Missouri-Kansas-Texas Railroad",
      "value": 160,
      "revenue": 20,
      "desc": "Comes with a 10% share of the Missouri-Kansas-Texas Railroad.",
      "sym": "MKT",
      "abilities": [
        {
          "type": "shares",
          "shares": "MKT_1"
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 60,
      "sym": "ATSF",
      "name": "Santa Fe",
      "logo": "1870/ATSF",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "B9",
      "color": "deepskyblue"
    },
    {
      "float_percent": 60,
      "sym": "SSW",
      "name": "Cotton",
      "logo": "1870/SSW",
      "tokens": [
        0,
        40
      ],
      "coordinates": "H17",
      "color": "blue"
    },
    {
      "float_percent": 60,
      "sym": "SP",
      "name": "Southern Pacific",
      "logo": "1870/SP",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "J3",
      "color": "orange"
    },
    {
      "float_percent": 20,
      "sym": "SLSF",
      "name": "Frisco",
      "logo": "1870/SLSF",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "E12",
      "color": "red"
    },
    {
      "float_percent": 60,
      "sym": "MP",
      "name": "Missouri Pacific",
      "logo": "1870/MP",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "C18",
      "color": "brown"
    },
    {
      "float_percent": 60,
      "sym": "MKT",
      "name": "Katy",
      "logo": "1870/MKT",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "B11",
      "color": "green"
    },
    {
      "float_percent": 60,
      "sym": "IC",
      "name": "Illinois Central",
      "logo": "1870/IC",
      "tokens": [
        0,
        40
      ],
      "coordinates": "K16",
      "color": "slategrey"
    },
    {
      "float_percent": 60,
      "sym": "GMO",
      "name": "Gulf Mobile Ohio",
      "logo": "1870/GMO",
      "tokens": [
        0,
        40
      ],
      "coordinates": "M20",
      "color": "pink"
    },
    {
      "float_percent": 60,
      "sym": "FW",
      "name": "Fortsworth",
      "logo": "1870/FW",
      "tokens": [
        0,
        40
      ],
      "coordinates": "J3",
      "color": "purple"
    },
    {
      "float_percent": 60,
      "sym": "TP",
      "name": "Texas Pacific",
      "logo": "1870/TP",
      "tokens": [
        0,
        40
      ],
      "coordinates": "J5",
      "color": "black"
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
      "num": 4,
      "events":[
        {"type": "close_companies"}
      ]
    },
    {
      "name": "6",
      "distance": 6,
      "price": 630,
      "num": 3,
      "events":[
        {"type": "remove_tokens"}
      ]
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
      "num": 12
    }
  ],
  "hexes": {
    "white": {
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
      ],
      "city=revenue:0": [
        "B9",
        "B19",
        "D5",
        "F5",
        "H13",
        "J3",
        "J5",
        "K16",
        "M2",
        "M6"
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
      "city=revenue:0;icon=image:port": [
        "M20"
      ],
      "upgrade=cost:40,terrain:water": [
        "C14",
        "C16",
        "G2",
        "H5"
      ],
      "upgrade=cost:60,terrain:water": [
        "H7",
        "I8",
        "J11",
        "K10"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:water": [
        "B11"
      ],
      "city=revenue:0;upgrade=cost:60,terrain:water": [
        "L11"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:water": [
        "A10",
        "B13",
        "H3"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:60,terrain:water": [
        "I10",
        "E20"
      ],
      "upgrade=cost:40,terrain:river": [
        "B17"
      ],
      "upgrade=cost:60,terrain:river": [
        "D17",
        "E18",
        "F19",
        "G18",
        "I16",
        "J15"
      ],
      "upgrade=cost:80,terrain:river": [
        "L13",
        "N15"
      ],
      "upgrade=cost:100,terrain:river": [
        "O16",
        "O18"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:river": [
        "C18"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:river;icon=image:port": [
        "M14"
      ],
      "city=revenue:0;upgrade=cost:60,terrain:river;icon=image:port": [
        "H17"
      ],
      "town=revenue:0;upgrade=cost:80,terrain:river": [
        "K14"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:river": [
        "A16"
      ],
      "upgrade=cost:60,terrain:lake": [
        "O2"
      ],
      "upgrade=cost:80,terrain:lake": [
        "O4",
        "O6",
        "N9",
        "N11",
        "N13"
      ],
      "upgrade=cost:80,terrain:lake;border=edge:0,type:impassable;border=edge:1,type:impassable": [
        "N19"
      ],
      "upgrade=cost:100,terrain:lake": [
        "O14"
      ],
      "city=revenue:0;upgrade=cost:80,terrain:lake;icon=image:port": [
        "N7",
        "N17"
      ],
      "town=revenue:0;upgrade=cost:80,terrain:lake": [
        "N21"
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
      "city=revenue:0;upgrade=cost:60,terrain:mountain": [
        "E12"
      ]
    },
    "red": {
      "offboard=revenue:yellow_30|brown_40|blue_50;path=a:4,b:_0;path=a:5,b:_0": [
        "A2"
      ],
      "offboard=revenue:yellow_40|brown_50|blue_60;path=a:0,b:_0;path=a:1,b:_0": [
        "A22"
      ],
      "city=revenue:yellow_20|brown_40|blue_50;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1": [
        "N1"
      ],
      "offboard=revenue:yellow_20|brown_30|blue_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0": [
        "M22"
      ]
    }
  },
  "phases": [
    {
      "name": "1",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "2",
      "on": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "status":[
        "can_buy_companies"
      ]
    },
    {
      "name": "3",
      "on": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "status":[
        "can_buy_companies"
      ]
    },
    {
      "name": "4",
      "on": "5",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "5",
      "on": "6",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3
    },
    {
      "name": "6",
      "on": "8",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3
    },
    {
      "name": "7",
      "on": "10",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3
    },
    {
      "name": "8",
      "on": "12",
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
