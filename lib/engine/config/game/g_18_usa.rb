# frozen_string_literal: true

# File original copied from g_1817.rb
# There is no 18xx-maker for this AFAIK

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18USA
        JSON = <<-'DATA'
{
  "filename": "18USA",
  "modulename": "18USA",
  "currencyFormatStr": "$%d",
  "bankCash": 99999,
  "certLimit": {
    "2": 32,
    "3": 21,
    "4": 16,
    "5": 16,
    "6": 13,
    "7": 11
  },
  "startingCash": {
    "2": 630,
    "3": 420,
    "4": 315,
    "5": 300,
    "6": 250,
    "7": 225
  },
  "capitalization": "incremental",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "A15": "Winnipeg",
    "A27": "Montreal",
    "B2": "Seattle",
    "B8": "Helena",
    "B14": "Fargo",
    "C3": "Portland",
    "C17": "Minneapolis",
    "C23": "Detroit",
    "C25": "Toronto",
    "C29": "Boston",
    "D6": "Boise",
    "D14": "Omaha",
    "D20": "Chicago",
    "D24": "Cleveland",
    "D28": "New York City",
    "E1": "San Francisco",
    "E3": "Sacramento",
    "E7": "Salt Lake City",
    "E11": "Denver",
    "E15": "Kansas City",
    "E17": "St. Louis",
    "E23": "Columbus",
    "F20": "Louisville",
    "F26": "Baltimore",
    "G3": "Los Angeles",
    "G7": "Pheonix",
    "G11": "Santa Fe",
    "G17": "Memphis",
    "G27": "Norfolk",
    "H8": "Tucson",
    "H14": "Dallas-Fort Worth",
    "H20": "Birmingham",
    "H22": "Atlanta",
    "I13": "San Antonio",
    "I15": "Houston",
    "I19": "New Orelans",
    "I25": "Jacksonville",
    "J20": "Port of New Orleans",
    "J24": "Florida",
    "I9": "Mexico"
  },
  "tiles": {
    "5": "unlimited",
    "6": "unlimited",
    "7": "unlimited",
    "8": "unlimited",
    "9": "unlimited",
    "14": "unlimited",
    "15": "unlimited",
    "54": "unlimited",
    "57": "unlimited",
    "62": "unlimited",
    "63": "unlimited",
    "80": "unlimited",
    "81": "unlimited",
    "82": "unlimited",
    "83": "unlimited",
    "448": "unlimited",
    "544": "unlimited",
    "545": "unlimited",
    "546": "unlimited",
    "592": "unlimited",
    "593": "unlimited",
    "597": "unlimited",
    "611": "unlimited",
    "619": "unlimited",
    "X00": {
      "count": "unlimited",
      "color": "yellow",
      "code": "city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B"
    },
    "X30": {
      "count": "unlimited",
      "color": "gray",
      "code": "city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY"
    }
  },
  "market": [
    [
      "0l",
      "0a",
      "0a",
      "0a",
      "42",
      "44",
      "46",
      "48",
      "50p",
      "53s",
      "56p",
      "59p",
      "62p",
      "66p",
      "70p",
      "74s",
      "78p",
      "82p",
      "86p",
      "90p",
      "95p",
      "100p",
      "105p",
      "110p",
      "115p",
      "120s",
      "127p",
      "135p",
      "142p",
      "150p",
      "157p",
      "165p",
      "172p",
      "180p",
      "190p",
      "200p",
      "210",
      "220",
      "230",
      "240",
      "250",
      "260",
      "270",
      "285",
      "300",
      "315",
      "330",
      "345",
      "360",
      "375",
      "390",
      "405",
      "420",
      "440",
      "460",
      "480",
      "500",
      "520",
      "540",
      "560",
      "580",
      "600",
      "625",
      "650",
      "675",
      "700",
      "725",
      "750",
      "775",
      "800"
    ]
  ],
  "companies": [
    {
       "name" : "Lehigh Coal Mine Co.",
       "value" : 30,
       "revenue" : 0,
       "desc" : "Comes with one coal token",
       "sym": "P1"
    },
    {
       "name" : "Fox Bridge Works",
       "value" : 40,
       "revenue" : 0,
       "desc" : "Comes with one bridge token. $10 discount on rivers",
       "sym": "P2"
    },
    {
       "name" : "Reece Oil and Gas",
       "value" : 30,
       "revenue" : 0,
       "desc" : "Comes with one oil token",
       "sym": "P3"
    },
    {
       "name" : "Hendrickson Iron",
       "value" : 40,
       "revenue" : 0,
       "desc" : "Comes with one ore token",
       "sym": "P4"
    },
    {
       "name" : "Nobel's Blasting Powder",
       "value" : 30,
       "revenue" : 0,
       "desc" : "$15 discount on mountains",
       "sym": "P5"
    },
    {
       "name" : "Import/Export Hub",
       "value" : 30,
       "revenue" : 0,
       "desc" : "Discard to replace an offboard value tile with the special tile",
       "sym": "P6"
    },
    {
       "name" : "Track Engineers",
       "value" : 40,
       "revenue" : 0,
       "desc" : "May lay two extra track tiles instead of one when paying $20",
       "sym": "P7"
    },
    {
       "name" : "Express Freight Service",
       "value" : 40,
       "revenue" : 0,
       "desc" : "+10 to any offboard for this company. Use an extra station token to indicate this",
       "sym": "P8"
    },
    {
       "name" : "Boomtown",
       "value" : 40,
       "revenue" : 0,
       "desc" : "Discard to upgrade a non-metropolis city to green as a free action even before Phase 3",
       "sym": "P9"
    },
    {
       "name" : "Carnegie Steel Company",
       "value" : 40,
       "revenue" : 0,
       "desc" : "If this company starts in an unselected and unimproved metropolis, that city becomes a metropolis",
       "sym": "P10"
    },
    {
       "name" : "Pettibone & Mulliken",
       "value" : 40,
       "revenue" : 0,
       "desc" : "May upgrade non-city track one color higher than currently allowed. May make an extra non-city upgrade instead of an extra lay when paying $20",
       "sym": "P11"
    },
    {
       "name" : "Standard Oil Co.",
       "value" : 60,
       "revenue" : 0,
       "desc" : "Comes with two oil tokens",
       "sym": "P12"
    },
    {
       "name" : "Pennsy Boneyard",
       "value" : 60,
       "revenue" : 0,
       "desc" : "Discard when this company's non-plus train would rust to treat it as a plus train.",
       "sym": "P13"
    },
    {
       "name" : "Pyramid Scheme",
       "value" : 60,
       "revenue" : 0,
       "desc" : "Minimum bid $5. No special ability",
       "sym": "P14"
    },
    {
       "name" : "Western Land Grant",
       "value" : 60,
       "revenue" : 0,
       "desc" : "Company may hold one additional loan on this card. This loan only has a $5 interest. Loans may be taken and paid off in any order",
       "sym": "P15"
    },
    {
       "name" : "Regional Headquarters",
       "value" : 60,
       "revenue" : 0,
       "desc" : "May upgrade a non-metropolis green or brown city to the Reg. HQ tile after Phase 5 starts. The arms labeled '?' may point to impassable hex sides.",
       "sym": "P16"
    },
    {
       "name" : "Great Northern Railway",
       "value" : 60,
       "revenue" : 0,
       "desc" : "One extra yellow lay per turn on the marked hexes, ignoring terrain fees. +30 per train that runs Fargo-Helena. +60 per train that runs Seattle-Fargo-Helena-Chicago",
       "sym": "P17"
    },
    {
       "name" : "Peabody Coal Company",
       "value" : 60,
       "revenue" : 0,
       "desc" : "Comes with two coal tokens",
       "sym": "P18"
    },
    {
       "name" : "Union Switch & Signal",
       "value" : 80,
       "revenue" : 0,
       "desc" : "One train per turn may skip over a city (even a blocked city).",
       "sym": "P19"
    },
    {
       "name" : "Suem & Wynn Law Firm",
       "value" : 80,
       "revenue" : 0,
       "desc" : "Discard to lay a token in a blocked city. This may be in addition to your normal token lay and may be done before laying track.",
       "sym": "P20"
    },
    {
       "name" : "Keystone Bridge Co.",
       "value" : 80,
       "revenue" : 0,
       "desc" : "Comes with one bridge token and either one ore or one coal token (your choice, decided when the token is laid)",
       "sym": "P21"
    },
    {
       "name" : "American Bridge Company",
       "value" : 80,
       "revenue" : 0,
       "desc" : "Comes with two bridge tokens. $10 discount on rivers",
       "sym": "P22"
    },
    {
       "name" : "Bailey yard",
       "value" : 80,
       "revenue" : 0,
       "desc" : "The company receives one bonus station marker",
       "sym": "P23"
    },
    {
       "name" : "Anaconda Copper",
       "value" : 90,
       "revenue" : 0,
       "desc" : "Comes with two ore tokens",
       "sym": "P24"
    },
    {
       "name" : "American Locomotive Co.",
       "value" : 90,
       "revenue" : 0,
       "desc" : "10% discount on train purchases. May discard this to buy a train any time before running. CLOSES ON PHASE 6",
       "sym": "P25"
    },
    {
       "name" : "Rural Junction",
       "value" : 90,
       "revenue" : 0,
       "desc" : "May place the Rural Junction tiles as a track lay (see rules)",
       "sym": "P26"
    },
    {
       "name" : "Company Town",
       "value" : 90,
       "revenue" : 0,
       "desc" : "May place -one- Company Town tile as a track lay (see rules)",
       "sym": "P27"
    },
    {
       "name" : "Consolidation Coal Co.",
       "value" : 90,
       "revenue" : 0,
       "desc" : "Comes with three coal tokens",
       "sym": "P28"
    },
    {
       "name" : "Bankrupt Railroad",
       "value" : 120,
       "revenue" : 0,
       "desc" : "If this company starts in a city with a No Subsidy tile it immediately takes a free 2-train which may run in its first OR",
       "sym": "P29"
    },
    {
       "name" : "Double Heading",
       "value" : 120,
       "revenue" : 0,
       "desc" : "Each turn, one non-permanent train may run to one extra city",
       "sym": "P30"
    }
  ],
  "corporations": [
    {
      "float_percent": 20,
      "sym": "A&S",
      "name": "Alton & Southern Railway",
      "logo": "1817/AS",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "pink"
    },
    {
      "float_percent": 20,
      "sym": "A&A",
      "name": "Arcade and Attica",
      "logo": "1817/AA",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "gold"
    },
    {
      "float_percent": 20,
      "sym": "Belt",
      "name": "Belt Railway of Chicago",
      "logo": "1817/Belt",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "text_color": "black",
      "color": "orange"
    },
    {
      "float_percent": 20,
      "sym": "Bess",
      "name": "Bessemer and Lake Erie Railroad",
      "logo": "1817/Bess",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "black"
    },
    {
      "float_percent": 20,
      "sym": "B&A",
      "name": "Boston and Albany Railroad",
      "logo": "1817/BA",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "red"
    },
    {
      "float_percent": 20,
      "sym": "DL&W",
      "name": "Delaware, Lackawanna and Western Railroad",
      "logo": "1817/DLW",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "brown"
    },
    {
      "float_percent": 20,
      "sym": "J",
      "name": "Elgin, Joliet and Eastern Railway",
      "logo": "1817/J",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "text_color": "black",
      "color": "green"
    },
    {
      "float_percent": 20,
      "sym": "GT",
      "name": "Grand Trunk Western Railroad",
      "logo": "1817/GT",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "violet"
    },
    {
      "float_percent": 20,
      "sym": "H",
      "name": "Housatonic Railroad",
      "logo": "1817/H",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "text_color": "black",
      "color": "lightBlue"
    },
    {
      "float_percent": 20,
      "sym": "ME",
      "name": "Morristown and Erie Railway",
      "logo": "1817/ME",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "yellow",
      "text_color": "black"
    },
    {
      "float_percent": 20,
      "sym": "NYOW",
      "name": "New York, Ontario and Western Railway",
      "logo": "1817/W",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "turquoise"
    },
    {
      "float_percent": 20,
      "sym": "NYSW",
      "name": "New York, Susquehanna and Western Railway",
      "logo": "1817/S",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "white",
      "text_color": "black"
    },
    {
      "float_percent": 20,
      "sym": "PSNR",
      "name": "Pittsburgh, Shawmut and Northern Railroad",
      "logo": "1817/PSNR",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "brightGreen"
    },
    {
      "float_percent": 20,
      "sym": "PLE",
      "name": "Pittsburgh and Lake Erie Railroad",
      "logo": "1817/PLE",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "lime"
    },
    {
      "float_percent": 20,
      "sym": "PW",
      "name": "Providence and Worcester Railroad",
      "logo": "1817/PW",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "text_color": "black",
      "color": "lightBrown"
    },
    {
      "float_percent": 20,
      "sym": "R",
      "name": "Rutland Railroad",
      "logo": "1817/R",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "blue"
    },
    {
      "float_percent": 20,
      "sym": "SR",
      "name": "Strasburg Railroad",
      "logo": "1817/SR",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "natural"
    },
    {
      "float_percent": 20,
      "sym": "UR",
      "name": "Union Railroad",
      "logo": "1817/UR",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "navy"
    },
    {
      "float_percent": 20,
      "sym": "WT",
      "name": "Warren & Trumbull Railroad",
      "logo": "1817/WT",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "lavender"
    },
    {
      "float_percent": 20,
      "sym": "WC",
      "name": "West Chester Railroad",
      "logo": "1817/WC",
      "shares": [100],
      "max_ownership_percent": 100,
      "tokens": [
        0
      ],
      "always_market_price": true,
      "color": "gray"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 40
    },
    {
      "name": "2+",
      "distance": 2,
      "price": 100,
      "obsolete_on": "4",
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
      "name": "3+",
      "distance": 3,
      "price": 250,
      "obsolete_on": "6",
      "num": 2
    },
    {
      "name": "4",
      "distance": 4,
      "price": 400,
      "rusts_on": "8",
      "num": 7
    },
    {
      "name": "4+",
      "distance": 4,
      "price": 400,
      "obsolete_on": "8",
      "num": 1
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
      "num": 40,
      "events": [
        {"type": "signal_end_game"}
      ]
    }
  ],
  "hexes": {
    "red": {
      "offboard=revenue:yellow_0;path=a:5,b:_0;path=a:0,b:_0": [
        "A27"
      ],
      "offboard=revenue:yellow_0;path=a:2,b:_0": [
        "J20"
      ],
      "offboard=revenue:yellow_0,groups:Mexico;path=a:2,b:_0;path=a:3,b:_0;border=edge:4": [
        "I5"
      ],
      "offboard=revenue:yellow_0,groups:Mexico;path=a:2,b:_0;path=a:3,b:_0;border=edge:4;border=edge:1": [
        "I7", "I9"
      ],
      "offboard=revenue:yellow_0,groups:Mexico;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:1;border=edge:5": [
        "I11"
      ],
      "offboard=revenue:yellow_0,groups:Mexico;path=a:3,b:_0;border=edge:2;border=edge:5": [
        "J12"
      ],
      "offboard=revenue:yellow_0,groups:Mexico;path=a:3,b:_0;border=edge:2": [
        "K13"
      ]
    },
    "white": {
      "city=revenue:0": [
        "E11", "G3", "H14", "I15", "H20", "H22", "F26", "C29", "D24"
      ],
      "city=revenue:0;icon=image:18_ms/coins": [
        "D6", "E3", "E7", "G7", "G11", "H8", "I13", "I25", "G27", "E23"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:water": [
        "C3", "D14",
        "C17", "E15", "E17", "F20", "G17", "I19"
      ],
      "upgrade=cost:15,terrain:mountain": [
        "B28",
        "C27",
        "F4",
        "G5", "G23"
      ],
      "upgrade=cost:10,terrain:water": [
        "D18",
        "E21",
        "F18",
        "H18"
      ],
      "upgrade=cost:20,terrain:lake": [
        "B22"
      ],
      "upgrade=cost:15,terrain:mountain;icon=image:mine": [
        "C7",
        "E9",
        "G21"
      ],
      "icon=image:mine": [
        "D16",
        "E5",
        "H6"
      ],
      "icon=image:oil-derrick": [
        "G15",
        "H4",
        "I17", "I21", "I23",
        "J14"
      ],
      "icon=image:coalcar": [
        "E19",
        "F16"
      ],
      "upgrade=cost:15,terrain:mountain;icon=image:coalcar": [
        "C9",
        "D8", "D10", "D26",
        "E25",
        "F8", "F10", "F22", "F24"
      ],
      "icon=image:18_usa/gnr": [
        "B16", "B18"
      ],
      "icon=image:18_usa/gnr;icon=image:mine": [
        "C19"
      ],
      "icon=image:18_usa/gnr;icon=image:coalcar;icon=image:mine": [
        "B10"
      ],
      "icon=image:18_usa/gnr;icon=image:coalcar;icon=image:oil-derrick": [
        "B12"
      ],
      "icon=image:18_usa/gnr;city=revenue:0": [
        "D20"
      ],
      "icon=image:18_usa/gnr;city=revenue:0;icon=image:18_ms/coins": [
        "B8", "B14"
      ],
      "icon=image:18_usa/gnr;upgrade=cost:15,terrain:mountain;icon=image:coalcar": [
        "B6"
      ],
      "icon=image:18_usa/gnr;upgrade=cost:10,terrain:water": [
        "B4"
      ],
      "": [
        "B20", "B26",
        "C5", "C11", "C13", "C15",
        "D2", "D4", "D12", "D22",
        "E13", "E27",
        "F2", "F6", "F12", "F14",
        "G9", "G13", "G19", "G25",
        "H10", "H12", "H16", "H24", "H26"
      ]
    },
    "gray": {
      "town=revenue:yellow_0;path=a:0,b:_0;path=a:5,b:_0": [
        "A15"
      ],
      "town=revenue:yellow_0;path=a:4,b:_0;path=a:5,b:_0": [
        "B2"
      ],
      "town=revenue:yellow_0;path=a:2,b:_0;path=a:3,b:_0": [
        "J24"
      ],
      "town=revenue:yellow_0;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0": [
        "E1"
      ],
      "path=a:1,b:0": [
        "B30"
      ],
      "town=revenue:yellow_30|green_40|brown_50|gray_60;path=a:4,b:_0;path=a:2,b:_0;path=a:0,b:_0": [
        "C23"
      ],
      "town=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0;path=a:5,b:_0;path=a:3,b:_0": [
        "C25"
      ]
    },
    "yellow": {
      "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:3,b:_0;label=NY": [
        "D28"
      ]
    },
    "blue": {
      "": [
        "B24", "C21"
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
      "operating_rounds": 2,
      "corporation_sizes": [2]
    },
    {
      "name": "2+",
      "on": "2+",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 2,
      "corporation_sizes": [2]
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
      "corporation_sizes": [2, 5]
    },
    {
      "name": "3+",
      "on": "3+",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "corporation_sizes": [2, 5]
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
      "corporation_sizes": [5]
    },
    {
      "name": "4+",
      "on": "4+",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "corporation_sizes": [5]
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
      "operating_rounds": 2,
      "corporation_sizes": [5, 10]
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
      "operating_rounds": 2,
      "corporation_sizes": [10]
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
      "operating_rounds": 2,
      "corporation_sizes": [10]
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
      "status": [
        "no_new_shorts"
      ],
      "operating_rounds": 2,
      "corporation_sizes": [10]
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
