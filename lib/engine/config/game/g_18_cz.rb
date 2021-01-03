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
            "bankCash": 99999,
            "certLimit": {
                "3": 14,
                "4": 12,
                "5": 10,
                "6": 9
            },
            "startingCash": {
                "3": 380,
                "4": 300,
                "5": 250,
                "6": 210
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
                "E11": "Praha",
                "D2": "Cheb",
                "D4": "Karolvy Vary",
                "E15": "Pardubice",
                "C25": "Ostrava",
                "F22": "Pferov",
                "G19": "Brno",
                "I9": "Strakonice"
            },
            "tiles": {
                "1": 1,
                "2": 2,
                "7": 5,
                "8": 14,
                "9": 13,
                "3": 4,
                "58": 4,
                "4": 4,
                "5": 4,
                "6": 4,
                "57": 4,
                "201": 2,
                "202": 2,
                "621": 2,
                "55": 1,
                "56": 1,
                "69": 1,
                "16": 1,
                "19": 1,
                "20": 1,
                "23": 3,
                "24": 3,
                "25": 2,
                "26": 2,
                "27": 2,
                "28": 1,
                "29": 1,
                "30": 1,
                "31": 1,
                "14": 4,
                "15": 4,
                "619": 4,
                "208": 2,
                "207": 2,
                "622": 2,
                "611": 7,
                "216": 3,
                "39": 1,
                "40": 1,
                "41": 1,
                "42": 1,
                "43": 1,
                "44": 1,
                "45": 1,
                "46": 1,
                "47": 1,
                "70": 1,
                "8885": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO"
                },
                "8859": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;label=OO"
                },
                "8860": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:4;label=OO"
                },
                "8863": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:5;label=OO"
                },
                "8864": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:3;label=OO"
                },
                "8865": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:3,b:_1;path=a:_1,b:4;label=OO"
                },
                "8889": {
                    "count": 1,
                    "color": "yellow",
                    "code": "city=revenue:30;city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_2;label=P"
                },
                "8890": {
                    "count": 1,
                    "color": "yellow",
                    "code": "city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=P"
                },
                "8891": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;label=P"
                },
                "8892": {
                    "count": 1,
                    "color": "brown",
                    "code": "city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=P"
                },
                "8893": {
                    "count": 1,
                    "color": "gray",
                    "code": "city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=P"
                },
                "8894": {
                    "count": 1,
                    "color": "red",
                    "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
                },
                "8895": {
                    "count": 1,
                    "color": "red",
                    "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
                },
                "8896": {
                    "count": 1,
                    "color": "red",
                    "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
                },
                "8897": {
                    "count": 1,
                    "color": "red",
                    "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
                },
                "8898": {
                    "count": 1,
                    "color": "red",
                    "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50"
                },
                "8866p": {
                    "count": 2,
                    "color": "green",
                    "code": "town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;frame=color:purple"
                },
                "14p": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple"
                },
                "887p": {
                    "count": 4,
                    "color": "green",
                    "code": "town=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;path=a:2,b:_0;frame=color:purple"
                },
                "15p": {
                    "count": 1,
                    "color": "green",
                    "code": "city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;frame=color:purple"
                },
                "888p": {
                    "count": 4,
                    "color": "green",
                    "code": "town=revenue:20;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;path=a:2,b:_0;frame=color:purple"
                },
                "889p": {
                    "count": 2,
                    "color": "brown",
                    "code": "town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple"
                },
                "611p": {
                    "count": 1,
                    "color": "brown",
                    "code": "city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;frame=color:purple"
                },
                "216p": {
                    "count": 1,
                    "color": "brown",
                    "code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y;frame=color:purple"
                },
                "8894p": {
                    "count": 1,
                    "color": "brown",
                    "code": "city=revenue:60,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO;frame=color:purple"
                },
                "8895p": {
                    "count": 1,
                    "color": "brown",
                    "code": "city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO;frame=color:purple"
                },
                "8896p": {
                    "count": 1,
                    "color": "brown",
                    "code": "city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=OO;frame=color:purple"
                },
                "8857p": {
                    "count": 1,
                    "color": "gray",
                    "code": "city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y;frame=color:purple"
                },
                "595p": {
                    "count": 2,
                    "color": "gray",
                    "code": "city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;frame=color:purple"
                }
            },
            "market": [
                [
                    "40",
                    "45",
                    "50p",
                    "53p",
                    "55p",
                    "58p",
                    "60p",
                    "63p",
                    "65p",
                    "68p",
                    "70p",
                    "75p",
                    "80p",
                    "85p",
                    "90p",
                    "95p",
                    "100p",
                    "105p",
                    "110p",
                    "115p",
                    "120p",
                    "126",
                    "132",
                    "138",
                    "144",
                    "151",
                    "158",
                    "165",
                    "172",
                    "180",
                    "188",
                    "196",
                    "204",
                    "213",
                    "222",
                    "231",
                    "240",
                    "250",
                    "260",
                    "275",
                    "290",
                    "305",
                    "320",
                    "335",
                    "350",
                    "370"
                ]
            ],
            "companies": [
                {
                    "name": "Plan - Tachau",
                    "value": 25,
                    "revenue": 5,
                    "sym": "PT",
                    "abilities": []
                },
                {
                    "name": "Melnik – Mscheno",
                    "value": 30,
                    "revenue": 5,
                    "sym": "MM",
                    "abilities": []
                },
                {
                    "name": "Zwittau – Politschka",
                    "value": 35,
                    "revenue": 5,
                    "sym": "ZP",
                    "abilities": []
                },
                {
                    "name": "Wolframs – Teltsch",
                    "value": 40,
                    "revenue": 5,
                    "sym": "WT",
                    "abilities": []
                },
                {
                    "name": "Strakonitz – Blatna – Bresnitz",
                    "value": 45,
                    "revenue": 5,
                    "sym": "SBB",
                    "abilities": []
                },
                {
                    "name": "Martinitz – Rochlitz",
                    "value": 50,
                    "revenue": 5,
                    "sym": "MR",
                    "abilities": []
                },
                {
                    "name": "Raudnitz – Kmetnowes",
                    "value": 40,
                    "revenue": 10,
                    "sym": "RK",
                    "abilities": []
                },
                {
                    "name": "Schweißing – Haid",
                    "value": 45,
                    "revenue": 10,
                    "sym": "SH",
                    "abilities": []
                },
                {
                    "name": "Deutschbrod – Tischnowitz",
                    "value": 50,
                    "revenue": 10,
                    "sym": "DT",
                    "abilities": []
                },
                {
                    "name": "Troppau – Grätz",
                    "value": 55,
                    "revenue": 10,
                    "sym": "TG",
                    "abilities": []
                },
                {
                    "name": "Hannsdorf – Mährisch Altstadt",
                    "value": 60,
                    "revenue": 10,
                    "sym": "HMA",
                    "abilities": []
                },
                {
                    "name": "Friedland - Bila",
                    "value": 65,
                    "revenue": 10,
                    "sym": "FB",
                    "abilities": []
                },
                {
                    "name": "Aujezd – Luhatschowitz",
                    "value": 55,
                    "revenue": 20,
                    "sym": "AL",
                    "abilities": []
                },
                {
                    "name": "Neuhaus – Wobratain",
                    "value": 60,
                    "revenue": 20,
                    "sym": "NW",
                    "abilities": []
                },
                {
                    "name": "Opočno – Dobruschka",
                    "value": 65,
                    "revenue": 20,
                    "sym": "OD",
                    "abilities": []
                },
                {
                    "name": "Wekelsdorf – Parschnitz – Trautenau",
                    "value": 70,
                    "revenue": 20,
                    "sym": "WPT",
                    "abilities": []
                },
                {
                    "name": "Nezamislitz – Morkowitz",
                    "value": 75,
                    "revenue": 20,
                    "sym": "NM",
                    "abilities": []
                },
                {
                    "name": "Taus – Tachau",
                    "value": 80,
                    "revenue": 20,
                    "sym": "TT",
                    "abilities": []
                }
            ],
            "corporations": [
                {
                    "float_percent": 50,
                    "sym": "SX",
                    "name": "Sächsische Eisenbahn",
                    "logo": "18_cz/SX",
                    "max_ownership_percent": 60,
                    "tokens": [
                        0,
                        40
                    ],
                    "coordinates": [
                        "A7",
                        "B4"
                    ],
                    "color": "red",
                    "type": "large"
                },
                {
                    "float_percent": 50,
                    "sym": "PR",
                    "name": "Preußische Eisenbahn",
                    "logo": "18_cz/PR",
                    "max_ownership_percent": 60,
                    "tokens": [
                        0,
                        40
                    ],
                    "coordinates": [
                        "A21",
                        "B18"
                    ],
                    "color": "black",
                    "type": "large"
                },
                {
                    "float_percent": 50,
                    "sym": "BY",
                    "name": "Bayrische Staatsbahn",
                    "logo": "18_cz/BY",
                    "max_ownership_percent": 60,
                    "tokens": [
                        0,
                        40
                    ],
                    "coordinates": [
                        "F2",
                        "H4"
                    ],
                    "color": "blue",
                    "type": "large"
                },
                {
                    "float_percent": 50,
                    "sym": "kk",
                    "name": "kk Staatsbahn",
                    "logo": "18_cz/kk",
                    "max_ownership_percent": 60,
                    "tokens": [
                        0,
                        40
                    ],
                    "coordinates": [
                        "J14",
                        "I17"
                    ],
                    "color": "orange",
                    "type": "large"
                },
                {
                    "float_percent": 50,
                    "sym": "Ug",
                    "name": "Ungarische Staatsbahn",
                    "logo": "18_cz/Ug",
                    "max_ownership_percent": 60,
                    "tokens": [
                        0,
                        40
                    ],
                    "coordinates": [
                        "G27",
                        "I23"
                    ],
                    "color": "purple",
                    "type": "large"
                },
                {
                    "float_percent": 50,
                    "sym": "BN",
                    "name": "Böhmische Nordbahn",
                    "logo": "18_cz/BN",
                    "max_ownership_percent": 60,
                    "shares": [
                        40,
                        20,
                        20,
                        20
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "city": 1,
                    "coordinates": "E11",
                    "color": "grey",
                    "type": "medium"
                },
                {
                    "float_percent": 50,
                    "sym": "NWB",
                    "name": "Österreichische Nordwestbahn",
                    "logo": "18_cz/NWB",
                    "max_ownership_percent": 60,
                    "shares": [
                        40,
                        20,
                        20,
                        20
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "city": 0,
                    "coordinates": "E11",
                    "color": "yellow",
                    "text_color": "black",
                    "type": "medium"
                },
                {
                    "float_percent": 50,
                    "sym": "ATE",
                    "name": "Aussig-Teplitzer Eisenbahn",
                    "logo": "18_cz/ATE",
                    "max_ownership_percent": 60,
                    "shares": [
                        40,
                        20,
                        20,
                        20
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "color": "gold",
                    "text_color": "black",
                    "coordinates": "B8",
                    "type": "medium"
                },
                {
                    "float_percent": 50,
                    "sym": "BTE",
                    "name": "Buschtehrader Eisenbahn",
                    "logo": "18_cz/BTE",
                    "max_ownership_percent": 60,
                    "shares": [
                        40,
                        20,
                        20,
                        20
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "coordinates": "D2",
                    "color": "brightGreen",
                    "text_color": "black",
                    "type": "medium"
                },
                {
                    "float_percent": 50,
                    "sym": "KFN",
                    "name": "Kaiser Ferdinands Nordbahn",
                    "logo": "18_cz/KFN",
                    "max_ownership_percent": 60,
                    "shares": [
                        40,
                        20,
                        20,
                        20
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "coordinates": "G19",
                    "color": "lightBlue",
                    "type": "medium"
                },
                {
                    "float_percent": 50,
                    "sym": "EKJ",
                    "name": "Eisenbahn Karlsbad – Johanngeorgenstadt",
                    "logo": "18_cz/EKJ",
                    "max_ownership_percent": 75,
                    "shares": [
                        50,
                        25,
                        25
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "coordinates": "D4",
                    "color": "white",
                    "text_color": "black",
                    "type": "small"
                },
                {
                    "float_percent": 50,
                    "sym": "OFE",
                    "name": "Ostrau-Friedlander Eisenbahn",
                    "logo": "18_cz/OFE",
                    "max_ownership_percent": 75,
                    "shares": [
                        50,
                        25,
                        25
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "coordinates": "C25",
                    "color": "lightRed",
                    "text_color": "black",
                    "type": "small"
                },
                {
                    "float_percent": 50,
                    "sym": "BCB",
                    "name": "Böhmische Commercialbahn",
                    "logo": "18_cz/BCB",
                    "max_ownership_percent": 75,
                    "shares": [
                        50,
                        25,
                        25
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "coordinates": "E15",
                    "color": "orange",
                    "text_color": "black",
                    "type": "small"
                },
                {
                    "float_percent": 50,
                    "sym": "MW",
                    "name": "Mährische Westbahn",
                    "logo": "18_cz/MW",
                    "max_ownership_percent": 75,
                    "shares": [
                        50,
                        25,
                        25
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "coordinates": "F22",
                    "color": "mintGreen",
                    "text_color": "black",
                    "type": "small"
                },
                {
                    "float_percent": 50,
                    "sym": "VBW",
                    "name": "Vereinigte Böhmerwaldbahnen",
                    "logo": "18_cz/VBW",
                    "max_ownership_percent": 75,
                    "shares": [
                        50,
                        25,
                        25
                    ],
                    "tokens": [
                        0,
                        40,
                        100
                    ],
                    "coordinates": "I9",
                    "color": "turquoise",
                    "type": "small"
                }
            ],
            "trains": [
                {
                    "name": "2a",
                    "distance": 2,
                    "price": 70,
                    "rusts_on": "4e",
                    "num": 5
                },
                {
                    "name": "2b",
                    "distance": 2,
                    "price": 70,
                    "rusts_on": "4e",
                    "num": 4,
                    "variants": [
                        {
                            "name": "2+2b",
                            "rusts_on": "4+4e",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 2,
                                    "visit": 2
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 2,
                                    "visit": 2
                                }
                            ],
                            "price": 80
                        }
                    ],
                    "events": [
                        {
                            "type": "medium_corps_available"
                        }
                    ]
                },
                {
                    "name": "3c",
                    "distance": 3,
                    "price": 120,
                    "rusts_on": "5g",
                    "num": 4,
                    "variants": [
                        {
                            "name": "2+2c",
                            "rusts_on": "4+4f",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 2,
                                    "visit": 2
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 2,
                                    "visit": 2
                                }
                            ],
                            "price": 80
                        }
                    ]
                },
                {
                    "name": "3d",
                    "distance": 3,
                    "price": 120,
                    "rusts_on": "5g",
                    "num": 4,
                    "variants": [
                        {
                            "name": "3+3d",
                            "rusts_on": "5+5h",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 3,
                                    "visit": 3
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 3,
                                    "visit": 3
                                }
                            ],
                            "price": 180
                        },
                        {
                            "name": "3Ed",
                            "rusts_on": "5E",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 3,
                                    "visit": 3
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 0,
                                    "visit": 99
                                }
                            ],
                            "price": 250
                        }
                    ],
                    "events": [
                        {
                            "type": "large_corps_available"
                        }
                    ]
                },
                {
                    "name": "4e",
                    "distance": 4,
                    "price": 250,
                    "num": 4,
                    "variants": [
                        {
                            "name": "3+3e",
                            "rusts_on": "5+5h",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 3,
                                    "visit": 3
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 3,
                                    "visit": 3
                                }
                            ],
                            "price": 180
                        },
                        {
                            "name": "3Ee",
                            "rusts_on": "5E",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 3,
                                    "visit": 3
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 0,
                                    "visit": 99
                                }
                            ],
                            "price": 250
                        }
                    ]
                },
                {
                    "name": "4f",
                    "distance": 4,
                    "price": 250,
                    "num": 4,
                    "variants": [
                        {
                            "name": "4+4f",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 4,
                                    "visit": 4
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 4,
                                    "visit": 4
                                }
                            ],
                            "price": 400
                        },
                        {
                            "name": "4Ef",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 4,
                                    "visit": 4
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 0,
                                    "visit": 99
                                }
                            ],
                            "price": 350
                        }
                    ]
                },
                {
                    "name": "5g",
                    "distance": 4,
                    "price": 350,
                    "num": 4,
                    "variants": [
                        {
                            "name": "4+4g",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 4,
                                    "visit": 4
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 4,
                                    "visit": 4
                                }
                            ],
                            "price": 400
                        },
                        {
                            "name": "4Eg",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 4,
                                    "visit": 4
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 0,
                                    "visit": 99
                                }
                            ],
                            "price": 350
                        }
                    ]
                },
                {
                    "name": "5h",
                    "distance": 4,
                    "price": 350,
                    "num": 2,
                    "variants": [
                        {
                            "name": "5+5h",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 5,
                                    "visit": 5
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 5,
                                    "visit": 5
                                }
                            ],
                            "price": 500
                        },
                        {
                            "name": "5E",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 5,
                                    "visit": 5
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 0,
                                    "visit": 99
                                }
                            ],
                            "price": 700
                        }
                    ]
                },
                {
                    "name": "5i",
                    "distance": 4,
                    "price": 350,
                    "num": 2,
                    "variants": [
                        {
                            "name": "5+5i",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 5,
                                    "visit": 5
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 5,
                                    "visit": 5
                                }
                            ],
                            "price": 500
                        },
                        {
                            "name": "6E",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 6,
                                    "visit": 6
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 0,
                                    "visit": 99
                                }
                            ],
                            "price": 800
                        }
                    ]
                },
                {
                    "name": "5j",
                    "distance": 4,
                    "price": 350,
                    "num": 30,
                    "variants": [
                        {
                            "name": "5+5j",
                            "distance": [
                                {
                                    "nodes": [
                                        "city",
                                        "offboard"
                                    ],
                                    "pay": 5,
                                    "visit": 5
                                },
                                {
                                    "nodes": [
                                        "town"
                                    ],
                                    "pay": 5,
                                    "visit": 5
                                }
                            ],
                            "price": 500
                        },
                        {
                            "name": "8E",
                            "distance": [
                                {
                                    "nodes": [
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
                            "price": 1000
                        }
                    ]
                }
            ],
            "hexes": {
                "white": {
                    "": [
                        "A11",
                        "B24",
                        "C15",
                        "D6",
                        "D8",
                        "D18",
                        "D20",
                        "D22",
                        "D24",
                        "E7",
                        "E17",
                        "E19",
                        "E23",
                        "E25",
                        "F8",
                        "F14",
                        "F16",
                        "F18",
                        "F24",
                        "G7",
                        "H8",
                        "H12",
                        "H20"
                    ],
                    "border=edge:5,type:impassible": [
                        "H22",
                        "I13"
                    ],
                    "border=edge:4,type:impassible": [
                        "J12",
                        "I21",
                        "G25"
                    ],
                    "border=edge:2,type:impassible": [
                        "B22"
                    ],
                    "border=edge:1,type:impassible": [
                        "F4",
                        "I19"
                    ],
                    "border=edge:2,type:impassible;border=edge:5,type:impassible": [
                        "G3"
                    ],
                    "border=edge:0,type:impassible": [
                        "G5",
                        "H18",
                        "H24"
                    ],
                    "upgrade=cost:40,terrain:mountain": [
                        "A15",
                        "C21",
                        "I7"
                    ],
                    "upgrade=cost:40,terrain:mountain;border=edge:1,type:impassible;border=edge:3,type:impassible": [
                        "B20"
                    ],
                    "upgrade=cost:40,terrain:mountain;border=edge:3,type:impassible": [
                        "C3"
                    ],
                    "upgrade=cost:40,terrain:mountain;border=edge:3,type:impassible;border=edge:1,type:impassible": [
                        "B6"
                    ],
                    "upgrade=cost:20,terrain:mountain": [
                        "A13",
                        "D28",
                        "E27",
                        "E5",
                        "H14",
                        "G13"
                    ],
                    "upgrade=cost:20,terrain:mountain;border=edge:5,type:impassible": [
                        "F26"
                    ],
                    "town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:2,type:impassible": [
                        "C5"
                    ],
                    "town=revenue:0;upgrade=cost:20,terrain:mountain": [
                        "J10",
                        "G17"
                    ],
                    "town=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:5,type:impassible": [
                        "H16"
                    ],
                    "town=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:1,type:impassible": [
                        "H6"
                    ],
                    "town=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:4,type:impassible": [
                        "B16"
                    ],
                    "city=revenue:0;upgrade=cost:20,terrain:mountain": [
                        "G15"
                    ],
                    "upgrade=cost:10,terrain:water": [
                        "D10",
                        "D12",
                        "D14",
                        "G9",
                        "H10"
                    ],
                    "upgrade=cost:10,terrain:water;border=edge:3,type:impassible": [
                        "C17"
                    ],
                    "town=revenue:0;upgrade=cost:10,terrain:water": [
                        "F10",
                        "C9",
                        "C11"
                    ],
                    "town=revenue:0;upgrade=cost:10,terrain:water;border=edge:1,type:impassible": [
                        "A9"
                    ],
                    "city=revenue:0;upgrade=cost:10,terrain:water": [
                        "D16",
                        "E15"
                    ],
                    "city=revenue:0": [
                        "B10",
                        "C23",
                        "E21",
                        "G23",
                        "G11",
                        "E9",
                        "D2",
                        "D4",
                        "F22"
                    ],
                    "city=revenue:0;label=Y": [
                        "B12",
                        "I11",
                        "F6",
                        "C25",
                        "G19",
                        "I9"
                    ],
                    "town=revenue:0": [
                        "C13",
                        "F12",
                        "G21",
                        "C27"
                    ],
                    "town=revenue:0;border=edge:0,type:impassible": [
                        "E3"
                    ],
                    "town=revenue:0;border=edge:5,type:impassible": [
                        "E1"
                    ],
                    "town=revenue:0;border=edge:2,type:impassible": [
                        "C19"
                    ],
                    "town=revenue:0;town=revenue:0": [
                        "E13",
                        "F20",
                        "B14"
                    ],
                    "city=revenue:20;city=revenue:20;path=a:5,b:_0;path=a:3,b:_1;label=P;upgrade=cost:10,terrain:water": [
                        "E11"
                    ],
                    "label=SX;border=edge:0,type:impassible;border=edge:5,type:impassible;border=edge:4,type:impassible": [
                        "A7",
                        "B4"
                    ],
                    "label=PR;border=edge:0,type:impassible;border=edge:5,type:impassible;border=edge:4,type:impassible;border=edge:1,type:impassible": [
                        "B18"
                    ],
                    "label=PR;border=edge:0,type:impassible;border=edge:5,type:impassible": [
                        "A21"
                    ],
                    "label=BY;border=edge:2,type:impassible;border=edge:3,type:impassible;border=edge:4,type:impassible": [
                        "H4"
                    ],
                    "label=BY;border=edge:2,type:impassible;border=edge:3,type:impassible;border=edge:4,type:impassible;border=edge:5,type:impassible": [
                        "F2"
                    ],
                    "label=kk;border=edge:2,type:impassible;border=edge:3,type:impassible;border=edge:4,type:impassible": [
                        "I17"
                    ],
                    "label=kk;border=edge:1,type:impassible;border=edge:2,type:impassible": [
                        "J14"
                    ],
                    "label=Ug;border=edge:1,type:impassible;border=edge:2,type:impassible;border=edge:3,type:impassible": [
                        "I23"
                    ],
                    "label=Ug;border=edge:1,type:impassible;border=edge:2,type:impassible": [
                        "G27"
                    ]
                },
                "yellow": {
                    "city=revenue:0;city=revenue:0;label=OO": [
                        "D26",
                        "C7"
                    ],
                    "city=revenue:0;city=revenue:0;label=OO;upgrade=cost:10,terrain:water;border=edge:2,type:impassible": [
                        "B8"
                    ]
                }
            },
            "phases": [
                {
                    "name": "a",
                    "train_limit": {
                        "small": 3
                    },
                    "tiles": [
                        "yellow"
                    ],
                    "operating_rounds": 1
                },
                {
                    "name": "b",
                    "on": "2b",
                    "train_limit": {
                        "small": 3,
                        "medium": 3
                    },
                    "tiles": [
                        "yellow"
                    ],
                    "operating_rounds": 1
                },
                {
                    "name": "c",
                    "on": "3c",
                    "train_limit": {
                        "small": 3,
                        "medium": 3
                    },
                    "tiles": [
                        "yellow"
                    ],
                    "operating_rounds": 1
                },
                {
                    "name": "d",
                    "on": "3d",
                    "train_limit": {
                        "small": 3,
                        "medium": 3,
                        "large": 3
                    },
                    "tiles": [
                        "yellow",
                        "green"
                    ],
                    "operating_rounds": 1,
                    "status": [
                        "can_buy_companies"
                    ]
                },
                {
                    "name": "e",
                    "on": "4e",
                    "train_limit": {
                        "small": 2,
                        "medium": 3,
                        "large": 3
                    },
                    "tiles": [
                        "yellow",
                        "green"
                    ],
                    "operating_rounds": 1,
                    "status": [
                        "can_buy_companies"
                    ]
                },
                {
                    "name": "f",
                    "on": "4f",
                    "train_limit": {
                        "small": 2,
                        "medium": 2,
                        "large": 3
                    },
                    "tiles": [
                        "yellow",
                        "green"
                    ],
                    "operating_rounds": 1,
                    "status": [
                        "can_buy_companies"
                    ]
                },
                {
                    "name": "g",
                    "on": "5g",
                    "train_limit": {
                        "small": 2,
                        "medium": 2,
                        "large": 3
                    },
                    "tiles": [
                        "yellow",
                        "green",
                        "brown"
                    ],
                    "operating_rounds": 1
                },
                {
                    "name": "h",
                    "on": "5h",
                    "train_limit": {
                        "small": 1,
                        "medium": 2,
                        "large": 3
                    },
                    "tiles": [
                        "yellow",
                        "green",
                        "brown"
                    ],
                    "operating_rounds": 1
                },
                {
                    "name": "i",
                    "on": "5i",
                    "train_limit": {
                        "small": 1,
                        "medium": 1,
                        "large": 3
                    },
                    "tiles": [
                        "yellow",
                        "green",
                        "brown",
                        "gray"
                    ],
                    "operating_rounds": 1
                },
                {
                    "name": "j",
                    "on": "5j",
                    "train_limit": {
                        "small": 1,
                        "medium": 1,
                        "large": 2
                    },
                    "tiles": [
                        "yellow",
                        "green",
                        "brown",
                        "gray"
                    ],
                    "operating_rounds": 1
                }
            ]
        }
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
