# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1830
        JSON = <<-DATA
{
  "filename": "1830",
  "modulename": "1830",
  "currencyFormatStr": "$%d",
  "bankCash": 12000,
  "certLimit": {
    "3": 20,
    "4": 16,
    "5": 13,
    "6": 11
  },
  "startingCash": {
    "3": 800,
    "4": 600,
    "5": 480,
    "6": 400
  },
  "locationNames": {
    "D2": "Lansing",
    "F2": "Chicago",
    "J2": "Gulf",
    "F4": "Toledo",
    "J14": "Washington",
    "F22": "Providence",
    "E5": "Detroit & Windsor",
    "D10": "Hamilton & Toronto",
    "F6": "Cleveland",
    "E7": "London",
    "A11": "Canadian West",
    "K13": "Deep South",
    "E11": "Dunkirk & Buffalo",
    "H12": "Altoona",
    "D14": "Rochester",
    "C15": "Kingston",
    "I15": "Baltimore",
    "K15": "Richmond",
    "B16": "Ottowa",
    "F16": "Scranton",
    "H18": "Philadelphia & Trenton",
    "A19": "Montreal",
    "E19": "Albany",
    "G19": "New York & Newark",
    "I19": "Atlantic City",
    "F24": "Mansfield",
    "B20": "Burlington",
    "E23": "Boston",
    "B24": "Maritime Provinces",
    "D4": "Flint",
    "F10": "Erie",
    "G7": "Akron & Canton",
    "G17": "Reading & Allentown",
    "F20": "New Haven & Hartford",
    "H4": "Columbus",
    "B10": "Barrie",
    "H10": "Pittsburgh",
    "H16": "Lancaster"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 2,
    "4": 2,
    "7": 4,
    "8": 8,
    "9": 7,
    "14": 3,
    "15": 2,
    "16": 1,
    "18": 1,
    "19": 1,
    "20": 1,
    "23": 3,
    "24": 3,
    "25": 1,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "39": 1,
    "40": 1,
    "41": 2,
    "42": 2,
    "43": 2,
    "44": 1,
    "45": 2,
    "46": 2,
    "47": 1,
    "53": 2,
    "54": 1,
    "55": 1,
    "56": 1,
    "57": 4,
    "58": 2,
    "59": 2,
    "61": 2,
    "62": 1,
    "63": 3,
    "64": 1,
    "65": 1,
    "66": 1,
    "67": 1,
    "68": 1,
    "69": 1,
    "70": 1
  },
  "market": [
    [
      "60y",
      "67",
      "71",
      "76",
      "82",
      "90",
      "100p",
      "112",
      "126",
      "142",
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
      "53y",
      "60y",
      "66",
      "70",
      "76",
      "82",
      "90p",
      "100",
      "112",
      "126",
      "142",
      "160",
      "180",
      "200",
      "220",
      "240",
      "260",
      "280",
      "300"
    ],
    [
      "46y",
      "55y",
      "60y",
      "65",
      "70",
      "76",
      "82p",
      "90",
      "100",
      "111",
      "125",
      "140",
      "155",
      "170",
      "185",
      "200"
    ],
    [
      "39o",
      "48y",
      "54y",
      "60y",
      "66",
      "71",
      "76p",
      "82",
      "90",
      "100",
      "110",
      "120",
      "130"
    ],
    [
      "32o",
      "41o",
      "48y",
      "55y",
      "62",
      "67",
      "71p",
      "76",
      "82",
      "90",
      "100"
    ],
    [
      "25b",
      "34o",
      "42o",
      "50y",
      "58y",
      "65",
      "67p",
      "71",
      "75",
      "80"
    ],
    [
      "18b",
      "27b",
      "36o",
      "45o",
      "54y",
      "63",
      "67",
      "69",
      "70"
    ],
    [
      "10b",
      "12b",
      "30b",
      "40o",
      "50y",
      "60y",
      "67",
      "68"
    ],
    [
      "",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y",
      "60y"
    ],
    [
      "",
      "",
      "10b",
      "20b",
      "30b",
      "40o",
      "50y"
    ],
    [
      "",
      "",
      "",
      "10b",
      "20b",
      "30b",
      "40o"
    ]
  ],
  "companies": [
    {
      "name": "Schuylkill Valley",
      "value": 20,
      "revenue": 5,
      "desc": "No special abilities."
    },
    {
      "name": "Champlain & St.Lawrence",
      "value": 40,
      "revenue": 10,
      "desc": "A corporation owning the C&StL may lay a tile on the C&StL's hex even if this hex is not connected to the corporations's railhead. This free tile placement is in addition to the corporation's normal tile placement."
    },
    {
      "name": "Delaware & Hudson",
      "value": 70,
      "revenue": 15,
      "desc": "A corporation owning the Delaware & Hudson may establish a railhead on the D&H hex by laying a station tile and a token. The station does not have to be connected to the remainder of the corporation's route. The tile laid is the owning corporation's one tile placement for the turn."
    },
    {
      "name": "Mohawk & Hudson",
      "value": 110,
      "revenue": 20,
      "desc": "A player owning the M&H may exhange it for a 10% share of the NYC if he does not already hold 60% of the NYC and there is NYC stock available in the Bank or the Pool. The exchange may be made during the player's turn of a stock round or between the turns of other players or corporations in either stock or operating rounds. This action closes the M&H."
    },
    {
      "name": "Camden & Amboy",
      "value": 160,
      "revenue": 25,
      "desc": "The initial purchaser of the C&A immediately receives a 10% share of PRR stock without further payment. This action does not close the C&A. The PRR corporation will not be running at this point, but the stock may be retained or sold subject to the ordinary rules of the game."
    },
    {
      "name": "Baltimore & Ohio",
      "value": 220,
      "revenue": 30,
      "desc": "The owner of the B&O private company immediately receives the President's certificate of the B&O without further payment. The B&O private company may not be sold to any corporation, and does not exchange hands if the owning player loses the Presidency of the B&O. When the B&O purchases its first train the private company is closed down."
    }
  ],
  "corporations": [
    {
      "float_percent": 60,
      "sym": "PRR",
      "name": "Pennsylvania Railroad",
      "logo": "1830/PRR",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "H12",
      "color": "green"
    },
    {
      "float_percent": 60,
      "sym": "NYC",
      "name": "New York Central Railroad",
      "logo": "1830/NYC",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "E19",
      "color": "black"
    },
    {
      "float_percent": 60,
      "sym": "CPR",
      "name": "Canadian Pacific Railroad",
      "logo": "1830/CPR",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "A19",
      "color": "red"
    },
    {
      "float_percent": 60,
      "sym": "B&O",
      "name": "Baltimore & Ohio Railroad",
      "logo": "1830/B&O",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "I15",
      "color": "blue"
    },
    {
      "float_percent": 60,
      "sym": "C&O",
      "name": "Chesapeake & Ohio Railroad",
      "logo": "1830/C&O",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "F6",
      "color": "lightBlue"
    },
    {
      "float_percent": 60,
      "sym": "ERIE",
      "name": "Erie Railroad",
      "logo": "1830/ERIE",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "E11",
      "color": "yellow"
    },
    {
      "float_percent": 60,
      "sym": "NYNH",
      "name": "New York, New Haven & Hartford Railroad",
      "logo": "1830/NYNH",
      "tokens": [
        0,
        40
      ],
      "coordinates": "G19",
      "color": "orange"
    },
    {
      "float_percent": 60,
      "sym": "B&M",
      "name": "Boston & Maine Railroad",
      "logo": "1830/B&M",
      "tokens": [
        0,
        40
      ],
      "coordinates": "E23",
      "color": "brightGreen"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": "4",
      "num": 6
    },
    {
      "name": "3",
      "distance": 3,
      "price": 180,
      "rusts_on": "6",
      "num": 5
    },
    {
      "name": "4",
      "distance": 4,
      "price": 300,
      "rusts_on": "D",
      "num": 4
    },
    {
      "name": "5",
      "distance": 5,
      "price": 450,
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
      "price": 1100,
      "num": 20,
      "available_on": "6",
      "discount": {
        "4": 300,
        "5": 300,
        "6": 300
      }
    }
  ],
  "hexes": {
    "red": {
      "p=a:3,b:j": [
        "I1"
      ],
      "o=r:yellow_40|brown_70;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0": [
        "F2"
      ],
      "o=r:yellow_30|brown_60;p=a:2,b:_0;p=a:3,b:_0": [
        "J2"
      ],
      "p=a:4,b:j": [
        "A9"
      ],
      "o=r:yellow_30|brown_50;p=a:4,b:_0;p=a:5,b:_0": [
        "A11"
      ],
      "o=r:yellow_30|brown_40;p=a:1,b:_0;p=a:2,b:_0": [
        "K13"
      ],
      "o=r:yellow_20|brown_30;p=a:0,b:_0;p=a:5,b:_0": [
        "B24"
      ]
    },
    "gray": {
      "c=r:20;p=a:3,b:_0;p=a:4,b:_0": [
        "D2"
      ],
      "c=r:30;p=a:4,b:_0;p=a:_0,b:5": [
        "F6"
      ],
      "p=a:1,b:2": [
        "E9"
      ],
      "c=r:10;p=a:0,b:_0;p=a:_0,b:3;p=a:0,b:_0": [
        "H12"
      ],
      "c=r:20;p=a:0,b:_0;p=a:3,b:_0;p=a:5,b:_0": [
        "D14"
      ],
      "t=r:10;p=a:0,b:_0;p=a:_0,b:2": [
        "C15"
      ],
      "c=r:20;p=a:1,b:_0": [
        "K15"
      ],
      "p=a:4,b:5": [
        "A17"
      ],
      "c=r:40;p=a:4,b:_0;p=a:_0,b:5": [
        "A19"
      ],
      "t=r:10;p=a:0,b:_0;p=a:_0,b:1": [
        "I19",
        "F24"
      ],
      "p=a:0,b:5": [
        "D24"
      ]
    },
    "white": {
      "c=r:0;u=c:80,t:water": [
        "F4",
        "J14",
        "F22"
      ],
      "town": [
        "E7",
        "B20",
        "D4",
        "F10"
      ],
      "blank": [
        "I13",
        "D18",
        "B12",
        "B14",
        "B22",
        "C7",
        "C9",
        "C11",
        "C13",
        "C23",
        "D8",
        "D12",
        "D16",
        "D20",
        "E3",
        "E13",
        "E15",
        "F8",
        "F12",
        "F14",
        "F18",
        "G3",
        "G5",
        "G9",
        "G11",
        "H2",
        "H6",
        "H8",
        "H14",
        "I3",
        "I5",
        "I7",
        "I9",
        "J4",
        "J6",
        "J8"
      ],
      "u=c:120,t:mountain": [
        "G15",
        "C17",
        "C21",
        "D22",
        "E17",
        "E21",
        "G13",
        "I11",
        "J10",
        "J12"
      ],
      "city": [
        "B16",
        "E19",
        "H4",
        "B10",
        "H10",
        "H16"
      ],
      "c=r:0;u=c:120,t:mountain": [
        "F16"
      ],
      "t=r:0;t=r:0": [
        "G7",
        "G17",
        "F20"
      ],
      "u=c:80,t:water": [
        "D6",
        "I17",
        "B18",
        "C19"
      ]
    },
    "yellow": {
      "c=r:0;c=r:0;l=OO;u=c:80,t:water": [
        "E5",
        "D10"
      ],
      "c=r:0;c=r:0;l=OO": [
        "E11",
        "H18"
      ],
      "c=r:30;p=a:3,b:_0;p=a:5,b:_0;l=B": [
        "I15"
      ],
      "c=r:40;c=r:40;p=a:2,b:_0;p=a:5,b:_1;l=NY;u=c:80,t:water": [
        "G19"
      ],
      "c=r:30;p=a:2,b:_0;p=a:4,b:_0;l=B": [
        "E23"
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
      "name": "D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
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
