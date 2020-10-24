# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1828
        JSON = <<-'DATA'
{
    "filename": "1828",
    "modulename": "1828",
    "currencyFormatStr": "$%d",
    "bankCash": 99999,
    "certLimit": {
        "3": 99,
        "4": 99,
        "5": 99
    },
    "startingCash": {
        "3": 800,
        "4": 700,
        "5": 620
    },
    "capitalization": "full",
    "layout": "pointy",
    "mustSellInBlocks": false,
    "locationNames": {
        "A3": "Copper County",
        "A5": "Marquette",
        "B14": "Barrie",
        "A7": "Mackinaw City",
        "C5": "Muskegon",
        "D4": "Grand Rapids",
        "D6": "Lansing",
        "D8": "Flint",
        "D10": "Sarnia",
        "D14": "Hamilton & Toronto",
        "E7": "Adrian & Ann Arbor",
        "E9": "Detroit & Windsor",
        "F8": "Toledo",
        "F10": "Cleveland",
        "F14": "Erie",
        "A13": "Canada",
        "A23": "Montreal",
        "B20": "Ottawa",
        "B24": "Burlington",
        "B28": "Maine",
        "C15": "Peterborough",
        "C19": "Kingston",
        "D18": "Rochester",
        "D24": "Schenectady",
        "E15": "Dunkirk & Buffalo",
        "E23": "Albany",
        "E27": "Boston",
        "F20": "Scranton",
        "F24": "New Haven & Hartford",
        "F26": "Providence",
        "F28": "Mansfield",
        "G3": "Chicago",
        "G11": "Akron & Canton",
        "H6": "Louisville",
        "H8": "Cincinnati",
        "H12": "Pittsburgh",
        "H14": "Johnstown",
        "I1": "West",
        "I3": "St Louis",
        "I11": "Washington",
        "J6": "Nashville",
        "K3": "New Orleans",
        "K11": "Virginia Coalfields",
        "K13": "Virginia Tunnel",
        "G21": "Reading & Allentown",
        "G23": "Newark & New York",
        "H16": "Altoona",
        "H20": "Lancaster",
        "H22": "Philadelphia & Trenton",
        "I19": "Baltimore",
        "I23": "Atlantic City",
        "J18": "Washington",
        "K15": "Richmond",
        "K19": "Norfolk",
        "L16": "Deep South",
        "L18": "Suffolk"
    },
    "tiles": {
        "1": 1,
        "2": 1,
        "3": 3,
        "4": 4,
        "7": 6,
        "8": 16,
        "9": 16,
        "14": 6,
        "15": 4,
        "16": 1,
        "17": 1,
        "18": 1,
        "19": 1,
        "20": 1,
        "23": 4,
        "24": 4,
        "25": 3,
        "26": 2,
        "27": 2,
        "28": 2,
        "29": 2,
        "30": 2,
        "31": 2,
        "39": 2,
        "40": 2,
        "41": 2,
        "42": 2,
        "43": 2,
        "44": 2,
        "45": 2,
        "46": 2,
        "47": 2,
        "53": 1,
        "54": 1,
        "55": 1,
        "56": 1,
        "57": 8,
        "58": 3,
        "59": 3,
        "61": 1,
        "62": 1,
        "63": 3,
        "64": 1,
        "65": 1,
        "66": 1,
        "67": 1,
        "68": 1,
        "69": 1,
        "70": 2,
        "121": 1,
        "205": 1,
        "206": 1,
        "448": 2,
        "449": 2,
        "997": 1
    },
    "market": [
        [
            "122",
            "130",
            "138",
            "147",
            "157",
            "167",
            "178",
            "191",
            "213",
            "240",
            "272",
            "312",
            "357",
            "412",
            "500e"
        ],
        [
            "112",
            "120p",
            "127",
            "136",
            "145",
            "154",
            "164",
            "176",
            "197",
            "221",
            "251",
            "287",
            "329",
            "380",
            "443"
        ],
        [
            "102",
            "107",
            "113",
            "119",
            "126",
            "133",
            "140",
            "149",
            "165",
            "184",
            "207",
            "235",
            "267",
            "305",
            "353"
        ],
        [
            "95",
            "100",
            "105p",
            "111",
            "117",
            "124",
            "130",
            "139",
            "153",
            "171",
            "192",
            "218",
            "248",
            "284",
            "328"
        ],
        [
            "87",
            "92",
            "96",
            "101",
            "106",
            "111",
            "117",
            "124",
            "136",
            "151",
            "169",
            "191",
            "216",
            "246",
            "283"
        ],
        [
            "81",
            "86",
            "90",
            "94p",
            "99",
            "104",
            "109",
            "116",
            "127",
            "141",
            "158",
            "179",
            "202",
            "230"
        ],
        [
            "76",
            "80",
            "84",
            "88",
            "93",
            "97",
            "102",
            "108",
            "119",
            "132",
            "148",
            "167",
            "189"
        ],
        [
            "71o",
            "75",
            "78",
            "82",
            "86p",
            "91",
            "95",
            "101",
            "111",
            "123",
            "138",
            "156"
        ],
        [
            "66o",
            "70o",
            "73",
            "77",
            "81",
            "85",
            "89",
            "94",
            "104",
            "115",
            "129"
        ],
        [
            "62o",
            "65o",
            "69",
            "72",
            "76",
            "79p",
            "83",
            "88",
            "97",
            "108"
        ],
        [
            "58o",
            "61o",
            "64o",
            "67",
            "71",
            "74",
            "78",
            "82",
            "91",
            "101"
        ],
        [
            "54o",
            "57o",
            "60o",
            "63o",
            "66",
            "69",
            "71p",
            "77",
            "85"
        ],
        [
            "51o",
            "53o",
            "56o",
            "59o",
            "62",
            "65",
            "68",
            "72",
            "79"
        ],
        [
            "47o",
            "50o",
            "52o",
            "55o",
            "58o",
            "60",
            "64",
            "67p",
            "74"
        ],
        [
            "",
            "47o",
            "49o",
            "51o",
            "54o",
            "57o",
            "59"
        ],
        [
            "",
            "43o",
            "46o",
            "48o",
            "50o",
            "53o",
            "55o"
        ],
        [
            "",
            "",
            "43o",
            "45o",
            "47o",
            "49o",
            "52o"
        ],
        [
            "",
            "",
            "40o",
            "42o",
            "44o",
            "46o",
            "48o"
        ]
    ],
    "companies": [
        {
            "name": "Schuylkill Valley Navigation",
            "value": 20,
            "revenue": 5,
            "desc": "Blocks G19 while owned by a player.",
            "sym": "SVN",
            "abilities": [
                {
                    "type": "blocks_hexes",
                    "owner_type": "player",
                    "hexes": [
                        "G19"
                    ]
                }
            ]
        },
        {
            "name": "Saint Clair Tunnel",
            "value": 20,
            "revenue": 5,
            "desc": "Blocks Sarnia (D10) while owned by a player. When this company is sold to a corporation, revenue increases to $10.",
            "sym": "StCT",
            "abilities": [
                {
                    "type": "blocks_hexes",
                    "owner_type": "player",
                    "hexes": [
                        "D10"
                    ]
                },
                {
                    "type": "revenue_change",
                    "revenue": 10,
                    "when": "sold"
                }
            ]
        },
        {
            "name": "Champlain & St. Lawrence Railroad",
            "value": 40,
            "revenue": 10,
            "desc": "Blocks Burlington (B24) while owned by a player. Once sold to a corporation, the owning corporation may place a yellow track tile in B24 for free at any time in its operations. This does not count as part of the owning corporation's track lay. The track tile at Burlington (B24) does not need to connect to or be part of one of the owning corporation's routes. This power may be used at any time during the owning corporation's operation.",
            "sym": "C&StL",
            "abilities": [
                {
                    "type": "blocks_hexes",
                    "owner_type": "player",
                    "hexes": [
                        "B24"
                    ]
                },
                {
                    "type": "tile_lay",
                    "owner_type": "corporation",
                    "hexes": [
                        "B24"
                    ],
                    "hexes": [
                        "B24"
                    ],
                    "tiles": [
                        "3",
                        "4",
                        "58"
                    ],
                    "free": true,
                    "count": 1
                }
            ]
        },
        {
            "name": "Delaware & Hudson Railroad",
            "value": 80,
            "revenue": 15,
            "desc": "Blocks Scranton (F20) while owned by a player. Once sold to a corporation, the owning corporation may pay a fee of $120 to the bank, place or upgrade a track tile in Scranton (F20) and optionally also place a station marker in Scranton (F20) without additional cost. This counts as a yellow track tile lay or upgrade respectively for the corporation's normal track build. If a station marker was placed in Scranton, it counts as the corporatin's station market placement for the Operating Round. The track tile at Scranton (F20) does not need to connect to or be part of one of the owning share company's routes. The power may be used in the track building and station placement steps of the owning corporation's operations.",
            "sym": "D&H",
            "abilities": [
                {
                    "type": "blocks_hexes",
                    "owner_type": "player",
                    "hexes": [
                        "F20"
                    ]
                },
                {
                    "type": "teleport",
                    "owner_type":"corporation",
                    "hexes": [
                      "F20"
                    ],
                    "tiles": [
                        "14",
                        "15",
                        "57",
                        "205",
                        "206"
                    ],
                    "when": "track",
                    "count": 1
                }
            ]
        },
        {
            "name": "Cobourg & Peterborough Railway",
            "value": 80,
            "revenue": 0,
            "desc": "Not yet implemented",
            "sym": "C&P",
            "abilities": [
                {
                    "type": "revenue_change",
                    "revenue": 15,
                    "when": "sold"
                }
            ]
        },
        {
            "name": "Mohawk & Hudson Railroad",
            "value": 120,
            "revenue": 20,
            "desc": "Blocks D22 while owned by a player. As the owning player's Stock Round action in yellow phase or later, or at any time during an Operating Round, may be exchanged for any 10% share certificate from the IPO or bank pool, or for 10% (half) of a director's certificate (the purchaser must pay for the other 10% and par the corporation in the normal manner), if one is available. The Mohawk & Hudson Railroad is then closed and removed from the game.",
            "sym": "M&H",
            "abilities": [
                {
                    "type": "blocks_hexes",
                    "owner_type": "player",
                    "hexes": [
                        "D22"
                    ]
                },
                {
                    "type": "exchange",
                    "corporation": "any",
                    "from": [
                        "ipo",
                        "market"
                    ]
                }
            ]
        },
        {
            "name": "Erie & Kalamazoo Railroad",
            "value": 120,
            "revenue": 20,
            "desc": "Blocks Adrian & Ann Arbor (E7) while owned by a player. The owning corporation may (once per game) place an additional yellow track tile for $20 paid to the bank as part of its normal track-build. The owning corporation cannot upgrade a track tile in the Operating Round.",
            "sym": "E&K",
            "abilities": [
                {
                    "type": "blocks_hexes",
                    "owner_type": "player",
                    "hexes": [
                        "E7"
                    ]
                },
                {
                    "type": "tile_lay",
                    "owner_type": "corporation",
                    "hexes": [
                        "E7"
                    ],
                    "tiles": [
                        "1",
                        "2",
                        "3",
                        "4",
                        "6",
                        "7",
                        "8",
                        "55",
                        "56",
                        "57",
                        "58",
                        "69"
                    ]
                }
            ]
        },
        {
            "name": "Camden & Amboy Railroad",
            "value": 160,
            "revenue": 25,
            "desc": "Blocks Philadelphia & Trenton (H22) while owned by a player. Comes with a 10% certificate of the Pennsylvania Railroad (PRR).",
            "sym": "C&A",
            "abilities": [
                {
                    "type": "blocks_hexes",
                    "owner_type": "player",
                    "hexes": [
                        "H22"
                    ]
                },
                {
                    "type": "shares",
                    "shares": "PRR_1"
                }
            ]
        },
        {
            "name": "Canadian Pacific",
            "value": 250,
            "revenue": 40,
            "desc": "When purchased during the private auction comes with the 20% director's certificate and a 10% share certificate of the matching corporation. The buying player must immediately set the par price for the matching corporation to any yellow par price. Cannot be purchased by a corporation. Closes when the matching corporation acquires a train.",
            "sym": "CPR",
            "abilities": [
                {
                    "type": "shares",
                    "shares": [
                        "CPR_0",
                        "CPR_1"
                    ]
                },
                {
                    "type": "no_buy"
                }
            ]
        },
        {
            "name": "Grand Trunk",
            "value": 250,
            "revenue": 40,
            "desc": "When purchased during the private auction comes with the 20% director's certificate and a 10% share certificate of the matching corporation. The buying player must immediately set the par price for the matching corporation to any yellow par price. Cannot be purchased by a corporation. Closes when the matching corporation acquires a train.",
            "sym": "GT",
            "abilities": [
                {
                    "type": "shares",
                    "shares": [
                        "GT_0",
                        "GT_1"
                    ]
                },
                {
                    "type": "no_buy"
                }
            ]
        },
        {
            "name": "Illinois Central",
            "value": 250,
            "revenue": 40,
            "desc": "When purchased during the private auction comes with the 20% director's certificate and a 10% share certificate of the matching corporation. The buying player must immediately set the par price for the matching corporation to any yellow par price. Cannot be purchased by a corporation. Closes when the matching corporation acquires a train.",
            "sym": "IC",
            "abilities": [
                {
                    "type": "shares",
                    "shares": [
                        "IC_0",
                        "IC_1"
                    ]
                },
                {
                    "type": "no_buy"
                }
            ]
        },
        {
            "name": "Michigan Central",
            "value": 250,
            "revenue": 40,
            "desc": "When purchased during the private auction comes with the 20% director's certificate and a 10% share certificate of the matching corporation. The buying player must immediately set the par price for the matching corporation to any yellow par price. Cannot be purchased by a corporation. Closes when the matching corporation acquires a train.",
            "sym": "MC",
            "abilities": [
                {
                    "type": "shares",
                    "shares": [
                        "MC_0",
                        "MC_1"
                    ]
                },
                {
                    "type": "no_buy"
                }
            ]
        },
        {
            "name": "Missouri Pacific Railroad",
            "value": 250,
            "revenue": 40,
            "desc": "When purchased during the private auction comes with the 20% director's certificate and a 10% share certificate of the matching corporation. The buying player must immediately set the par price for the matching corporation to any yellow par price. Cannot be purchased by a corporation. Closes when the matching corporation acquires a train.",
            "sym": "MP",
            "abilities": [
                {
                    "type": "shares",
                    "shares": [
                        "MP_0",
                        "MP_1"
                    ]
                },
                {
                    "type": "no_buy"
                }
            ]
        },
        {
            "name": "New York, Chicago & St. Louis Railroad",
            "value": 250,
            "revenue": 40,
            "desc": "When purchased during the private auction comes with the 20% director's certificate and a 10% share certificate of the matching corporation. The buying player must immediately set the par price for the matching corporation to any yellow par price. Cannot be purchased by a corporation. Closes when the matching corporation acquires a train.",
            "sym": "NKP",
            "abilities": [
                {
                    "type": "shares",
                    "shares": [
                        "NKP_0",
                        "NKP_1"
                    ]
                },
                {
                    "type": "no_buy"
                }
            ]
        },
        {
            "name": "Norfolk & Western",
            "value": 250,
            "revenue": 40,
            "desc": "When purchased during the private auction comes with the 20% director's certificate and a 10% share certificate of the matching corporation. The buying player must immediately set the par price for the matching corporation to any yellow par price. Cannot be purchased by a corporation. Closes when the matching corporation acquires a train.",
            "sym": "NW",
            "abilities": [
                {
                    "type": "shares",
                    "shares": [
                        "NW_0",
                        "NW_1"
                    ]
                },
                {
                    "type": "no_buy"
                }
            ]
        },
        {
            "name": "Ontario, Simcoe & Huron",
            "value": 250,
            "revenue": 40,
            "desc": "When purchased during the private auction comes with the 20% director's certificate and a 10% share certificate of the matching corporation. The buying player must immediately set the par price for the matching corporation to any yellow par price. Cannot be purchased by a corporation. Closes when the matching corporation acquires a train.",
            "sym": "OSH",
            "abilities": [
                {
                    "type": "shares",
                    "shares": [
                        "OSH_0",
                        "OSH_1"
                    ]
                },
                {
                    "type": "no_buy"
                }
            ]
        }
    ],
    "corporations": [
        {
            "sym": "B&M",
            "name": "Boston & Maine",
            "logo": "1828/BM",
            "tokens": [
                0,
                100,
                100,
                100
            ],
            "coordinates": "E27",
            "color": "hanBlue"
        },
        {
            "sym": "B&O",
            "name": "Baltimore & Ohio",
            "logo": "1828/BO",
            "tokens": [
                0,
                100,
                100
            ],
            "coordinates": "I19",
            "color": "steelBlue"
        },
        {
            "sym": "C&O",
            "name": "Chesapeake & Ohio Railroad",
            "logo": "1828/CO",
            "tokens": [
                0,
                100,
                100
            ],
            "coordinates": "K15",
            "color": "powderBlue"
        },
        {
            "sym": "CPR",
            "name": "Canadian Pacific Railroad",
            "logo": "1828/CPR",
            "tokens": [
                0,
                100,
                100,
                100
            ],
            "coordinates": "A23",
            "color": "brick"
        },
        {
            "sym": "GT",
            "name": "Grand Trunk",
            "logo": "1828/GT",
            "tokens": [
                0,
                100,
                100
            ],
            "coordinates": "D4",
            "color": "khaki"
        },
        {
            "sym": "ERIE",
            "name": "Erie Railroad",
            "logo": "1828/ERIE",
            "tokens": [
                0,
                100,
                100
            ],
            "coordinates": "E15",
            "color": "darkGoldenrod"
        },
        {
            "sym": "IC",
            "name": "Illinois Central",
            "logo": "1828/IC",
            "tokens": [
                0,
                100,
                100,
                100
            ],
            "coordinates": "J6",
            "color" : "yellowGreen"
        },
        {
            "sym": "MC",
            "name": "Michigan Central",
            "logo": "1828/MC",
            "tokens": [
                0,
                100,
                100,
                100
            ],
            "coordinates": "A7",
            "color": "gray70"
        },
        {
            "sym": "MP",
            "name": "Missouri Pacific Railroad",
            "logo": "1828/MP",
            "tokens": [
                0,
                100,
                100,
                100
            ],
            "coordinates": "I3",
            "color": "khakiDark"
        },
        {
            "sym": "NYC",
            "name": "New York Central Railroad",
            "logo": "1828/NYC",
            "tokens": [
                0,
                100,
                100
            ],
            "coordinates": "E23",
            "color": "gray50"
        },
        {
            "sym": "NKP",
            "name": "New York, Chicago & St. Louis Railroad",
            "logo": "1828/NKP",
            "tokens": [
                0,
                100,
                100
            ],
            "coordinates": "F10",
            "color": "thistle"
        },
        {
            "sym": "NYH",
            "name": "New York, New Haven & Hartford Railway",
            "logo": "1828/NYH",
            "tokens": [
                0,
                100,
                100
            ],
            "coordinates": "G23",
            "city": 1,
            "color": "tan"
        },
        {
            "sym": "NW",
            "name": "Norfolk & Western Railway",
            "logo": "1828/NW",
            "tokens": [
                0,
                100,
                100,
                100
            ],
            "coordinates": "K19",
            "color": "lightCoral"
        },
        {
            "sym": "OSH",
            "name": "Ontario, Simcoe & Huron",
            "logo": "1828/OSH",
            "tokens": [
                0,
                100,
                100,
                100
            ],
            "coordinates": "A15",
            "color": "cinnabarGreen"
        },
        {
            "sym": "PRR",
            "name": "Pennsylvania Railroad",
            "logo": "1828/PRR",
            "tokens": [
                0,
                100,
                100,
                100
            ],
            "coordinates": "H16",
            "color": "tomato"
        },
        {
            "sym": "WAB",
            "name": "Wabash Railroad",
            "logo": "1828/WAB",
            "tokens": [
                0,
                100,
                100
            ],
            "coordinates": "H6",
            "color": "plum"
        }
    ],
    "trains": [
        {
            "name": "2",
            "distance": 2,
            "price": 80,
            "rusts_on": "5",
            "num": 6
        },
        {
            "name": "3",
            "distance": 3,
            "price": 160,
            "rusts_on": "6",
            "num": 9,
            "events":[
                {"type": "green_par"}
            ]
        },
        {
            "name": "5",
            "distance": 5,
            "price": 250,
            "rusts_on": "8E",
            "num": 4,
            "events":[
                {"type": "blue_par"}
            ]
        },
        {
            "name": "3+D",
            "distance":[
                {
                    "nodes":[
                        "city",
                        "offboard"
                    ],
                    "pay": 3,
                    "visit": 3,
                    "multiplier": 2
                },
                {
                    "nodes": [
                        "town"
                    ],
                    "pay": 99,
                    "visit": 99,
                    "multiplier": 2
                }
            ],
            "price": 350,
            "rusts_on": "D",
            "num": 6,
            "events":[
                {"type": "brown_par"}
            ]
        },
        {
            "name": "6",
            "distance": 6,
            "price": 650,
            "num": 4,
            "events":[
                {"type": "close_companies"}
            ]
        },
        {
            "name": "8E",
            "distance":[
                {
                    "nodes":[
                        "city",
                        "offboard"
                    ],
                    "pay": 8,
                    "visit": 8
                },
                {
                    "nodes": [
                        "town"
                    ],
                    "pay": 0,
                    "visit": 99
                }
            ],
            "price": 800,
            "num": 3
        },
        {
            "name": "D",
            "distance": 999,
            "price": 900,
            "num": 20,
            "events":[
                {"type": "remove_corporations"}
            ]
        }
    ],
    "hexes": {
        "white": {
            "": [
                "B16",
                "B18",
                "B26",
                "C7",
                "C13",
                "C27",
                "D12",
                "D20",
                "D22",
                "E5",
                "E17",
                "E19",
                "F6",
                "F16",
                "F18",
                "F22",
                "G5",
                "G7",
                "G9",
                "G13",
                "G15",
                "H4",
                "H10",
                "H18",
                "I5",
                "I7",
                "I9",
                "I13",
                "I17",
                "J4",
                "J8",
                "J10",
                "J12",
                "K17"
            ],
            "border=edge:0,type:impassable": [
                "C17"
            ],
            "border=edge:2,type:impassable;border=edge:3,type:impassable": [
                "D16"
            ],
            "border=edge:2,type:impassable": [
                "F12"
            ],
            "upgrade=cost:80,terrain:water": [
                "B6",
                "B8",
                "B22",
                "C23",
                "H2",
                "I21",
                "J2"
            ],
            "border=edge:5,type:impassable;upgrade=cost:80,terrain:water": [
                "E11"
            ],
            "border=edge:2,type:impassable;upgrade=cost:120,terrain:mountain": [
                "C21"
            ],
            "upgrade=cost:120,terrain:mountain": [
                "C25",
                "D26",
                "E21",
                "E25",
                "G17",
                "G19",
                "I15",
                "J14",
                "J16"
            ],
            "city=revenue:0;upgrade=cost:80,terrain:water": [
                "B14",
                "D6",
                "F8",
                "F26",
                "I3",
                "J18"
            ],
            "city=revenue:0;border=edge:5,type:impassable": [
                "B20"
            ],
            "city=revenue:0": [
                "D8",
                "E23",
                "H6",
                "H8",
                "H12",
                "H20",
                "K15"
            ],
            "city=revenue:0;upgrade=cost:120,terrain:mountain": [
                "F20"
            ],
            "town=revenue:0": [
                "B24",
                "D10",
                "F14",
                "H14",
                "I11"
            ],
            "town=revenue:0;upgrade=cost:120,terrain:mountain;icon=image:1828/coal": [
                "K13"
            ],
            "town=revenue:0;town=revenue:0": [
                "E7",
                "F24",
                "G11",
                "G21"
            ]
        },
        "yellow": {
            "city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;upgrade=cost:80,terrain:water;border=edge:5,type:impassable": [
                "C15"
            ],
            "city=revenue:0;city=revenue:0;label=OO;upgrade=cost:80,terrain:water": [
                "D14",
                "E9"
            ],
            "city=revenue:0;city=revenue:0;label=OO": [
                "E15",
                "H22"
            ],
            "city=revenue:30;path=a:3,b:_0;path=a:5,b:_0": [
                "E27"
            ],
            "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_1;label=OO;upgrade=cost:80,terrain:water": [
                "G23"
            ],
            "city=revenue:30;path=a:0,b:_0;path=a:4,b:_0": [
                "I19"
            ],
            "city=revenue:20;path=a:1,b:_0;path=a:4,b:_0": [
                "J6"
            ]
        },
        "gray": {
            "town=revenue:20;path=a:1,b:_0;path=a:4,b:_0": [
                "A5"
            ],
            "city=revenue:30;path=a:1,b:_0;path=a:5,b:_0": [
                "A7"
            ],
            "path=a:0,b:5": [
                "A21"
            ],
            "city=revenue:40;path=a:0,b:_0;path=a:5,b:_0": [
                "A23"
            ],
            "town=revenue:10;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0": [
                "C5"
            ],
            "town=revenue:10;path=a:1,b:_0;path=a:3,b:_0": [
                "C19"
            ],
            "city=revenue:30;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
                "D4"
            ],
            "city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0": [
                "D18"
            ],
            "city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0": [
                "D24"
            ],
            "path=a:0,b:1;path=a:0,b:2": [
                "D28"
            ],
            "path=a:2,b:3": [
                "E13"
            ],
            "city=revenue:yellow_30|brown_40;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0": [
                "F10"
            ],
            "town=revenue:10;path=a:1,b:_0;path=a:2,b:_0": [
                "F28",
                "I23"
            ],
            "city=revenue:yellow_20|brown_30,loc:2.5;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:1,b:4": [
                "H16"
            ],
            "city=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;icon=image:1828/coal;icon=image:1828/coal": [
                "K11"
            ],
            "city=revenue:yellow_30|brown_40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0": [
                "K19"
            ],
            "town=revenue:10;path=a:2,b:_0;path=a:3,b:_0": [
                "L18"
            ]
        },
        "red": {
            "offboard=revenue:60;path=a:4,b:_0": [
                "A3"
            ],
            "offboard=revenue:yellow_30|brown_50,groups:Canada;path=a:4,b:5": [
                "A13"
            ],
            "city=revenue:yellow_30|brown_50,groups:Canada;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1": [
                "A15"
            ],
            "offboard=revenue:yellow_20|brown_30;path=a:0,b:_0;path=a:1,b:_0": [
                "B28"
            ],
            "offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
                "G3"
            ],
            "offboard=revenue:yellow_20|brown_60;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
                "I1"
            ],
            "offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0": [
                "K3",
                "L16"
            ]
        }
    },
    "phases": [
        {
            "name": "Yellow",
            "train_limit": 4,
            "tiles": [
                "yellow"
            ],
            "operating_rounds": 1
        },
        {
            "name": "Green",
            "on": "3",
            "train_limit": 4,
            "tiles": [
                "yellow",
                "green"
            ],
            "operating_rounds": 2,
            "status": [
                "can_buy_companies"
            ]
        },
        {
            "name": "Blue",
            "on": "5",
            "train_limit": 4,
            "tiles": [
                "yellow",
                "green"
            ],
            "operating_rounds": 2,
            "status": [
                "can_buy_companies"
            ]
        },
        {
            "name": "Brown",
            "on": "3+D",
            "train_limit": 3,
            "tiles": [
                "yellow",
                "green",
                "brown"
            ],
            "operating_rounds": 3,
            "status": [
                "can_buy_companies"
            ]
        },
        {
            "name": "Red",
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
            "name": "Gray",
            "on": "8E",
            "train_limit": 2,
            "tiles": [
                "yellow",
                "green",
                "brown"
            ],
            "operating_rounds": 3
        },
        {
            "name": "Purple",
            "on": "D",
            "train_limit": 2,
            "tiles": [
                "yellow",
                "green",
                "brown"
            ],
            "operating_rounds": 4
        }
    ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
