# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18EU
        JSON = <<-'DATA'
{
  "filename": "18_eu",
  "modulename": "18EU",
  "currencyFormatStr": "£%d",
  "bankCash": 12000,
  "certLimit": {
    "2": 28,
    "3": 20,
    "4": 16,
    "5": 13,
    "6": 11
  },
  "startingCash": {
    "2": 750,
    "3": 450,
    "4": 350,
    "5": 300,
    "6": 250
  },
  "capitalization": "incremental",
  "layout": "flat",
  "mustSellInBlocks": true,
  "locationNames": {
    "N17": "Bucharest",
    "N5": "Warsaw",
    "A6": "London",
    "G2": "Hamburg",
    "G22": "Rome",
    "B17": "Lyon",
    "B19": "Marseille",
    "C8": "Brussels",
    "D3": "Amsterdam",
    "D7": "Cologne",
    "D13": "Strausburg",
    "D19": "Turin",
    "E6": "Dortmund",
    "E18": "Milan",
    "E20": "Genoa",
    "F9": "Frankfurt",
    "G12": "Munich",
    "H19": "Venice",
    "I18": "Trieste",
    "J7": "Dresden",
    "J11": "Prague",
    "M16": "Budapest",
    "B7": "Lille",
    "B13": "Dijon",
    "C4": "Rotterdam",
    "C6": "Antwerp",
    "C16": "Geneva",
    "D5": "Utrecht",
    "D15": "Basil",
    "E12": "Stuttgart",
    "F3": "Bremen",
    "F11": "Augsburg",
    "F21": "Florence",
    "G6": "Hannover",
    "G10": "Nuremberg",
    "G20": "Bologne",
    "H7": "Magdeburg",
    "I8": "Leipzig",
    "K4": "Stettin",
    "K12": "Brunn",
    "L5": "Thorn",
    "C20": "Nice",
    "E14": "Zürich",
    "H15": "Innsbruck",
    "I14": "Salzburg",
    "L15": "Pressburg",
    "M10": "Krakau"
  },
  "tiles": {
    "3": 8,
    "4": 10,
    "7": 4,
    "8": 15,
    "9": 15,
    "14": 4,
    "15": 4,
    "57": 8,
    "58": 14,
    "80": 4,
    "81": 4,
    "82": 4,
    "83": 4,
    "141": 5,
    "142": 4,
    "143": 2,
    "144": 2,
    "145": 4,
    "146": 5,
    "147": 4,
    "201": 7,
    "202": 9,
    "513": 5,
    "544": 3,
    "545": 3,
    "546": 3,
    "576": 4,
    "577": 4,
    "578": 3,
    "579": 3,
    "580": 1,
    "581": 2,
    "582": 9,
    "583": 1,
    "584": 2,
    "611": 8
  },
  "market": [
    [
      "82",
      "90",
      "100",
      "110",
      "122",
      "135",
      "150",
      "165",
      "180",
      "200",
      "225",
      "245",
      "270",
      "300",
      "330",
      "360",
      "400"
    ],
    [
      "75",
      "82",
      "90",
      "100",
      "110",
      "122",
      "135",
      "150",
      "165",
      "180",
      "200",
      "225",
      "245",
      "270"
    ],
    [
      "70",
      "75",
      "82",
      "90",
      "100p",
      "110",
      "122",
      "135",
      "150",
      "165",
      "180"
    ],
    [
      "65",
      "70",
      "75",
      "82p",
      "90p",
      "100",
      "110",
      "122"
    ],
    [
      "60",
      "65",
      "70p",
      "75p",
      "82",
      "90"
    ],
    [
      "50",
      "60",
      "65",
      "70",
      "75"
    ],
    [
      "40",
      "50",
      "60",
      "65"
    ]
  ],
  "companies": [

  ],
  "corporations": [
    {
      "float_percent": 50,
      "sym": "BNR",
      "name": "Belgian National Railways",
      "logo": "18_eu/BNR",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "#ffcb05",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "DR",
      "name": "Dutch Railways",
      "logo": "18_eu/DR",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "#fff200",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "FS",
      "name": "Italian State Railways",
      "logo": "18_eu/FS",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "#00a651"
    },
    {
      "float_percent": 50,
      "sym": "RBSR",
      "name": "Royal Bavarian State Railroad",
      "logo": "18_eu/RBSR",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "#8ed8f8",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "RPR",
      "name": "Royal Prussian Railway",
      "logo": "18_eu/RPR",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "#00a4e4"
    },
    {
      "float_percent": 50,
      "sym": "AIRS",
      "name": "Austrian Imperial Royal State",
      "logo": "18_eu/AIRS",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "#fffcd5",
      "text_color": "black"
    },
    {
      "float_percent": 50,
      "sym": "SNCF",
      "name": "SNCF",
      "logo": "18_eu/SNCF",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "#ed1c24"
    },
    {
      "float_percent": 50,
      "sym": "GSR",
      "name": "German State Railways",
      "logo": "18_eu/GSR",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "#231f20"
    },
    {
      "sym": "1",
      "name": "Chemin de Fer du Nord",
      "logo": "18_eu/1",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "2",
      "name": "État Belge",
      "logo": "18_eu/2",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "3",
      "name": "Paris-Lyon-Méditerranée",
      "logo": "18_eu/3",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "4",
      "name": "Leipzig-Dresdner-Bahn",
      "logo": "18_eu/4",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "5",
      "name": "Ferrovia Adriatica",
      "logo": "18_eu/5",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "6",
      "name": "Kaiser-Ferdinand-Nordbahn",
      "logo": "18_eu/6",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "7",
      "name": "Berlin-Potsdamer-Bahn",
      "logo": "18_eu/7",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "8",
      "name": "Ungarische Staatsbahn",
      "logo": "18_eu/8",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "9",
      "name": "Berlin-Stettiner-Bahn",
      "logo": "18_eu/9",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "10",
      "name": "Strade Ferrate Alta Italia",
      "logo": "18_eu/10",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "11",
      "name": "Südbahn",
      "logo": "18_eu/11",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "12",
      "name": "Hollandsche Maatschappij",
      "logo": "18_eu/12",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "13",
      "name": "Ludwigsbahn",
      "logo": "18_eu/13",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "14",
      "name": "Ligne Strasbourg-Bâle",
      "logo": "18_eu/14",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "15",
      "name": "Grand Central",
      "logo": "18_eu/15",
      "tokens": [
        0
      ],
      "color": "white",
      "text_color": "black"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": [
        {
          "nodes": [
            "city",
            "offboard",
            "town"
          ],
          "pay": 2,
          "visit": 2
        },
        {
          "nodes": [
            "town"
          ],
          "pay": 99,
          "visit": 99
        }
      ],
      "price": 100,
      "num": 15
    },
    {
      "name": "3",
      "distance": [
        {
          "nodes": [
            "city",
            "offboard",
            "town"
          ],
          "pay": 3,
          "visit": 3
        },
        {
          "nodes": [
            "town"
          ],
          "pay": 99,
          "visit": 99
        }
      ],
      "price": 200,
      "num": 5
    },
    {
      "name": "P",
      "distance": 99,
      "price": 100,
      "num": 5
    },
    {
      "name": "4",
      "distance": [
        {
          "nodes": [
            "city",
            "offboard",
            "town"
          ],
          "pay": 4,
          "visit": 4
        },
        {
          "nodes": [
            "town"
          ],
          "pay": 99,
          "visit": 99
        }
      ],
      "price": 300,
      "num": 4
    },
    {
      "name": "5",
      "distance": [
        {
          "nodes": [
            "city",
            "offboard",
            "town"
          ],
          "pay": 5,
          "visit": 5
        },
        {
          "nodes": [
            "town"
          ],
          "pay": 99,
          "visit": 99
        }
      ],
      "price": 500,
      "num": 3
    },
    {
      "name": "6",
      "distance": [
        {
          "nodes": [
            "city",
            "offboard",
            "town"
          ],
          "pay": 6,
          "visit": 6
        },
        {
          "nodes": [
            "town"
          ],
          "pay": 99,
          "visit": 99
        }
      ],
      "price": 600,
      "num": 2
    },
    {
      "name": "8",
      "distance": [
        {
          "nodes": [
            "city",
            "offboard",
            "town"
          ],
          "pay": 8,
          "visit": 8
        },
        {
          "nodes": [
            "town"
          ],
          "pay": 99,
          "visit": 99
        }
      ],
      "price": 800,
      "num": 99
    }
  ],
  "hexes": {
    "red": {
      "offboard=revenue:yellow_30|brown_50;path=a:2,b:_0": [
        "N17"
      ],
      "offboard=revenue:yellow_20|brown_30;path=a:1,b:_0": [
        "N5"
      ],
      "offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:5,b:_0": [
        "A6"
      ],
      "offboard=revenue:yellow_30|brown_50;path=a:1,b:_0;path=a:_0,b:5;path=a:0,b:_0;path=a:_0,b:5;path=a:0,b:_0;path=a:_0,b:1": [
        "G2"
      ],
      "offboard=revenue:yellow_30|brown_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0": [
        "G22"
      ]
    },
    "blue": {
      "offboard=revenue:10;path=a:0,b:_0": [
        "D1"
      ],
      "offboard=revenue:10;path=a:3,b:_0": [
        "B21",
        "E22",
        "I20"
      ]
    },
    "yellow": {
      "city=revenue:40;city=revenue:40;path=a:4,b:_0;path=a:5,b:_1;label=P": [
        "A10"
      ],
      "city=revenue:30;city=revenue:30;path=a:4,b:_0;path=a:1,b:_1;label=B-V": [
        "J5"
      ],
      "city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=B-V": [
        "K14"
      ],
      "path=a:1,b:3;upgrade=cost:60,terrain:mountain": [
        "K16"
      ]
    },
    "white": {
      "city=revenue:0;label=Y": [
        "B17",
        "C8",
        "D3",
        "D13",
        "E18",
        "G12",
        "H19",
        "J7",
        "M16"
      ],
      "city=revenue:0": [
        "B19",
        "D7",
        "D19",
        "E6",
        "E20",
        "F9",
        "I18",
        "J11"
      ],
      "town=revenue:0": [
        "B7",
        "B13",
        "C4",
        "C6",
        "C16",
        "D5",
        "D15",
        "E12",
        "F3",
        "F11",
        "F21",
        "G6",
        "G10",
        "G20",
        "H7",
        "I8",
        "K4",
        "K12",
        "L5"
      ],
      "town=revenue:0;upgrade=cost:60,terrain:mountain": [
        "C20",
        "E14",
        "H15",
        "I14",
        "L15",
        "M10"
      ],
      "upgrade=cost:60,terrain:mountain": [
        "A14",
        "A16",
        "C10",
        "D9",
        "D11",
        "F15",
        "G16",
        "I10",
        "I12",
        "J9",
        "J13",
        "K8",
        "L9"
      ],
      "upgrade=cost:120,terrain:mountain": [
        "C18",
        "D17",
        "E16",
        "F17",
        "G18",
        "H17",
        "I16",
        "J15"
      ],
      "": [
        "A8",
        "A12",
        "A18",
        "A20",
        "B9",
        "B15",
        "C12",
        "C14",
        "D21",
        "E4",
        "E8",
        "E10",
        "F5",
        "F7",
        "F13",
        "G4",
        "G8",
        "G14",
        "H3",
        "H5",
        "H9",
        "H11",
        "H13",
        "H21",
        "I4",
        "J3",
        "J17",
        "J19",
        "K6",
        "K10",
        "K18",
        "L7",
        "L11",
        "L13",
        "L17",
        "M6",
        "M8",
        "M12",
        "M14",
        "B11",
        "F19",
        "I6"
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
