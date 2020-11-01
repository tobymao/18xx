# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1836jr
        JSON = <<-'DATA'
{
  "filename": "1836_jr",
  "modulename": "1836jr",
  "currencyFormatStr": "F%d",
  "bankCash": 6000,
  "certLimit": {
    "2": 20,
    "3": 13,
    "4": 10
  },
  "startingCash": {
    "2": 450,
    "3": 300,
    "4": 225
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A9": "Leeuwarden",
    "A13": "Hamburg",
    "B8": "Enkhuizen & Stavoren",
    "B10": "Groningen",
    "D6": "Amsterdam",
    "E5": "Rotterdam & Den Haag",
    "E7": "Utrecht",
    "E11": "Arnhem & Nijmegen",
    "F4": "Hoek van Holland",
    "F10": "Eindhoven",
    "G7": "Antwerp",
    "H2": "Bruges",
    "H4": "Gand",
    "H6": "Brussels",
    "H10": "Maastricht & Liège",
    "I3": "Lille",
    "I9": "Namur",
    "J6": "Charleroi",
    "J8": "Hainaut Coalfields",
    "E3": "Harwich",
    "G1": "Dover",
    "J2": "Paris",
    "E13": "Dortmund",
    "H12": "Cologne",
    "K11": "Arlon & Luxembourg",
    "K13": "Strasbourg"
  },
  "tiles": {
    "2": 1,
    "3": 3,
    "4": 3,
    "5": 2,
    "6": 2,
    "7": 7,
    "8": 13,
    "9": 13,
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
    "56": 1,
    "57": 4,
    "58": 3,
    "59": 2,
    "63": 4,
    "64": 1,
    "65": 1,
    "66": 1,
    "67": 1,
    "68": 1,
    "70": 1,
    "120": 1,
    "121": 2,
    "122": 1,
    "123": 1,
    "124": 1,
    "125": {
      "count": 4,
      "color": "brown",
      "code": "city=revenue:40,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=L"
    },
    "126": 1,
    "127": 1
  },
  "market": [
    [
      "70",
      "75",
      "80",
      "90",
      "100p",
      "110",
      "125",
      "150",
      "175",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325",
      "350",
      "375",
      "400",
      "425",
      "450"
    ],
    [
      "65",
      "70",
      "75",
      "80",
      "90p",
      "100",
      "110",
      "125",
      "150",
      "175",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325",
      "350",
      "375",
      "400",
      "425"
    ],
    [
      "60",
      "65",
      "70",
      "75",
      "80p",
      "90",
      "100",
      "110",
      "125",
      "150",
      "175",
      "200",
      "225",
      "250",
      "275"
    ],
    [
      "55",
      "60",
      "65",
      "70",
      "75p",
      "80",
      "90",
      "100",
      "110",
      "125",
      "150",
      "175",
      "200"
    ],
    [
      "50y",
      "55",
      "60",
      "65",
      "70p",
      "75",
      "80",
      "90",
      "100",
      "110",
      "125"
    ],
    [
      "45y",
      "50y",
      "55",
      "60",
      "65p",
      "70",
      "75",
      "80",
      "90"
    ],
    [
      "40o",
      "45y",
      "50y",
      "55",
      "60",
      "65",
      "70"
    ],
    [
      "35o",
      "40o",
      "45y",
      "50y",
      "55",
      "60"
    ],
    [
      "30o",
      "35o",
      "40o",
      "45y",
      "50y"
    ],
    [
      "0",
      "30o",
      "35o",
      "40o",
      "45y"
    ],
    [
      "0",
      "0",
      "30o",
      "35o",
      "40o"
    ]
  ],
  "companies": [
    {
      "name": "Amsterdam Canal Company",
      "value": 20,
      "revenue": 5,
      "desc": "No special ability. Blocks hex D6 while owned by player."
    },
    {
      "name": "Enkhuizen-Stavoren Ferry",
      "value": 40,
      "revenue": 10,
      "desc": "Owning corporation may place a free tile on the E-SF hex B8 (the IJsselmeer Causeway) free of cost, in addition to its own tile placement. Blocks hex B8 while owned by player."
    },
    {
      "name": "Charbonnages du Hainaut",
      "value": 50,
      "revenue": 10,
      "desc": "Owning corporation may place a tile and station token in the CdH hex J8 for only the F60 cost of the mountain. Blocks hex J8 while owned by player."
    },
    {
      "name": "Régie des Postes",
      "value": 70,
      "revenue": 15,
      "desc": "Owning corporation may place the +20 token on any city or town. The value of that location is increased by F20 for each and every time that corporation’s trains visit it. Once placed, the token cannot be moved."
    },
    {
      "name": "Régie des Postes",
      "value": 70,
      "revenue": 15,
      "desc": "At any time during its operating round, the owning corporation may place the +20 token on any city or town. The value of that location is increased by F20 for each and every time that corporation’s trains visit it. Once placed, the token cannot be moved. Placing the token closes this private company. The token is removed with the purchase of the first 6 Train."
    }
  ],
  "corporations": [
    {
      "sym": "B",
      "name": "Chemins de Fer de L'État Belge",
      "logo": "1836_jr/B",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "H6",
      "color": "black"
    },
    {
      "sym": "GCL",
      "name": "Grande Compagnie du Luxembourg",
      "logo": "1836_jr/GCL",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "I9",
      "color": "green"
    },
    {
      "sym": "Nord",
      "name": "Chemin de Fer du Nord",
      "logo": "1836_jr/Nord",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "I3",
      "color": "blue"
    },
    {
      "sym": "NBDS",
      "name": "Noord-Brabantsch-Duitsche Spoorweg-Maatschappij",
      "logo": "1836_jr/NBDS",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "E11",
      "color": "yellow"
    },
    {
      "sym": "HSM",
      "name": "Hollandsche IJzeren Spoorweg Maatschappij",
      "logo": "1836_jr/HSM",
      "tokens": [
        0,
        40
      ],
      "coordinates": "D6",
      "color": "orange"
    },
    {
      "sym": "NFL",
      "name": "Noord-Friesche Locaal",
      "logo": "1836_jr/NFL",
      "tokens": [
        0,
        40
      ],
      "coordinates": "A9",
      "color": "brightGreen"
    },
    {
      "sym": "SS",
      "name": "Maatschappij tot Exploitie van de Staats-Spoorwegen",
      "logo": "1836_jr/SS",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "color": "red"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 5
    },
    {
      "name": "3",
      "distance": 3,
      "price": 225,
      "rusts_on": "6",
      "num": 4
    },
    {
      "name": "4",
      "distance": 4,
      "price": 350,
      "rusts_on": "8",
      "num": 3
    },
    {
      "name": "5",
      "distance": 5,
      "price": 550,
      "num": 2
    },
    {
      "name": "6",
      "distance": 6,
      "price": 700,
      "num": 2
    },
    {
      "name": "8",
      "distance": 8,
      "price": 1000,
      "num": 5,
      "discount": {
        "4": 350,
        "5": 350,
        "6": 350
      }
    }
  ],
  "hexes": {
    "gray": {
      "city=revenue:10;path=a:0,b:_0;path=a:_0,b:5": [
        "A9"
      ]
    },
    "white": {
      "": [
        "A11",
        "B12",
        "C7",
        "C9",
        "C11",
        "D12",
        "E9",
        "G3",
        "G5",
        "H8",
        "I5",
        "I7",
        "K5",
        "J4"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:80,terrain:water": [
        "B8"
      ],
      "city=revenue:0": [
        "B10",
        "E7",
        "G7",
        "H4",
        "J6"
      ],
      "upgrade=cost:40,terrain:water": [
        "D8",
        "D10",
        "F8",
        "G9",
        "G11"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:water": [
        "F4"
      ],
      "upgrade=cost:80,terrain:water": [
        "F6"
      ],
      "town=revenue:0": [
        "F10",
        "H2"
      ],
      "upgrade=cost:60,terrain:mountain": [
        "I11",
        "J10",
        "J12",
        "K7",
        "K9"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:water": [
        "I9"
      ],
      "city=revenue:0;upgrade=cost:60,terrain:mountain": [
        "J8"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:60,terrain:mountain": [
        "K11"
      ]
    },
    "red": {
      "offboard=revenue:yellow_40|brown_70;path=a:1,b:_0;path=a:0,b:_0": [
        "A13"
      ],
      "offboard=revenue:yellow_30|brown_50;path=a:1,b:_0": [
        "E13",
        "H12"
      ],
      "offboard=revenue:yellow_40|brown_70;path=a:1,b:_0;path=a:2,b:_0": [
        "K13"
      ]
    },
    "yellow": {
      "city=revenue:40;path=a:0,b:_0;path=a:_0,b:5;label=T;upgrade=cost:40,terrain:water": [
        "D6"
      ],
      "city=revenue:0;city=revenue:0;label=OO;label=H": [
        "E5"
      ],
      "city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:water": [
        "E11",
        "H10"
      ],
      "city=revenue:30;path=a:1,b:_0;path=a:_0,b:3;label=L": [
        "H6"
      ],
      "city=revenue:30;path=a:0,b:_0;path=a:_0,b:4;label=B": [
        "I3"
      ]
    },
    "blue": {
      "offboard=revenue:yellow_+20|brown_+30;path=a:4,b:_0;path=a:5,b:_0": [
        "E3",
        "G1"
      ]
    },
    "land": {
      "offboard=revenue:yellow_+20|brown_+30;path=a:3,b:_0;path=a:4,b:_0": [
        "J2"
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
