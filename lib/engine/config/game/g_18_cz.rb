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
                  "G16": "Jihlava",
                  "D17": "Hradec Kralove",
                  "B11": "Decin",
                  "B13": "Liberec",
                  "C24": "Opava",
                  "E22": "Olomouc",
                  "G24": "Hulin",
                  "G12": "Tabor",
                  "I12": "Ceske Budejovice",
                  "F7": "Pilzen",
                  "E10": "Kladno",
                  "B9": "Teplice & Ustid nad Labem",
                  "D27": "Frydland & Frydek",
                  "C8": "Chomutov & Most",
                  "E12": "Praha",
                  "D3": "Cheb",
                  "D5": "Karolvy Vary",
                  "E16": "Pardubice",
                  "C26": "Ostrava",
                  "F23": "Pferov",
                  "G20": "Brno",
                  "I10": "Strakonice"
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
                      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50;label=Ug"
                  },
                  "8895": {
                      "count": 1,
                      "color": "red",
                      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50;label=kk"
                  },
                  "8896": {
                      "count": 1,
                      "color": "red",
                      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50;label=SX"
                  },
                  "8897": {
                      "count": 1,
                      "color": "red",
                      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50;label=PR"
                  },
                  "8898": {
                      "count": 1,
                      "color": "red",
                      "code": "city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;icon=image:18_cz/50;label=BY"
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
                      "53",
                      "55p",
                      "58",
                      "60pP",
                      "63",
                      "65p",
                      "68",
                      "70pP",
                      "75",
                      "80P",
                      "85",
                      "90zP",
                      "95",
                      "100zP",
                      "105",
                      "110z",
                      "115",
                      "120z",
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
                      "name": "Small #1",
                      "value": 25,
                      "revenue": 5,
                      "sym": "S1",
                      "desc":"May either ignore the cost to build a river tile or lay a special purple-edged tile on yellow cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Small #2",
                      "value": 30,
                      "revenue": 5,
                      "sym": "S2",
                      "desc":"May either ignore the cost to build a river tile or lay a special purple-edged tile on yellow cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Small #3",
                      "value": 35,
                      "revenue": 5,
                      "sym": "S3",
                      "desc":"May either ignore the cost to build a river tile or lay a special purple-edged tile on yellow cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Small #4",
                      "value": 40,
                      "revenue": 5,
                      "sym": "S4",
                      "desc":"May either ignore the cost to build a river tile or lay a special purple-edged tile on yellow cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Small #5",
                      "value": 45,
                      "revenue": 5,
                      "sym": "S5",
                      "desc":"May either ignore the cost to build a river tile or lay a special purple-edged tile on yellow cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Small #6",
                      "value": 50,
                      "revenue": 5,
                      "sym": "S6",
                      "desc":"May either ignore the cost to build a river tile or lay a special purple-edged tile on yellow cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Medium #1",
                      "value": 40,
                      "revenue": 10,
                      "sym": "M1",
                      "desc":"May either ignore the cost to build a river or hill tile or lay a special purple-edged tile on yellow or green cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Medium #2",
                      "value": 45,
                      "revenue": 10,
                      "sym": "M2",
                      "desc":"May either ignore the cost to build a river or hill tile or lay a special purple-edged tile on yellow or green cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Medium #3",
                      "value": 50,
                      "revenue": 10,
                      "sym": "M3",
                      "desc":"May either ignore the cost to build a river or hill tile or lay a special purple-edged tile on yellow or green cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Medium #4",
                      "value": 55,
                      "revenue": 10,
                      "sym": "M4",
                      "desc":"May either ignore the cost to build a river or hill tile or lay a special purple-edged tile on yellow or green cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Medium #5",
                      "value": 60,
                      "revenue": 10,
                      "sym": "M5",
                      "desc":"May either ignore the cost to build a river or hill tile or lay a special purple-edged tile on yellow or green cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Medium #6",
                      "value": 65,
                      "revenue": 10,
                      "sym": "M6",
                      "desc":"May either ignore the cost to build a river or hill tile or lay a special purple-edged tile on yellow or green cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Large #1",
                      "value": 55,
                      "revenue": 20,
                      "sym": "L1",
                      "desc":"May either ignore the cost to build a river, hill or mountain tile or lay a special purple-edged tile on yellow, green or brown cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p",
                                 "595p",
                                 "8857p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 40,
                              "terrain": "mountain"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Large #2",
                      "value": 60,
                      "revenue": 20,
                      "sym": "L2",
                      "desc":"May either ignore the cost to build a river, hill or mountain tile or lay a special purple-edged tile on yellow, green or brown cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p",
                                 "595p",
                                 "8857p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 40,
                              "terrain": "mountain"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Large #3",
                      "value": 65,
                      "revenue": 20,
                      "sym": "L3",
                      "desc":"May either ignore the cost to build a river, hill or mountain tile or lay a special purple-edged tile on yellow, green or brown cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p",
                                 "595p",
                                 "8857p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 40,
                              "terrain": "mountain"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Large #4",
                      "value": 70,
                      "revenue": 20,
                      "sym": "L4",
                      "desc":"May either ignore the cost to build a river, hill or mountain tile or lay a special purple-edged tile on yellow, green or brown cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p",
                                 "595p",
                                 "8857p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 40,
                              "terrain": "mountain"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Large #5",
                      "value": 75,
                      "revenue": 20,
                      "sym": "L5",
                      "desc":"May either ignore the cost to build a river, hill or mountain tile or lay a special purple-edged tile on yellow, green or brown cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p",
                                 "595p",
                                 "8857p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 40,
                              "terrain": "mountain"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  },
                  {
                      "name": "Large #6",
                      "value": 80,
                      "revenue": 20,
                      "sym": "L6",
                      "desc":"May either ignore the cost to build a river, hill or mountain tile or lay a special purple-edged tile on yellow, green or brown cities",
                      "abilities": [
                          {
                              "type":"tile_lay",
                              "count": 1,
                              "owner_type":"corporation",
                              "tiles":[
                                 "14p",
                                 "15p",
                                 "887p",
                                 "888p",
                                 "8866p",
                                 "216p",
                                 "611p",
                                 "889p",
                                 "8894p",
                                 "8895p",
                                 "8896p",
                                 "595p",
                                 "8857p"
                              ],
                              "when": "owning_corp_or_turn",
                              "hexes": [],
                              "reachable": true,
                              "special": false
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 10,
                              "terrain": "river"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 20,
                              "terrain": "hill"
                          },
                          {
                              "type":"tile_discount",
                              "count": 1,
                              "when": "owning_corp_or_turn",
                              "owner_type":"corporation",
                              "discount": 40,
                              "terrain": "mountain"
                          },
                          {
                            "type":"sell_company",
                            "when": "owning_corp_or_turn"
                          }
                      ]
                  }
              ],
              "corporations": [
                  {
                      "float_percent": 50,
                      "sym": "SX",
                      "name": "Sächsische Eisenbahn",
                      "logo": "18_cz/SX",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
                      "tokens": [
                          0,
                          40
                      ],
                      "coordinates": [
                          "A8",
                          "B5"
                      ],
                      "color": "#e31e24",
                      "type": "large"
                  },
                  {
                      "float_percent": 50,
                      "sym": "PR",
                      "name": "Preußische Eisenbahn",
                      "logo": "18_cz/PR",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
                      "tokens": [
                          0,
                          40
                      ],
                      "coordinates": [
                          "A22",
                          "B19"
                      ],
                      "color": "#2b2a29",
                      "type": "large"
                  },
                  {
                      "float_percent": 50,
                      "sym": "BY",
                      "name": "Bayrische Staatsbahn",
                      "logo": "18_cz/BY",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
                      "tokens": [
                          0,
                          40
                      ],
                      "coordinates": [
                          "F3",
                          "H5"
                      ],
                      "color": "#0971b7",
                      "type": "large"
                  },
                  {
                      "float_percent": 50,
                      "sym": "kk",
                      "name": "kk Staatsbahn",
                      "logo": "18_cz/kk",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
                      "tokens": [
                          0,
                          40
                      ],
                      "coordinates": [
                          "J15",
                          "I18"
                      ],
                      "color": "#cc6f3c",
                      "type": "large"
                  },
                  {
                      "float_percent": 50,
                      "sym": "Ug",
                      "name": "Ungarische Staatsbahn",
                      "logo": "18_cz/Ug",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
                      "tokens": [
                          0,
                          40
                      ],
                      "coordinates": [
                          "G28",
                          "I24"
                      ],
                      "color": "#ae4a84",
                      "type": "large"
                  },
                  {
                      "float_percent": 50,
                      "sym": "BN",
                      "name": "Böhmische Nordbahn",
                      "logo": "18_cz/BN",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
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
                      "coordinates": "E12",
                      "color": "darkGrey",
                      "text_color": "black",
                      "type": "medium"
                  },
                  {
                      "float_percent": 50,
                      "sym": "NWB",
                      "name": "Österreichische Nordwestbahn",
                      "logo": "18_cz/NWB",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
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
                      "coordinates": "E12",
                      "color": "#e1af33",
                      "text_color": "black",
                      "type": "medium"
                  },
                  {
                      "float_percent": 50,
                      "sym": "ATE",
                      "name": "Aussig-Teplitzer Eisenbahn",
                      "logo": "18_cz/ATE",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
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
                      "coordinates": "B9",
                      "type": "medium"
                  },
                  {
                      "float_percent": 50,
                      "sym": "BTE",
                      "name": "Buschtehrader Eisenbahn",
                      "logo": "18_cz/BTE",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
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
                      "coordinates": "D3",
                      "color": "#dbe285",
                      "text_color": "black",
                      "type": "medium"
                  },
                  {
                      "float_percent": 50,
                      "sym": "KFN",
                      "name": "Kaiser Ferdinands Nordbahn",
                      "logo": "18_cz/KFN",
                      "max_ownership_percent": 60,
                      "always_market_price": true,
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
                      "coordinates": "G20",
                      "color": "#a2d9f7",
                      "text_color": "black",
                      "type": "medium"
                  },
                  {
                      "float_percent": 50,
                      "sym": "EKJ",
                      "name": "Eisenbahn Karlsbad Johanngeorgenstadt",
                      "logo": "18_cz/EKJ",
                      "max_ownership_percent": 75,
                      "always_market_price": true,
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
                      "coordinates": "D5",
                      "color": "antiqueWhite",
                      "text_color": "black",
                      "type": "small"
                  },
                  {
                      "float_percent": 50,
                      "sym": "OFE",
                      "name": "Ostrau-Friedlander Eisenbahn",
                      "logo": "18_cz/OFE",
                      "max_ownership_percent": 75,
                      "always_market_price": true,
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
                      "coordinates": "C26",
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
                      "always_market_price": true,
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
                      "coordinates": "E16",
                      "color": "#fabc48",
                      "text_color": "black",
                      "type": "small"
                  },
                  {
                      "float_percent": 50,
                      "sym": "MW",
                      "name": "Mährische Westbahn",
                      "logo": "18_cz/MW",
                      "max_ownership_percent": 75,
                      "always_market_price": true,
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
                      "coordinates": "F23",
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
                      "always_market_price": true,
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
                      "coordinates": "I10",
                      "color": "#009846",
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
                                      "pay": 3,
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
                                      "pay": 3,
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
                                      "pay": 3,
                                      "visit": 99
                                  }
                              ],
                              "price": 350
                          }
                      ]
                  },
                  {
                      "name": "5g",
                      "distance": 5,
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
                                      "pay": 3,
                                      "visit": 99
                                  }
                              ],
                              "price": 350
                          }
                      ]
                  },
                  {
                      "name": "5h",
                      "distance": 5,
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
                                      "pay": 3,
                                      "visit": 99
                                  }
                              ],
                              "price": 700
                          }
                      ]
                  },
                  {
                      "name": "5i",
                      "distance": 5,
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
                                      "pay": 3,
                                      "visit": 99
                                  }
                              ],
                              "price": 800
                          }
                      ]
                  },
                  {
                      "name": "5j",
                      "distance": 5,
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
                                      "pay": 3,
                                      "visit": 99
                                  }
                              ],
                              "price": 1000
                          }
                      ]
                  }
              ],
              "hexes": {
                  "gray": {
                      "town=revenue:10;path=a:4,b:_0;path=a:5,b:_0": [
                          "D1"
                      ]
                  },
                  "white": {
                      "": [
                          "A12",
                          "B25",
                          "C16",
                          "D7",
                          "D9",
                          "D19",
                          "D21",
                          "D23",
                          "D25",
                          "E8",
                          "E18",
                          "E20",
                          "E24",
                          "E26",
                          "F9",
                          "F15",
                          "F17",
                          "F19",
                          "F25",
                          "G8",
                          "H9",
                          "H13",
                          "H21"
                      ],
                      "border=edge:5,type:offboard": [
                          "H23",
                          "I14"
                      ],
                      "border=edge:4,type:offboard": [
                          "J13",
                          "I22",
                          "G26"
                      ],
                      "border=edge:2,type:offboard": [
                          "B23"
                      ],
                      "border=edge:1,type:offboard": [
                          "F5",
                          "I20"
                      ],
                      "border=edge:2,type:offboard;border=edge:5,type:offboard": [
                          "G4"
                      ],
                      "border=edge:0,type:offboard": [
                          "G6",
                          "H19",
                          "H25"
                      ],
                      "upgrade=cost:40,terrain:mountain": [
                          "A16",
                          "C22",
                          "I8"
                      ],
                      "upgrade=cost:40,terrain:mountain;border=edge:1,type:offboard;border=edge:3,type:offboard": [
                          "B21"
                      ],
                      "upgrade=cost:40,terrain:mountain;border=edge:3,type:offboard": [
                          "C4"
                      ],
                      "upgrade=cost:40,terrain:mountain;border=edge:3,type:offboard;border=edge:1,type:offboard": [
                          "B7"
                      ],
                      "upgrade=cost:20,terrain:hill": [
                          "A14",
                          "D29",
                          "E28",
                          "E6",
                          "H15",
                          "G14"
                      ],
                      "upgrade=cost:20,terrain:hill;border=edge:5,type:offboard": [
                          "F27"
                      ],
                      "town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:2,type:offboard": [
                          "C6"
                      ],
                      "town=revenue:0;upgrade=cost:20,terrain:hill": [
                          "J11",
                          "G18"
                      ],
                      "town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:5,type:offboard": [
                          "H17"
                      ],
                      "town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:1,type:offboard": [
                          "H7"
                      ],
                      "town=revenue:0;upgrade=cost:20,terrain:hill;border=edge:4,type:offboard": [
                          "B17"
                      ],
                      "city=revenue:0;upgrade=cost:20,terrain:hill": [
                          "G16"
                      ],
                      "upgrade=cost:10,terrain:water": [
                          "D11",
                          "D15",
                          "G10",
                          "H11"
                      ],
                      "upgrade=cost:10,terrain:water;stub=edge:0": [
                          "D13"
                      ],
                      "upgrade=cost:10,terrain:water;border=edge:3,type:offboard": [
                          "C18"
                      ],
                      "town=revenue:0;upgrade=cost:10,terrain:water": [
                          "F11",
                          "C10",
                          "C12"
                      ],
                      "town=revenue:0;upgrade=cost:10,terrain:water;border=edge:1,type:offboard": [
                          "A10"
                      ],
                      "city=revenue:0;upgrade=cost:10,terrain:water": [
                          "D17",
                          "E16"
                      ],
                      "city=revenue:0": [
                          "B11",
                          "C24",
                          "E22",
                          "G24",
                          "G12",
                          "E10",
                          "D3",
                          "D5",
                          "F23",
                          "I10"
                      ],
                      "city=revenue:0;label=Y": [
                          "B13",
                          "I12",
                          "F7",
                          "C26",
                          "G20"
                      ],
                      "town=revenue:0": [
                          "C14",
                          "G22",
                          "C28"
                      ],
                      "town=revenue:0;stub=edge:2": [
                          "F13"
                      ],
                      "town=revenue:0;border=edge:0,type:offboard": [
                          "E4"
                      ],
                      "town=revenue:0;border=edge:5,type:offboard": [
                          "E2"
                      ],
                      "town=revenue:0;border=edge:2,type:offboard": [
                          "C20"
                      ],
                      "town=revenue:0;town=revenue:0": [
                          "E14",
                          "F21",
                          "B15"
                      ],
                      "city=revenue:20;city=revenue:20;path=a:5,b:_0;path=a:3,b:_1;label=P;upgrade=cost:10,terrain:water": [
                          "E12"
                      ],
                      "label=SX;border=edge:0,type:offboard;border=edge:5,type:offboard;border=edge:4,type:offboard": [
                          "A8",
                          "B5"
                      ],
                      "label=PR;border=edge:0,type:offboard;border=edge:5,type:offboard;border=edge:4,type:offboard;border=edge:1,type:offboard": [
                          "B19"
                      ],
                      "label=PR;border=edge:0,type:offboard;border=edge:5,type:offboard": [
                          "A22"
                      ],
                      "label=BY;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard": [
                          "H5"
                      ],
                      "label=BY;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard;border=edge:5,type:offboard": [
                          "F3"
                      ],
                      "label=kk;border=edge:2,type:offboard;border=edge:3,type:offboard;border=edge:4,type:offboard": [
                          "I18"
                      ],
                      "label=kk;border=edge:1,type:offboard;border=edge:2,type:offboard": [
                          "J15"
                      ],
                      "label=Ug;border=edge:1,type:offboard;border=edge:2,type:offboard;border=edge:3,type:offboard": [
                          "I24"
                      ],
                      "label=Ug;border=edge:1,type:offboard;border=edge:2,type:offboard": [
                          "G28"
                      ]
                  },
                  "yellow": {
                      "city=revenue:0;city=revenue:0;label=OO": [
                          "D27",
                          "C8"
                      ],
                      "city=revenue:0;city=revenue:0;label=OO;upgrade=cost:10,terrain:water;border=edge:2,type:offboard": [
                          "B9"
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
                      "corporation_sizes": ["small"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium", "large"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium", "large"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium", "large"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium", "large"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium", "large"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium", "large"]
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
                      "status": [
                          "can_buy_companies"
                      ],
                      "corporation_sizes": ["small", "medium", "large"]
                  }
              ]
          }
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
