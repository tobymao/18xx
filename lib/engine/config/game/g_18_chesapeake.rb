# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18Chesapeake
        JSON = <<-'DATA'
{
  "filename": "18_chesapeake",
  "modulename": "18Chesapeake",
  "currencyFormatStr": "$%d",
  "bankCash": 8000,
  "certLimit": {
    "2": 20,
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
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "B2": "Pittsburgh",
    "A7": "Ohio",
    "B14": "West Virginia Coal",
    "B4": "Charleroi & Connellsville",
    "C5": "Green Spring",
    "C13": "Lynchburg",
    "D2": "Berlin",
    "D8": "Leesburg",
    "D12": "Charlottesville",
    "E3": "Hagerstown",
    "E11": "Fredericksburg",
    "F2": "Harrisburg",
    "F8": "Washington DC",
    "G3": "Columbia",
    "G13": "Richmond",
    "H4": "Strasburg",
    "H6": "Baltimore",
    "H14": "Norfolk",
    "I5": "Wilmington",
    "I9": "Delmarva Peninsula",
    "J2": "Allentown",
    "J4": "Philadelphia",
    "J6": "Camden",
    "K1": "Easton",
    "K3": "Trenton & Amboy",
    "K5": "Burlington & Princeton",
    "L2": "New York"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 2,
    "4": 2,
    "7": 20,
    "8": 20,
    "9": 20,
    "14": 5,
    "15": 6,
    "16": 1,
    "19": 1,
    "20": 1,
    "23": 3,
    "24": 3,
    "25": 2,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "39": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "43": 2,
    "44": 1,
    "45": 1,
    "46": 1,
    "47": 2,
    "55": 1,
    "56": 1,
    "57": 7,
    "58": 2,
    "69": 1,
    "70": 1,
    "611": 5,
    "915": 1,
    "X1": {
      "count": 1,
      "color": "yellow",
      "code": "c=r:30;p=a:0,b:_0;p=a:4,b:_0;l=DC"
    },
    "X2": {
      "count": 1,
      "color": "green",
      "code": "c=r:40,s:2;p=a:0,b:_0;p=a:2,b:_0;p=a:1,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=DC"
    },
    "X3": {
      "count": 1,
      "color": "green",
      "code": "c=r:40;c=r:40;p=a:0,b:_0;p=a:_0,b:2;p=a:3,b:_1;p=a:_1,b:5;l=OO"
    },
    "X4": {
      "count": 1,
      "color": "green",
      "code": "c=r:40;c=r:40;p=a:0,b:_0;p=a:_0,b:1;p=a:2,b:_1;p=a:_1,b:3;l=OO"
    },
    "X5": {
      "count": 1,
      "color": "green",
      "code": "c=r:40;c=r:40;p=a:3,b:_0;p=a:_0,b:5;p=a:0,b:_1;p=a:_1,b:4;l=OO"
    },
    "X6": {
      "count": 1,
      "color": "brown",
      "code": "c=r:70,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=DC"
    },
    "X7": {
      "count": 2,
      "color": "brown",
      "code": "c=r:50,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:5,b:_0;p=a:4,b:_0;l=OO"
    },
    "X8": {
      "count": 1,
      "color": "gray",
      "code": "c=r:100,s:4;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=DC"
    },
    "X9": {
      "count": 1,
      "color": "gray",
      "code": "c=r:70,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=OO"
    }
  },
  "market": [
    [
      "80",
      "85",
      "90",
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
      "350",
      "375"
    ],
    [
      "75",
      "80",
      "85",
      "90",
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
    ],
    [
      "70",
      "75",
      "80",
      "85",
      "95p",
      "105",
      "115",
      "130",
      "145",
      "160",
      "180",
      "200"
    ],
    [
      "65",
      "70",
      "75",
      "80p",
      "85",
      "95",
      "105",
      "115",
      "130",
      "145"
    ],
    [
      "60",
      "65",
      "70p",
      "75",
      "80",
      "85",
      "95",
      "105"
    ],
    [
      "55y",
      "60",
      "65",
      "70",
      "75",
      "80"
    ],
    [
      "50y",
      "55y",
      "60",
      "65"
    ],
    [
      "40y",
      "45y",
      "50y"
    ]
  ],
  "companies": [
    {
      "name": "Delaware and Raritan Canal",
      "value": 20,
      "revenue": 5,
      "desc": "No special ability. Blocks hex K3 while owned by a player.",
      "sym": "D&R",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "K3"
          ]
        }
      ]
    },
    {
      "name": "Columbia - Philadelphia Railroad",
      "value": 40,
      "revenue": 10,
      "desc": "Blocks hexes H2 and I3 while owned by a player. The owning corporation may lay two connected tiles in hexes H2 and I3. Only #8 and #9 tiles may be used. If any tiles are played in these hexes other than by using this ability, the ability is forfeit. These tiles may be placed even if the owning corporation does not have a route to the hexes. These tiles are laid during the tile laying step and are in addition to the corporation’s tile placement action.",
      "sym": "C-P",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "H2",
            "I3"
          ]
        },
        {
          "type": "tile_lay",
          "owner_type": "corporation",
          "hexes": [
            "H2",
            "I3"
          ],
          "tiles": [
            "8",
            "9"
          ],
          "when": "track",
          "count": 2
        }
      ]
    },
    {
      "name": "Baltimore and Susquehanna Railroad",
      "value": 50,
      "revenue": 10,
      "desc": "Blocks hexes F4 and G5 while owned by a player. The owning corporation may lay two connected tiles in hexes F4 and G5. Only #8 and #9 tiles may be used. If any tiles are played in these hexes other than by using this ability, the ability is forfeit. These tiles may be placed even if the owning corporation does not have a route to the hexes. These tiles are laid during the tile laying step and are in addition to the corporation’s tile placement action.",
      "sym": "B&S",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "F4",
            "G5"
          ]
        },
        {
          "type": "tile_lay",
          "owner_type": "corporation",
          "hexes": [
            "F4",
            "G5"
          ],
          "tiles": [
            "8",
            "9"
          ],
          "when": "track",
          "count": 2
        }
      ]
    },
    {
      "name": "Chesapeake and Ohio Canal",
      "value": 80,
      "revenue": 15,
      "desc": "Blocks hex D2 while owned by a player. The owning corporation may place a tile in hex D2. The corporation does not need to have a route to this hex. The tile placed counts as the corporation’s tile lay action and the corporation must pay the terrain cost. The corporation may then immediately place a station token free of charge.",
      "sym": "C&OC",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "D2"
          ]
        },
        {
          "type": "teleport",
          "owner_type": "corporation",
          "tiles": [
            "57"
          ],
          "hexes": [
            "D2"
          ]
        }
      ]
    },
    {
      "name": "Baltimore & Ohio Railroad",
      "value": 100,
      "revenue": 0,
      "desc": "During game setup place one share of the Baltimore & Ohio corporation with this certificate. The player purchasing this private immediately takes both the private company and the B&O share. This private company has no other special ability.",
      "abilities": [
        {
          "type": "share",
          "share": "B&O_1"
        }
      ]
    },
    {
      "name": "Cornelius Vanderbilt",
      "value": 200,
      "revenue": 30,
      "desc": "During game setup select a random president’s certificate and place it with this certificate. The player purchasing this private company takes both this certificate and the randomly selected president’s certificate. The player immediately sets the par value of the corporation. This private closes when the associated corporation buys its first train. It cannot be bought by a corporation.",
      "abilities": [
        {
          "type": "share",
          "share": "random_president"
        },
        {
          "type": "no_buy"
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 60,
      "sym": "PRR",
      "name": "Pennsylvania Railroad",
      "logo": "18_chesapeake/PRR",
      "tokens": [
        0,
        40,
        60,
        80
      ],
      "coordinates": "F2",
      "color": "green"
    },
    {
      "float_percent": 60,
      "sym": "PLE",
      "name": "Pittsburgh and Lake Erie Railroad",
      "logo": "18_chesapeake/PLE",
      "tokens": [
        0,
        40,
        60
      ],
      "coordinates": "A3",
      "color": "black"
    },
    {
      "float_percent": 60,
      "sym": "SRR",
      "name": "Strasburg Rail Road",
      "logo": "18_chesapeake/SRR",
      "tokens": [
        0,
        40
      ],
      "coordinates": "H4",
      "color": "red"
    },
    {
      "float_percent": 60,
      "sym": "B&O",
      "name": "Baltimore & Ohio Railroad",
      "logo": "18_chesapeake/BO",
      "tokens": [
        0,
        40,
        60
      ],
      "coordinates": "H6",
      "color": "blue"
    },
    {
      "float_percent": 60,
      "sym": "C&O",
      "name": "Chesapeake & Ohio Railroad",
      "logo": "18_chesapeake/CO",
      "tokens": [
        0,
        40,
        60,
        80
      ],
      "coordinates": "G13",
      "color": "lightBlue",
      "text_color": "black"
    },
    {
      "float_percent": 60,
      "sym": "LV",
      "name": "Lehigh Valley Railroad",
      "logo": "18_chesapeake/LV",
      "tokens": [
        0,
        40
      ],
      "coordinates": "J2",
      "color": "yellow",
      "text_color": "black"
    },
    {
      "float_percent": 60,
      "sym": "C&A",
      "name": "Camden & Amboy Railroad",
      "logo": "18_chesapeake/CA",
      "tokens": [
        0,
        40
      ],
      "coordinates": "J6",
      "color": "orange"
    },
    {
      "float_percent": 60,
      "sym": "N&W",
      "name": "Norfolk & Western Railway",
      "logo": "18_chesapeake/NW",
      "tokens": [
        0,
        40,
        60
      ],
      "coordinates": "C13",
      "color": "brown"
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
        "C3",
        "C7",
        "C9",
        "C11",
        "E7",
        "E9",
        "E13",
        "F6",
        "F12",
        "G7",
        "I7",
        "J8",
        "J10",
        "L4",
        "F4",
        "G5",
        "H2",
        "I3"
      ],
      "u=c:80,t:mountain": [
        "B12",
        "D4",
        "D6",
        "D10",
        "E5"
      ],
      "u=c:40,t:water": [
        "F10",
        "G9",
        "G11",
        "H12"
      ],
      "t=r:0;t=r:0": [
        "B4",
        "K3",
        "K5"
      ],
      "city": [
        "C5",
        "D12",
        "E3",
        "F2",
        "G13",
        "J2"
      ],
      "c=r:0;u=c:80,t:mountain": [
        "C13",
        "D2",
        "D8"
      ],
      "town": [
        "E11"
      ],
      "c=r:0;l=DC": [
        "F8"
      ],
      "t=r:0;u=c:40,t:water": [
        "G3",
        "I5"
      ],
      "c=r:0;u=c:40,t:water": [
        "H4",
        "J6"
      ]
    },
    "red": {
      "c=r:yellow_40|green_50|brown_60|gray_80,h:1,g:Pittsburgh;p=a:5,b:_0;b=e:4": [
        "A3"
      ],
      "o=r:yellow_40|green_50|brown_60|gray_80,g:Pittsburgh;p=a:0,b:_0;b=e:1": [
        "B2"
      ],
      "o=r:yellow_40|green_60|brown_80|gray_100;p=a:4,b:_0;p=a:5,b:_0": [
        "A7"
      ],
      "o=r:yellow_40|green_50|brown_60|gray_80,h:1,g:West Virginia Coal;p=a:4,b:_0;b=e:5": [
        "A13"
      ],
      "o=r:yellow_40|green_50|brown_60|gray_80,g:West Virginia Coal;p=a:3,b:_0;p=a:4,b:_0;b=e:2": [
        "B14"
      ],
      "o=r:yellow_30|green_40|brown_50|gray_60;p=a:2,b:_0": [
        "H14"
      ],
      "o=r:yellow_40|green_60|brown_80|gray_100;p=a:0,b:_0;p=a:1,b:_0": [
        "L2"
      ]
    },
    "gray": {
      "p=a:1,b:5": [
        "E1"
      ],
      "p=a:3,b:4": [
        "F14"
      ],
      "p=a:1,b:5;p=a:0,b:1": [
        "G1"
      ],
      "t=r:30;p=a:3,b:_0;p=a:_0,b:5": [
        "I9"
      ],
      "t=r:30;p=a:0,b:_0;p=a:_0,b:1": [
        "K1"
      ],
      "p=a:2,b:3": [
        "K7"
      ]
    },
    "yellow": {
      "c=r:30;c=r:30;p=a:1,b:_0;p=a:4,b:_1;l=OO;u=c:40,t:water": [
        "H6"
      ],
      "c=r:30;c=r:30;p=a:0,b:_0;p=a:3,b:_1;l=OO": [
        "J4"
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
