# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1817NA
        JSON = <<-'DATA'
{
  "filename": "1817_ na",
  "modulename": "1817NA",
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
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A8": "Dawson City",
    "B3": "Anchorage",
    "B7": "The Klondike",
    "B19": "Arctic",
    "C4": "Asia",
    "C10": "Hazelton",
    "D13": "Edmonton",
    "D17": "Winnipeg",
    "D23": "Quebec",
    "D27": "Europe",
    "E10": "Seattle",
    "F15": "Denver",
    "F21": "Toronto",
    "F23": " & ",
    "H9": "Hawaii",
    "H11": "Los Angeles",
    "H19": "New Orleans",
    "I14": "Guadalajara",
    "I16": "Mexico City",
    "I22": "Miami",
    "J19": "Belize",
    "K22": "South America"
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
      "code": "city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B"
    },
    "X30": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY"
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
      "sym": "A&S",
      "name": "Alton & Southern Railway",
      "logo": "1817_ na/AS",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "pink"
    },
    {
      "sym": "A&A",
      "name": "Arcade and Attica",
      "logo": "1817_ na/AA",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "gold"
    },
    {
      "sym": "Belt",
      "name": "Belt Railway of Chicago",
      "logo": "1817_ na/Belt",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "orange"
    },
    {
      "sym": "Bess",
      "name": "Bessemer and Lake Erie Railroad",
      "logo": "1817_ na/Bess",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "black"
    },
    {
      "sym": "B&A",
      "name": "Boston and Albany Railroad",
      "logo": "1817_ na/BA",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "red"
    },
    {
      "sym": "DL&W",
      "name": "Delaware, Lackawanna and Western Railroad",
      "logo": "1817_ na/DLW",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "brown"
    },
    {
      "sym": "J",
      "name": "Elgin, Joliet and Eastern Railway",
      "logo": "1817_ na/J",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "green"
    },
    {
      "sym": "GT",
      "name": "Grand Trunk Western Railroad",
      "logo": "1817_ na/GT",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "violet"
    },
    {
      "sym": "H",
      "name": "Housatonic Railroad",
      "logo": "1817_ na/H",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lightBlue"
    },
    {
      "sym": "ME",
      "name": "Morristown and Erie Railway",
      "logo": "1817_ na/ME",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "yellow"
    },
    {
      "sym": "NYOW",
      "name": "New York, Ontaria and Western Railway",
      "logo": "1817_ na/NYOW",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "turquoise"
    },
    {
      "sym": "NYSW",
      "name": "New York, Susquehanna and Western Railway",
      "logo": "1817_ na/NYSW",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "white"
    },
    {
      "sym": "PSNR",
      "name": "Pittsburg, Shawmut and Northern Railroad",
      "logo": "1817_ na/PSNR",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "brightGreen"
    },
    {
      "sym": "PLE",
      "name": "Pittsburg and Lake Erie Railroad",
      "logo": "1817_ na/PLE",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lime"
    },
    {
      "sym": "PW",
      "name": "Providence and Worcester Railroad",
      "logo": "1817_ na/PW",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lightBrown"
    },
    {
      "sym": "R",
      "name": "Rutland Railraod",
      "logo": "1817_ na/R",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "blue"
    },
    {
      "sym": "SR",
      "name": "Strasburg Railroad",
      "logo": "1817_ na/SR",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "natural"
    },
    {
      "sym": "UR",
      "name": "Union Railroad",
      "logo": "1817_ na/UR",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "navy"
    },
    {
      "sym": "WT",
      "name": "Warren & Trumbull Railroad",
      "logo": "1817_ na/WT",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "lavender"
    },
    {
      "sym": "WC",
      "name": "West Chester Railroad",
      "logo": "1817_ na/WC",
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
      "num": 16
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
    "white": {
      "path=a:5,b:_0;border=edge:1": [
        "A2"
      ],
      "upgrade=cost:15,terrain:mountain": [
        "A4",
        "B5",
        "B9",
        "B11",
        "D11",
        "E12",
        "E14",
        "F13",
        "G14",
        "G20",
        "H13",
        "J15"
      ],
      "": [
        "A6",
        "A10",
        "B13",
        "C8",
        "C12",
        "C14",
        "C16",
        "C18",
        "C24",
        "D19",
        "D21",
        "D25",
        "E18",
        "E20",
        "E22",
        "E24",
        "F11",
        "F19",
        "G10",
        "G12",
        "G16",
        "G22",
        "H15",
        "H17",
        "H21",
        "J17",
        "K18",
        "K20"
      ],
      "city=revenue:0;upgrade=cost:15,terrain:mountain": [
        "A8"
      ],
      "city=revenue:0": [
        "B3",
        "C10",
        "D23",
        "E10",
        "F15",
        "F21",
        "H11",
        "J19"
      ],
      "path=a:3,b:_0;border=edge:1": [
        "C2",
        "F9",
        "I10",
        "J13"
      ],
      "upgrade=cost:20,terrain:water": [
        "D9",
        "E26",
        "I20",
        "J21"
      ],
      "upgrade=cost:10,terrain:water": [
        "D15",
        "E16",
        "F17",
        "G18"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "H19"
      ],
      "path=a:2,b:_0;path=a:4,b:_0;border=edge:1": [
        "I12"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:water": [
        "I14"
      ]
    },
    "gray": {
      "town=revenue:yellow_70|green_10|brown_40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0": [
        "B7"
      ],
      "path=a:1,b:4": [
        "B15",
        "C20"
      ],
      "path=a:1,b:5": [
        "B17",
        "C22"
      ],
      "city=revenue:yellow_30|green_50|brown_60|gray_80;path=a:1,b:_0;path=a:_0,b:2;path=a:0,b:_0;path=a:_0,b:1": [
        "I22"
      ]
    },
    "red": {
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0": [
        "B19"
      ],
      "offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0": [
        "C4"
      ],
      "offboard=revenue:yellow_30|green_50|brown_60|gray_80;path=a:1,b:_0;path=a:0,b:_0": [
        "D27"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:3,b:_0;path=a:4,b:_0": [
        "H9"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:1,b:_0;path=a:2,b:_0": [
        "K22"
      ]
    },
    "yellow": {
      "city=revenue:30;path=a:2,b:_0;path=a:_0,b:4;label=B": [
        "D13"
      ],
      "city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:0,b:_0;label=NYC": [
        "F23"
      ],
      "city=revenue:30;path=a:1,b:_0;path=a:_0,b:5;label=B": [
        "I16"
      ]
    },
    "undefined": {
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "D17"
      ]
    },
    "blue": {
      "path=a:3,b:_0": [
        "I18"
      ]
    }
  },
  "phases": []
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
