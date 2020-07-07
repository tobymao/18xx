# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1817
        JSON = <<-'DATA'
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
  "capitalization": "incremental",
  "layout": "pointy",
  "mustSellInBlocks": false,
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
  "companies": [
    {
       "name" : "Pittsburgh Steel Mill",
       "value" : 40,
       "revenue" : 0,
       "desc" : "Owning corp may place special Pittsburgh yellow tile during tile-laying, regardless of connectivity.  The hex is not reserved, and the power is lost if another company builds there first.",
       "sym" : "PSM"
    },
    {
      "name" : "Mountain Engineers",
      "value" : 40,
      "revenue" : 0,
      "desc" : "Owning company receives $20 after laying a yellow tile in a mountain hex.  Any fees must be paid first.",
      "sym" : "ME"
    },
    {
      "name" : "Ohio Bridge Company",
      "value" : 40,
      "revenue" : 0,
      "desc" : "Comes with one $10 bridge token that may be placed by the owning corp in Louisville, Cincinnati, or Charleston, max one token per city, regardless of connectivity..  Allows owning corp to skip $10 river fee when placing yellow tiles.",
      "sym" : "OBC"
    },
    {
      "name" : "Union Bridge Company",
      "value" : 80,
      "revenue" : 0,
      "desc" : "Comes with two $10 bridge token that may be placed by the owning corp in Louisville, Cincinnati, or Charleston, max one token per city, regardless of connectivity..  Allows owning corp to skip $10 river fee when placing yellow tiles.",
      "sym" : "UBC"
    },
    {
      "name" : "Train Station",
      "value" : 80,
      "revenue" : 0,
      "desc" : "Provides an additional station marker for the owning corp, awarded at time of purchase",
      "sym" : "TS"
    },
    {
      "name" : "Minor Coal Mine",
      "value" : 30,
      "revenue" : 0,
      "desc" : "Comes with one coal mine marker.  When placing a yellow tile in a mountain hex, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra.  May not start or end a route at a coal mine.",
      "sym" : "MINC"
    },
    {
      "name" : "Coal Mine",
      "value" : 60,
      "revenue" : 0,
      "desc" : "Comes with two coal mine markers.  When placing a yellow tile in a mountain hex, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra.  May not start or end a route at a coal mine.",
      "sym" : "CM"
    },
    {
      "name" : "Major Coal Mine",
      "value" : 90,
      "revenue" : 0,
      "desc" : "Comes with three coal mine markers.  When placing a yellow tile in a mountain hex, can place token to avoid $15 terrain fee.  Marked yellow hexes cannot be upgraded.  Hexes pay $10 extra.  May not start or end a route at a coal mine.",
      "sym" : "MAJC"
    },
    {
      "name" : "Minor Mail Contract",
      "value" : 60,
      "revenue" : 0,
      "desc" : "Pays owning corp $10 at the start of each operating round, as long as the company has at least one train.",
      "sym" : "MINM"
    },
    {
      "name" : "Mail Contract",
      "value" : 90,
      "revenue" : 0,
      "desc" : "Pays owning corp $15 at the start of each operating round, as long as the company has at least one train.",
      "sym" : "MAIL"
    },
    {
      "name" : "Major Mail Contract",
      "value" : 120,
      "revenue" : 0,
      "desc" : "Pays owning corp $20 at the start of each operating round, as long as the company has at least one train.",
      "sym" : "MAJM"
    }
  ],
  "corporations": [
    {
      "float_percent": 20,
      "sym": "A&S",
      "name": "Alton & Southern Railway",
      "logo": "1817/AS",
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
      "logo": "1817/AA",
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
      "logo": "1817/Belt",
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
      "logo": "1817/Bess",
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
      "logo": "1817/BA",
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
      "logo": "1817/DLW",
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
      "logo": "1817/J",
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
      "logo": "1817/GT",
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
      "logo": "1817/H",
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
      "logo": "1817/ME",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "yellow",
      "text_color": "black"
    },
    {
      "float_percent": 20,
      "sym": "NYOW",
      "name": "New York, Ontaria and Western Railway",
      "logo": "1817/NYOW",
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
      "logo": "1817/NYSW",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "float_percent": 20,
      "sym": "PSNR",
      "name": "Pittsburgh, Shawmut and Northern Railroad",
      "logo": "1817/PSNR",
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
      "name": "Pittsburgh and Lake Erie Railroad",
      "logo": "1817/PLE",
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
      "logo": "1817/PW",
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
      "name": "Rutland Railroad",
      "logo": "1817/R",
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
      "logo": "1817/SR",
      "tokens": [
        0,
        0,
        0,
        0
      ],
      "color": "natural",
      "text_color": "black"
    },
    {
      "float_percent": 20,
      "sym": "UR",
      "name": "Union Railroad",
      "logo": "1817/UR",
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
      "logo": "1817/WT",
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
      "logo": "1817/WC",
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
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:5,b:_0;path=a:0,b:_0": [
        "A20"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0": [
        "A28"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:4,b:_0;path=a:5,b:_0": [
        "D1"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "H1"
      ],
      "offboard=revenue:yellow_20|green_30|brown_50|gray_60;path=a:2,b:_0;path=a:3,b:_0": [
        "J7",
        "J15"
      ]
    },
    "white": {
      "city=revenue:0": [
        "B5",
        "B17",
        "C14",
        "C22",
        "F3",
        "F13",
        "F19",
        "I16"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:water": [
        "D7"
      ],
      "city=revenue:0;upgrade=cost:15,terrain:mountain": [
        "D19",
        "I12"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "G6",
        "H3",
        "H9"
      ],
      "upgrade=cost:15,terrain:mountain": [
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
      "upgrade=cost:10,terrain:water": [
        "D13",
        "E12",
        "F11",
        "G4",
        "G10",
        "H7"
      ],
      "upgrade=cost:20,terrain:water": [
        "B9",
        "B27",
        "D25",
        "D27",
        "G20",
        "H17"
      ],
      "": [
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
      "town=revenue:yellow_20|green_30|brown_40;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "B13"
      ],
      "city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:5,b:_0;path=a:0,b:_0": [
        "D9"
      ],
      "junction;path=a:4,b:_0;path=a:3,b:_0;path=a:5,b:_0": [
        "F1"
      ]
    },
    "yellow": {
      "city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B;upgrade=cost:20,terrain:water": [
        "C8"
      ],
      "city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=B": [
        "C26"
      ],
      "city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:0,b:_0;label=NY;upgrade=cost:20,terrain:water": [
        "E22"
      ],
      "city=revenue:30;path=a:4,b:_0;path=a:0,b:_0;label=B": [
        "G18"
      ]
    },
    "blue": {
      "": [
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
      "on": "2+",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3",
      "on": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5",
      "on": "5",
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
      "on": "6",
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
      "on": "7",
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
      "on": "8",
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
