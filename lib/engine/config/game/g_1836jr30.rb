# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1836jr30
        JSON = <<-'DATA'
{
   "filename":"1836jr30",
   "modulename":"1836Jr-30",
   "currencyFormatStr":"F%d",
   "bankCash":6000,
   "certLimit":{
      "2":20,
      "3":13,
      "4":10
   },
   "startingCash":{
      "2":900,
      "3":600,
      "4":450
   },
   "layout":"pointy",
   "axes":{
      "rows":"letters",
      "columns":"numbers"
   },
   "locationNames":{
      "A9":"Leeuwarden",
      "A13":"Hamburg",
      "B8":"Enkhuizen & Stavoren",
      "B10":"Groningen",
      "D6":"Amsterdam",
      "E5":"Rotterdam & Den Haag",
      "E7":"Utrecht",
      "E11":"Arnhem & Nijmegen",
      "F4":"Hoek van Holland",
      "F10":"Eindhoven",
      "G7":"Antwerp",
      "H2":"Bruges",
      "H4":"Gand",
      "H6":"Brussels",
      "H10":"Maastricht & Liège",
      "I3":"Lille",
      "I9":"Namur",
      "J6":"Charleroi",
      "J8":"Hainaut Coalfields",
      "E3":"Harwich",
      "G1":"Dover",
      "J2":"Paris",
      "E13":"Dortmund",
      "H12":"Cologne",
      "K11":"Arlon & Luxembourg",
      "K13":"Strasbourg"
   },
   "tiles":{
      "2":1,
      "3":2,
      "4":2,
      "7":4,
      "8":8,
      "9":7,
      "14":3,
      "15":2,
      "16":1,
      "18":1,
      "19":1,
      "20":1,
      "23":3,
      "24":3,
      "25":1,
      "26":1,
      "27":1,
      "28":1,
      "29":1,
      "39":1,
      "40":1,
      "41":2,
      "42":2,
      "43":2,
      "44":1,
      "45":2,
      "46":2,
      "47":1,
      "53":2,
      "54":1,
      "56":1,
      "57":4,
      "58":2,
      "59":2,
      "61":2,
      "62":1,
      "63":3,
      "64":1,
      "65":1,
      "66":1,
      "67":1,
      "68":1,
      "70":1
   },
   "market":[
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
   "companies":[
      {
         "name":"Amsterdam Canal Company",
         "value":20,
         "revenue":5,
         "desc":"No special ability. Blocks hex D6 while owned by player.",
         "abilities":[
            {
               "type":"blocks_hexes",
               "owner_type":"player",
               "hexes":[
                  "D6"
               ]
            }
          ]
      },
      {
         "name":"Enkhuizen-Stavoren Ferry",
         "value":40,
         "revenue":10,
         "desc":"Owning corporation may place a free tile on the E-SF hex B8 (the IJsselmeer Causeway) free of cost, in addition to its own tile placement. Blocks hex B8 while owned by player.",
         "abilities":[
            {
               "type":"blocks_hexes",
               "owner_type":"player",
               "hexes":[
                  "B8"
               ]
            },
            {
               "type":"tile_lay",
               "owner_type":"corporation",
               "hexes":[
                  "B8"
               ],
               "when":"track",
               "count":1
            }
         ]
      },
      {
         "name":"Charbonnages du Hainaut",
         "value":70,
         "revenue":15,
         "desc":"Owning corporation may place a tile and station token in the CdH hex J8 for only the F60 cost of the mountain. The track is not required to be connected to existing track of this corporation (or any corporation), and can be used as a teleport. This counts as the corporation's track lay for that turn. Blocks hex J8 while owned by player.",
         "abilities":[
            {
               "type":"blocks_hexes",
               "owner_type":"player",
               "hexes":[
                  "J8"
               ]
            },
            {
               "type":"teleport",
               "owner_type":"corporation",
               "hexes":[
                  "J8"
               ]
            }
         ]
      },
      {
         "name":"Grand Central Belge",
         "value":110,
         "revenue":20,
         "desc":"Owning player may exchange the GCB for a 10% certificate of the Chemins de Fer de L’Etat Belge (B) from the bank or the bank pool, subject to normal certificate limits. This closes the private company. The exchange may be made a) in a stock round, during the player’s turn or between the turns of other players, or b) in an operating round, between the turns of corporations. Blocks hexes G7, G9, & H10 while owned by player.",
         "abilities":[
            {
               "type":"exchange",
               "corporation":"B",
               "owner_type":"player"
            },
            {
               "type":"blocks_hexes",
               "owner_type":"player",
               "hexes":[
                  "G7",
                  "G9",
                  "H10"
               ]
            }
         ]
      },
      {
         "name":"Chemins de Fer Luxembourgeois",
         "value":160,
         "revenue":25,
         "desc":"Upon purchase, the owning player receives a 10% certificate of the Grande Compagnie du Luxembourg (GCL). This certificate may only be sold once the GCL President’s Certificate has been purchased and a par price set, subject to standard rules. Blocks hexes K11 & J12 while owned by player.",
         "abilities":[
            {
               "type":"share",
               "share":"GCL_1"
            }
         ]
      },
      {
         "name":"Chemin de Fer de Lille à Valenciennes",
         "value":220,
         "revenue":30,
         "desc":"Upon purchase, the owning player receives the President’s Certificate of the Chemin de Fer du Nord (Nord) and must immediately set the par price. This private company may not be bought by a corporation, and closes when the Nord buys its first train. Blocks hexes I3 & J4 while owned by player.",
         "abilities":[
            {
               "type":"share",
               "share":"NO_0"
            },
            {
               "type":"no_buy"
            }
         ]
      }
   ],
   "corporations":[
      {
         "sym":"B",
         "name":"Chemins de Fer de L'État Belge",
         "logo":"1836jr/B",
         "tokens":[
            0,
            40,
            100,
            100
         ],
         "coordinates":"H6",
         "color":"black"
      },
      {
         "sym":"GCL",
         "name":"Grande Compagnie du Luxembourg",
         "logo":"1836jr/GCL",
         "tokens":[
            0,
            40,
            100,
            100
         ],
         "coordinates":"I9",
         "color":"green"
      },
      {
         "sym":"NO",
         "name":"Chemin de Fer du Nord",
         "logo":"1836jr/NO",
         "tokens":[
            0,
            40,
            100
         ],
         "coordinates":"I3",
         "color":"darkblue"
      },
      {
         "sym":"NBDS",
         "name":"Noord-Brabantsch-Duitsche Spoorweg-Maatschappij",
         "logo":"1836jr/NBDS",
         "tokens":[
            0,
            40,
            100
         ],
         "coordinates":"E11",
         "color":"#ffcd05",
         "text_color":"black"
      },
      {
         "sym":"HSM",
         "name":"Hollandsche IJzeren Spoorweg Maatschappij",
         "logo":"1836jr/HSM",
         "tokens":[
            0,
            40
         ],
         "coordinates":"D6",
         "color":"#f26722"
      },
      {
         "sym":"NFL",
         "name":"Noord-Friesche Locaal",
         "logo":"1836jr/NFL",
         "tokens":[
            0,
            40
         ],
         "coordinates":"A9",
         "color":"#90ee90",
         "text_color":"black"
      }
   ],
   "trains":[
      {
         "name":"2",
         "distance":2,
         "price":80,
         "rusts_on":"4",
         "num":5
      },
      {
         "name":"3",
         "distance":3,
         "price":180,
         "rusts_on":"6",
         "num":4
      },
      {
         "name":"4",
         "distance":4,
         "price":300,
         "rusts_on":"D",
         "num":3
      },
      {
         "name":"5",
         "distance":5,
         "price":450,
         "num":2
      },
      {
         "name":"6",
         "distance":6,
         "price":630,
         "num":2
      },
      {
         "name":"D",
         "distance":999,
         "price":1100,
         "num":5,
         "available_on":"6",
         "discount":{
            "4":300,
            "5":300,
            "6":300
         }
      }
   ],
   "hexes":{
      "gray":{
         "city=revenue:10;path=a:0,b:_0;path=a:_0,b:5":[
            "A9"
         ]
      },
      "white":{
         "blank":[
            "A11",
            "B12",
            "C7",
            "C9",
            "C11",
            "D12",
            "E9",
            "G3",
            "G5",
            "H8",
            "I5",
            "I7",
            "K5",
            "J4"
         ],
         "town=revenue:0;town=revenue:0;upgrade=cost:80,terrain:water":[
            "B8"
         ],
         "city=revenue:0":[
            "B10",
            "E7",
            "G7",
            "H4",
            "J6"
         ],
         "upgrade=cost:40,terrain:water":[
            "D8",
            "D10",
            "F8",
            "G9",
            "G11"
         ],
         "town=revenue:0;upgrade=cost:40,terrain:water":[
            "F4"
         ],
         "upgrade=cost:80,terrain:water":[
            "F6"
         ],
         "town=revenue:0":[
            "F10",
            "H2"
         ],
         "upgrade=cost:60,terrain:mountain":[
            "I11",
            "J10",
            "J12",
            "K7",
            "K9"
         ],
         "city=revenue:0;upgrade=cost:40,terrain:water":[
            "I9"
         ],
         "city=revenue:0;upgrade=cost:60,terrain:mountain":[
            "J8"
         ],
         "town=revenue:0;town=revenue:0;upgrade=cost:60,terrain:mountain":[
            "K11"
         ]
      },
      "red":{
         "offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:1,b:_0":[
            "A13"
         ],
         "offboard=revenue:yellow_30|brown_50;path=a:1,b:_0":[
            "E13",
            "H12"
         ],
         "offboard=revenue:yellow_40|brown_70;path=a:1,b:_0;path=a:2,b:_0":[
            "K13"
         ]
      },
      "yellow":{
         "city=revenue:40;path=a:0,b:_0;path=a:_0,b:5;label=NY;upgrade=cost:40,terrain:water":[
            "D6"
         ],
         "city=revenue:0;city=revenue:0;label=OO":[
            "E5"
         ],
         "city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:water":[
            "E11",
            "H10"
         ],
         "city=revenue:30;path=a:1,b:_0;path=a:_0,b:3;label=B":[
            "H6"
         ],
         "city=revenue:30;path=a:0,b:_0;path=a:_0,b:4;label=B":[
            "I3"
         ]
      },
      "blue":{
         "offboard=revenue:yellow_20|brown_30;path=a:4,b:_0;path=a:5,b:_0":[
            "E3",
            "G1"
         ]
      },
      "green":{
         "offboard=revenue:yellow_20|brown_30;path=a:3,b:_0;path=a:4,b:_0":[
            "J2"
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
