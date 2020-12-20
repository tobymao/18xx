# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18CZ
        JSON = <<-'DATA'
{
  "filename": "18_cz",
  "modulename": "18CZ",
  "currencyFormatStr": "K%d",
  "bankCash": 12000,
  "certLimit": {
    "3": 21,
    "4": 16,
    "5": 13,
    "6": 11
  },
  "startingCash": {
    "3": 500,
    "4": 375,
    "5": 300,
    "6": 250
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "G15": "Jihlava",
    "D16": "Hradec Kralove",
    "B10": "Decin",
    "B12": "Liberec",
    "C23": "Opava",
    "E21": "Opava",
    "G23": "Hulin",
    "G11": "Tabor",
    "I11": "Ceske Budejovice",
    "F6": "Pilzen",
    "E9": "Kladno",
    "B8": "Teplice & Ustid nad Labem",
    "D26": "Frydland & Frydek",
    "C7": "Chomutov & Most",
    "E11": "Praha"
  },
  "tiles": { 
     "1": 1,
  "2": 1,
  "5": 3,
  "6": 4,
  "7": 4,
  "8": 9,
  "9": 12,
  "14": 3},
  "market": [
    [
      "Closed",
      "50",
      "60",
      "65",
      "70p",
      "80p",
      "90p",
      "100p",
      "110p",
      "120p",
      "135p",
      "150p",
      "165",
      "180",
      "200",
      "220",
      "245",
      "270",
      "300"
    ]
  ],
  "companies": [ {
    "sym": "P1",
    "name": "Melbourne & Hobson's Bay Railway Company",
    "value": 40,
    "discount": 10,
    "revenue": 5,
    "desc": "No special abilities."
  }],
  "corporations": [
    {
      "float_percent": 50,
      "sym": "SX",
      "name": "Saxonian",
      "logo": "18_cz/SX",
      "tokens": [
        0,
        40
      ],
      "coordinates": "A7",
      "color": "green"
    }
  ],
  "trains": [],
  "hexes": {
    "white": {
      "": [
        "A11",
        "B22",
        "B24",
        "C15",
        "D6",
        "D8",
        "D18",
        "D20",
        "D22",
        "E7",
        "E17",
        "E19",
        "E23",
        "E25",
        "F4",
        "F8",
        "F14",
        "F16",
        "F18",
        "F24",
        "G3",
        "G5",
        "G7",
        "G25",
        "H8",
        "H12",
        "H18",
        "H20",
        "H22",
        "H24",
        "I13",
        "I19",
        "I21",
        "J12"
      ],
      "upgrade=cost:40,terrain:mountain": [
        "B6",
        "C3",
        "A15",
        "B20",
        "C21",
        "I7"
      ],
      "upgrade=cost:20,terrain:mountain": [
        "A13",
        "D28",
        "E27",
        "E5",
        "F26",
        "H14",
        "G13"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:mountain": [
        "C5"
      ],
      "town=revenue:0;upgrade=cost:20,terrain:mountain": [
        "H6",
        "J10",
        "B16",
        "H16",
        "G17"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:mountain": [
        "G15"
      ],
      "upgrade=cost:10,terrain:water": [
        "D10",
        "D12",
        "D14",
        "C17",
        "G9",
        "H10"
      ],
      "town=revenue:0;upgrade=cost:10,terrain:water": [
        "F10",
        "C9",
        "C11"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "D16"
      ],
      "city=revenue:0": [
        "B10",
        "C23",
        "E21",
        "G23",
        "G11",
        "E9"
      ],
      "city=revenue:0;label=Y": [
        "B12",
        "I11",
        "F6"
      ],
      "town=revenue:0": [
        "E1",
        "E3",
        "C13",
        "F12",
        "C19",
        "G21",
        "C27"
      ],
      "town=revenue:0;town=revenue:0": [
        "E13",
        "F20",
        "B14"
      ],
      "city=revenue:20;city=revenue:20;label=P;upgrade=cost:10,terrain:water": [
        "E11"
      ],
      "city=revenue:0;label=SX": [
        "A7",
        "B4"
      ],
      "city=revenue:0;label=PR": [
        "A21",
        "B18"
      ],
      "city=revenue:0;label=BY": [
        "F2",
        "H4"
      ],
      "city=revenue:0;label=kk": [
        "J14",
        "I17"
      ],
      "city=revenue:0;label=Ug": [
        "G27",
        "I23"
      ]
    },
    "yellow": {
      "city=revenue:0;city=revenue:0;label=OO": [
        "B8",
        "D26",
        "C7"
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
      "status":[
         "can_buy_companies"
      ]
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
      "status":[
         "can_buy_companies"
      ]
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
      "operating_rounds": 3
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
      "name": "8",
      "on": "8",
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
