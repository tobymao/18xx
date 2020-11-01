# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18Scan
        JSON = <<-'DATA'
{
  "filename": "18_scan",
  "modulename": "18Scan",
  "currencyFormatStr": "K%d",
  "bankCash": 6000,
  "certLimit": {
    "2": 18,
    "3": 12,
    "4": 9
  },
  "startingCash": {
    "2": 900,
    "3": 600,
    "4": 450
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A4": "Newcastle",
    "A18": "Narvik",
    "A20": "Kiruna",
    "B5": "Bergen",
    "B11": "Trondheim",
    "B19": "Gällivare",
    "C4": "Stavanger",
    "C12": "Östersund",
    "C18": "Luleå",
    "D5": "Kristiansand",
    "D7": "Oslo",
    "D15": "Umeå",
    "D19": "Oulu",
    "E4": "Århus",
    "E6": "Göteborg",
    "E10": "Gävle",
    "F1": "Kiel",
    "F3": "Copenhagen & Odense",
    "F7": "Norrköping",
    "F11": "Stockholm",
    "F13": "Turku",
    "F15": "Tampere",
    "G2": "Szczecin",
    "G4": "Malmö",
    "G14": "Helsinki",
    "G16": "Lahti",
    "H13": "Tallinn",
    "H17": "Vyborg"
  },
  "tiles": {
    "5": 12,
    "8": 8,
    "9": 8,
    "15": 6,
    "58": 7,
    "80": 3,
    "81": 3,
    "82": 3,
    "83": 3,
    "121": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:50,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=COP"
    },
    "141": 3,
    "142": 3,
    "143": 3,
    "144": 3,
    "145": 3,
    "146": 3,
    "147": 4,
    "544": 3,
    "545": 3,
    "546": 4,
    "582": 2,
    "584": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=COP"
    },
    "622": 3,
    "623": 1
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
      "220",
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
      "220",
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
    {
      "name": "Stockholm-Åbo Ferry Company",
      "value": 120,
      "revenue": 20,
      "desc": "Comes with a 10% share of Valtionrautatiet (VR). Allows up to two Companies to increase the value of a route that runs between Turku and Stockholm via the Ferry (G12) by K20. Tokens may be bought for K20 each during the Additional Token Placement step."
    },
    {
      "name": "Lapland Ore Line",
      "value": 150,
      "revenue": 25,
      "desc": "Comes with a 10% share of Sveriges & Norges Järnvägar (S&NJ). Allows a Company to increase the its earnings by K50, if the Company has a route that includes the Kiruna Iron Mines (A20). The bonus is only added once to the Company's earnings, even if two of the Company's trains run to Kiruna. The token may be bought for K50 during the Additional Token Placement step."
    },
    {
      "name": "Sjællandske Jernbaneselskab",
      "value": 180,
      "revenue": 35,
      "desc": "Comes with the president share (20%) of Danske Statsbaner (DSB). Allows a Company to lay (or upgrade) the yellow \"Copenhagen\" tile at no cost. The special power is exercised in the track-laying phase of the placing Company. The Private Company closes when the DSB buys its first train."
    },
    {
      "name": "Södra Stambanan",
      "value": 260,
      "revenue": 0,
      "desc": "Starts in Malmö (G4). Destination: Göteborg (E6). Starts with K260 in the treasury."
    },
    {
      "name": "Nordvästra Stambanan",
      "value": 220,
      "revenue": 0,
      "desc": "Starts in Stockholm (F11). Destination: Trondheim (B11). Starts with K220 in the treasury."
    },
    {
      "name": "Västra Stambanan",
      "value": 200,
      "revenue": 0,
      "desc": "Starts in Stockholm (F11). Destination: Oslo (D7). Starts with K200 in the treasury."
    }
  ],
  "corporations": [
    {
      "sym": "DSB",
      "name": "Danske Statsbaner",
      "logo": "18_scan/DSB",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "F3",
      "color": "red"
    },
    {
      "sym": "S&NJ",
      "name": "Sveriges & Norges Järnvägar",
      "logo": "18_scan/SNJ",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "B19",
      "color": "green"
    },
    {
      "sym": "NSB",
      "name": "Norges Statsbaner",
      "logo": "18_scan/NSB",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "D7",
      "color": "blue"
    },
    {
      "sym": "VR",
      "name": "Valtionrautatiet",
      "logo": "18_scan/VR",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "G14",
      "color": "cyan"
    },
    {
      "sym": "SJ",
      "name": "Statens Järnvägar",
      "logo": "18_scan/SJ",
      "tokens": [
        0,
        40,
        100,
        100,
        100,
        100
      ],
      "color": "yellow"
    },
    {
      "sym": "1",
      "name": "Södra Stambanan",
      "logo": "18_scan/1",
      "tokens": [
        0,
        40
      ],
      "coordinates": "G4",
      "color": "turquoise"
    },
    {
      "sym": "2",
      "name": "Nordvästra Stambanan",
      "logo": "18_scan/2",
      "tokens": [
        0,
        40
      ],
      "coordinates": "F11",
      "color": "turquoise"
    },
    {
      "sym": "3",
      "name": "Västra Stambanan",
      "logo": "18_scan/3",
      "tokens": [
        0,
        40
      ],
      "coordinates": "F11",
      "color": "turquoise"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 6
    },
    {
      "name": "1+1",
      "distance": 1,
      "price": 80,
      "rusts_on": "4",
      "num": 6
    },
    {
      "name": "3",
      "distance": 3,
      "price": 200,
      "rusts_on": "5",
      "num": 4
    },
    {
      "name": "2+2",
      "distance": 2,
      "price": 180,
      "rusts_on": "5",
      "num": 4
    },
    {
      "name": "4",
      "distance": 4,
      "price": 300,
      "rusts_on": "4D",
      "num": 3
    },
    {
      "name": "3+3",
      "distance": 3,
      "price": 280,
      "rusts_on": "4D",
      "num": 3
    },
    {
      "name": "5",
      "distance": 5,
      "price": 500,
      "num": 2
    },
    {
      "name": "4+4",
      "distance": 4,
      "price": 480,
      "num": 2
    },
    {
      "name": "5E",
      "distance": 5,
      "price": 600,
      "num": 2
    },
    {
      "name": "4D",
      "distance": 4,
      "price": 800,
      "num": 6
    }
  ],
  "hexes": {
    "red": {
      "city=revenue:yellow_20|green_30|brown_80;path=a:5,b:_0": [
        "A4"
      ],
      "town=revenue:yellow_10|green_50|brown_10;path=a:1,b:_0;path=a:0,b:_0": [
        "A20"
      ],
      "city=revenue:yellow_20|green_30|brown_50;path=a:3,b:_0;path=a:4,b:_0": [
        "F1"
      ],
      "city=revenue:yellow_10|green_30|brown_60;path=a:3,b:_0;path=a:4,b:_0": [
        "G2"
      ],
      "city=revenue:yellow_0|green_30|brown_60;path=a:3,b:_0": [
        "H13"
      ],
      "city=revenue:yellow_30|green_50|brown_80;path=a:2,b:_0": [
        "H17"
      ]
    },
    "undefined": {
      "city=revenue:0;upgrade=cost:60,terrain:mountain": [
        "A18",
        "B11"
      ],
      "city=revenue:0": [
        "B5",
        "B19",
        "C4",
        "D15",
        "E4",
        "E6",
        "F13",
        "F15"
      ],
      "town=revenue:0": [
        "C12",
        "C18",
        "D5",
        "D19",
        "E10",
        "F7",
        "G16"
      ],
      "city=revenue:0;label=Y": [
        "D7",
        "G14"
      ],
      "city=revenue:0;town=revenue:0;label=COP;upgrade=cost:40,terrain:water": [
        "F3"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:water": [
        "G4"
      ]
    },
    "yellow": {
      "city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;label=Y": [
        "F11"
      ]
    },
    "blue": {
      "path=a:2,b:3,track:narrow": [
        "G12"
      ]
    },
    "white": {
      "upgrade=cost:60,terrain:mountain": [
        "A6",
        "A8",
        "A10",
        "A14",
        "A16",
        "B7",
        "B9",
        "B13",
        "B15",
        "B17",
        "C6",
        "C8",
        "C10"
      ],
      "": [
        "C14",
        "C16",
        "D9",
        "D11",
        "D13",
        "D17",
        "E2",
        "E8",
        "E12",
        "E14",
        "E16",
        "E18",
        "F5",
        "F9",
        "F17",
        "G6",
        "G8"
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
      "name": "5E",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "4D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "5",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "5E",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "4D",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "2",
      "train_limit": 2,
      "tiles": [
        "yellow"
      ]
    },
    {
      "name": "3",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green"
      ]
    },
    {
      "name": "4",
      "train_limit": 1,
      "tiles": [
        "yellow",
        "green"
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
