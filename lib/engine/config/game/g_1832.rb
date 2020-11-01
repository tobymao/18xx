# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1832
        JSON = <<-'DATA'
{
  "filename": "1832",
  "modulename": "1832",
  "currencyFormatStr": "$%d",
  "bankCash": 12000,
  "certLimit": {
    "2": 28,
    "3": 20,
    "4": 16,
    "5": 13,
    "6": 11,
    "7": 9
  },
  "startingCash": {
    "2": 1050,
    "3": 700,
    "4": 525,
    "5": 420,
    "6": 350,
    "7": 300
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A7": "Louisville",
    "A21": "Richmond",
    "B2": "Kansas City",
    "B14": "W. Va. Coalfields & $80",
    "B18": "Lynchburg",
    "B24": "Norfolk",
    "C3": "Jackson",
    "C7": "Nashville",
    "C11": "Knoxville",
    "C17": "Winston Salem & Greensboro",
    "D4": "Corinth",
    "D16": "Charlotte",
    "D20": "Raleigh",
    "E17": "Columbia",
    "E21": "Wilmington",
    "F6": "Birmingham",
    "F10": "Atlanta",
    "G3": "Meridian",
    "G17": "Charleston",
    "H8": "Eufaula",
    "H16": "Savannah",
    "I3": "Mobile",
    "J2": "New Orleans",
    "J4": "Pensacola",
    "J10": "Talahassee",
    "J12": "Valdosta",
    "J14": "Jacksonville",
    "M13": "Tampa",
    "M15": "Lakeland & Winter Haven",
    "N16": "Key West & Miami"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 3,
    "4": 4,
    "5": 2,
    "7": 7,
    "8": 20,
    "9": 20,
    "14": 4,
    "15": 4,
    "16": 1,
    "17": 1,
    "18": 1,
    "19": 1,
    "20": 1,
    "23": 4,
    "24": 4,
    "25": 1,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "39": 1,
    "40": 1,
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
    "63": 4,
    "69": 1,
    "70": 1,
    "141": 1,
    "142": 1,
    "143": 1,
    "144": 1,
    "145": 1,
    "146": 1,
    "147": 1,
    "190": 1,
    "191": 1,
    "193": 1,
    "611": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=JC"
    }
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
      "40o",
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
      "60",
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
      "60",
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
      "name": "Carolina Stage Coach",
      "value": 20,
      "revenue": 5,
      "desc": "No special abilities."
    },
    {
      "name": "Cotton Warehouse",
      "value": 40,
      "revenue": 10,
      "desc": "This company has a $10 token which may be placed in any non-coastal city (Atlantic or Gulf Coast) as an extra token lay during the token placement step of an owning public company's operating round."
    },
    {
      "name": "Atlantic Shipping",
      "value": 50,
      "revenue": 10,
      "desc": "This company has a Port token which may be placed on any city on the coasts as an extra token lay during the token placement step of an owning public company's operating round. All eligible cities are marked with an anchor symbol. This token increases the value of the selected city by $20 for the owning company and by $10 for all other companies."
    },
    {
      "name": "London Investment",
      "value": 70,
      "revenue": 10,
      "desc": "This company represents those shrewd investors in London. They have hired you to invest their money in the new Southern railways. They will purchase a share of your choice in any newly started company. You get the share. After the company pays its first dividend, the London Investment Company is closed, as they realize they have paid you for nothing and you spent the money for yourself."
    },
    {
      "name": "West Virginia Coalfields",
      "value": 80,
      "revenue": 15,
      "desc": "This private company gives the owning company a WVCF token for free. When other companies connect to the coal fields, they may buy a WVCF token (if available) during their operating round for $80 ($40 goes to the company owning the WVCF private company)."
    },
    {
      "name": "Southern Bank",
      "value": 100,
      "revenue": "$10/10%",
      "desc": "You may loan money to your company by taking out a mortgage on a company asset. The mortgage value is from half to double the value of the asset. At the start of each operating round, the company will pay you 10% interest (10% of the value of the mortgaged asset). If the company does not have enough money to pay the interest, it pays nothing. The company will repay the mortgage for half to full value of the asset. "
    },
    {
      "name": "Central Railroad & Canal",
      "value": 200,
      "revenue": 30,
      "desc": "Comes with the president's share of the Central of Georgia Railway. The player buying this private company must immediately set the par value of the CoG. "
    }
  ],
  "corporations": [
    {
      "sym": "SCL",
      "name": "Seaboard Coast Lines",
      "logo": "1832/SCL",
      "tokens": [
        100,
        100,
        100,
        100,
        100,
        100
      ],
      "color": "red"
    },
    {
      "sym": "NS",
      "name": "Norfolk Southern",
      "logo": "1832/NS",
      "tokens": [
        100,
        100,
        100,
        100,
        100,
        100
      ],
      "color": "black"
    },
    {
      "sym": "IC",
      "name": "Illinois Central",
      "logo": "1832/IC",
      "tokens": [
        100,
        100,
        100,
        100,
        100,
        100
      ],
      "color": "green"
    },
    {
      "sym": "AMTK",
      "name": "Amtrak",
      "logo": "1832/AMTK",
      "tokens": [
        100,
        100,
        100,
        100,
        100,
        100
      ],
      "color": "blue"
    },
    {
      "sym": "CSX",
      "name": "CSX Transportation",
      "logo": "1832/CSX",
      "tokens": [
        100,
        100,
        100,
        100,
        100,
        100
      ],
      "color": "cyan"
    },
    {
      "sym": "ACL",
      "name": "Atlantic Coast Line Railroad",
      "logo": "1832/ACL",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "G17",
      "color": "pink"
    },
    {
      "sym": "A&WP",
      "name": "Atlanta & West Point Railroad",
      "logo": "1832/AWP",
      "tokens": [
        0,
        40
      ],
      "coordinates": "F10",
      "color": "purple"
    },
    {
      "sym": "SALR",
      "name": "Seaboard Air Line Railway",
      "logo": "1832/SALR",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "D20",
      "color": "orange"
    },
    {
      "sym": "N&W",
      "name": "Norfolk & Western Railway",
      "logo": "1832/NW",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "B24",
      "color": "black"
    },
    {
      "sym": "COG",
      "name": "Central of Georgia Railway",
      "logo": "1832/COG",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "H16",
      "color": "turquoise"
    },
    {
      "sym": "L&N",
      "name": "Louisville & Nashville Railroad",
      "logo": "1832/LN",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "C7",
      "color": "blue"
    },
    {
      "sym": "GRR",
      "name": "Georgia Railroad",
      "logo": "1832/GRR",
      "tokens": [
        0,
        40
      ],
      "coordinates": "F10",
      "color": "cyan"
    },
    {
      "sym": "GMO",
      "name": "Gulf, Mobile & Ohio Railroad",
      "logo": "1832/GMO",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "J2",
      "color": "red"
    },
    {
      "sym": "SOU",
      "name": "Southern Railway",
      "logo": "1832/SOU",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "C11",
      "color": "green"
    },
    {
      "sym": "FECR",
      "name": "Florida East Coast Railroad",
      "logo": "1832/FECR",
      "tokens": [
        0,
        40,
        0
      ],
      "coordinates": "J14",
      "color": "yellow"
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
      "num": 4
    },
    {
      "name": "5",
      "distance": 5,
      "price": 450,
      "rusts_on": "12",
      "num": 3
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
      "offboard=revenue:yellow_30|brown_50;path=a:5,b:_0;path=a:0,b:_0": [
        "A7",
        "A21"
      ],
      "offboard=revenue:yellow_30|brown_50|gray_60;path=a:4,b:_0;path=a:5,b:_0": [
        "B2"
      ],
      "city=revenue:yellow_20|brown_30|gray_50;path=a:3,b:_0;path=a:2,b:_0;path=a:1,b:_0": [
        "N16"
      ]
    },
    "white": {
      "upgrade=cost:40,terrain:water": [
        "B4",
        "D8",
        "E13",
        "F14",
        "K15",
        "L16"
      ],
      "": [
        "B6",
        "B8",
        "B20",
        "B22",
        "C5",
        "C19",
        "C21",
        "C23",
        "D2",
        "D14",
        "D18",
        "D22",
        "E3",
        "E5",
        "E15",
        "E19",
        "F2",
        "F4",
        "F12",
        "F16",
        "F18",
        "G5",
        "G7",
        "G9",
        "G11",
        "G13",
        "H2",
        "H4",
        "H6",
        "H10",
        "H12",
        "H14",
        "I5",
        "I7",
        "I9",
        "I11",
        "I13",
        "J8",
        "K13",
        "L14"
      ],
      "upgrade=cost:60,terrain:mountain": [
        "B10",
        "B12",
        "C9",
        "D10",
        "E11"
      ],
      "upgrade=cost:70,terrain:mountain": [
        "B16",
        "C15"
      ],
      "town=revenue:0": [
        "B18",
        "E17",
        "E21",
        "G3",
        "H8",
        "J12"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:water": [
        "C3",
        "D4"
      ],
      "city=revenue:0": [
        "C7",
        "D16",
        "D20",
        "F6",
        "I3",
        "J10",
        "J14"
      ],
      "city=revenue:0;upgrade=cost:60,terrain:water": [
        "C11",
        "G17",
        "H16"
      ],
      "upgrade=cost:80,terrain:mountain": [
        "C13",
        "D12"
      ],
      "town=revenue:0;town=revenue:0": [
        "C17",
        "M15"
      ],
      "upgrade=cost:40,terrain:mountain": [
        "D6",
        "E7",
        "E9",
        "F8"
      ],
      "upgrade=cost:80,terrain:water": [
        "E23",
        "F20",
        "G19",
        "J6",
        "K9",
        "K11",
        "L12",
        "N12"
      ],
      "upgrade=cost:60,terrain:water": [
        "G15",
        "I15",
        "N14"
      ],
      "town=revenue:0;upgrade=cost:80,terrain:water": [
        "J4"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:water": [
        "M13"
      ]
    },
    "gray": {
      "town=revenue:yellow_40|brown_60;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0": [
        "B14"
      ],
      "city=revenue:yellow_20|brown_40|gray_50;path=a:0,b:_0;path=a:_0,b:1": [
        "B24"
      ],
      "path=a:4,b:5;border=edge:5": [
        "I1"
      ],
      "city=revenue:yellow_20|brown_30|gray_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:2": [
        "J2"
      ],
      "path=a:0,b:2": [
        "M17"
      ]
    },
    "yellow": {
      "city=revenue:20;city=revenue:20;city=revenue:20;path=a:2,b:_0;path=a:4,b:_0;path=a:0,b:_0;label=A": [
        "F10"
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
      "train_limit": 2,
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
      "name": "8",
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
      "name": "10",
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
      "name": "12",
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
