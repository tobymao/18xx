# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18AL
        JSON = <<-'DATA'

{
   "filename":"18_al",
   "modulename":"18AL",
   "currencyFormatStr":"$%d",
   "bankCash":8000,
   "certLimit":{
      "3":15,
      "4":12,
      "5":10
   },
   "startingCash":{
      "3":600,
      "4":500,
      "5":400
   },
   "capitalization":"full",
   "layout":"flat",
   "axes":{
      "rows":"numbers",
      "columns":"letters"
   },
   "mustSellInBlocks":false,
   "locationNames":{
      "A4":"Nashville",
      "B1":"Corinth",
      "B7":"Chattanooga",
      "C2":"Florence",
      "C4":"Decatur",
      "C6":"Stevenson",
      "D7":"Rome",
      "E6":"Gadsden",
      "F1":"Tupelo",
      "G4":"Birmingham",
      "G6":"Anniston",
      "G8":"Atlanta",
      "H3":"Tuscaloosa",
      "H5":"Oxmoor",
      "J7":"West Point",
      "K2":"York",
      "K4":"Selma",
      "L1":"Meridian",
      "L5":"Montgomery",
      "M8":"Phenix City",
      "O6":"Dothan",
      "P7":"Gulf of Mexico",
      "Q2":"Mobile"
   },
   "tiles":{
      "3":3,
      "4":3,
      "5":3,
      "6":3,
      "7":5,
      "8":11,
      "9":10,
      "14":4,
      "15":4,
      "16":1,
      "17":1,
      "19":1,
      "20":1,
      "23":4,
      "24":4,
      "25":1,
      "26":1,
      "27":1,
      "28":1,
      "29":1,
      "39":1,
      "40":1,
      "41":3,
      "42":3,
      "43":2,
      "44":1,
      "45":2,
      "46":2,
      "47":2,
      "57":4,
      "58":3,
      "63":7,
      "70":1,
      "142":2,
      "143":2,
      "144":2,
      "445":1,
      "446":1,
      "441a":1,
      "442a":1,
      "443a":1,
      "444b":1,
      "444m":1
   },
   "market":[
      [
         "60",
         "65",
         "70",
         "75",
         "80",
         "90p",
         "105p",
         "120",
         "135",
         "150",
         "170",
         "190",
         "215",
         "240",
         "270",
         "300e"
      ],
      [
         "55",
         "60",
         "65",
         "70p",
         "75p",
         "80",
         "90",
         "105",
         "120",
         "135",
         "150",
         "170",
         "190",
         "215",
         "240"
      ],
      [
         "50y",
         "55",
         "60p",
         "65",
         "70",
         "75",
         "80",
         "90",
         "105",
         "120",
         "135",
         "150",
         "170"
      ],
      [
         "45y",
         "50y",
         "55",
         "60",
         "65",
         "70",
         "75",
         "80",
         "90",
         "105",
         "120"
      ],
      [
         "40y",
         "45y",
         "50y",
         "55",
         "60",
         "65",
         "70",
         "75"
      ],
      [
         "35y",
         "40y",
         "45y",
         "50y",
         "55y"
      ],
      [
         "30y",
         "35y",
         "40y",
         "45y",
         "50y"
      ]
   ],
   "companies":[
      {
         "sym":"TR",
         "name":"Tuscumbia Railway",
         "value":20,
         "revenue":5,
         "desc":"No special abilities."
      },
      {
         "sym":"SNAR",
         "name":"South & North Alabama Railroad",
         "value":40,
         "revenue":10,
         "desc":"Owning corporation may place the Warrior Coal Field token in one of the city hexes with a mining symbol (Gadsden, Anniston, Oxmoor, Birmingham, or Tuscaloosa) provided that the corporation can reach the city with a route that is in the range of a train owned by the corporation (i.e. not an infinite route). Placing the token does not close the company. The owning corporation adds 10 to revenue for all trains whose route includes the city with the token. The token is removed from the game at the beginning of phase 6.",
         "abilities": [
            {
               "type": "assign_hexes",
               "hexes": [
                 "H3",
                 "G4",
                 "H5",
                 "G6",
                 "E6"
               ],
               "count": 1,
               "owner_type": "corporation"
            }
         ]
      },
      {
         "sym":"BLC",
         "name":"Brown & Sons Lumber Co.",
         "value":70,
         "revenue":15,
         "desc":"Owning corporation may during the track laying step lay the Lumber Terminal track tile (# 445) in an empty swamp hex, which need not be connected to the corporation's station(s). The tile is free and does not count as the corporation's one tile lay per turn. Laying the tile does not close the company. The tile is permanent and cannot be upgraded.",
         "abilities": [
             {
               "type": "tile_lay",
               "free":true,
               "owner_type": "corporation",
               "tiles": [
                  "445"
               ],
               "hexes": [
                 "G2",
                 "M2",
                 "O4",
                 "N5",
                 "P5"
               ],
               "count": 1,
               "when": "track"
             }
         ]
      },
      {
         "sym":"M&C",
         "name":"Memphis & Charleston Railroad",
         "value":100,
         "revenue":20,
         "desc":"Owning corporation receives the Robert E. Lee marker which adds +20 to revenue if a route includes Atlanta and Birmingham and the Pan American marker which adds +40 to revenue if a route includes Nashville and Mobile. Each marker may be assigned to one train each operating round and both markers may be assigned to a single train. The bonuses are permanent unless a new player becomes president of the corporation, in which case they are removed from the game."
      },
      {
         "sym":"NDY",
         "name":"New Decatur Yards",
         "value":120,
         "revenue":20,
         "desc":"Owning corporation may purchase one new train from the bank with a discount of 50%, which closes the company.",
         "abilities": [
            {
              "type": "train_discount",
              "discount": 0.50,
              "owner_type": "corporation",
              "trains": [
                 "3",
                 "4",
                 "5"
              ],
              "count": 1,
              "when": "train"
            }
         ]
      }
   ],
   "corporations":[
      {
         "sym":"L&N",
         "name":"Louisville & Nashville Railroad",
         "logo":"18_al/LN",
         "tokens":[
            0,
            40,
            100,
            100
         ],
         "coordinates":"A4",
         "color":"blue",
         "abilities": [
            {
              "type": "assign_hexes",
              "hexes": [
                "G4"
              ],
              "count": 1
            }
         ]
      },
      {
         "sym":"M&O",
         "name":"Mobile & Ohio Railroad",
         "logo":"18_al/MO",
         "tokens":[
            0,
            40,
            100,
            100
         ],
         "coordinates":"Q2",
         "color":"orange",
         "abilities": [
            {
               "type": "assign_hexes",
               "hexes": [
                 "K2"
               ],
               "count": 1
            }
         ]
      },
      {
         "sym":"WRA",
         "name":"Western Railway of Alabama",
         "logo":"18_al/WRA",
         "tokens":[
            0,
            40,
            100,
            100
         ],
         "coordinates":"L5",
         "color":"red",
         "abilities": [
            {
               "type": "assign_hexes",
               "hexes": [
                 "J7"
               ],
               "count": 1
            }
         ]
      },
      {
         "sym":"ATN",
         "name":"Alabama, Tennessee & Northern Railroad",
         "logo":"18_al/ATN",
         "tokens":[
            0,
            40,
            100
         ],
         "coordinates":"F1",
         "color":"black",
         "abilities": [
            {
               "type": "assign_hexes",
               "hexes": [
                 "L1"
               ],
               "count": 1
            }
         ]
      },
      {
         "sym":"ABC",
         "name":"Atlanta, Birmingham & Coast Railroad",
         "logo":"18_al/ABC",
         "tokens":[
            0,
            40
         ],
         "coordinates":"G6",
         "color":"green",
         "abilities": [
            {
               "type": "assign_hexes",
               "hexes": [
                 "G4"
               ],
               "count": 1
            }
         ]
      },
      {
         "sym":"TAG",
         "name":"Tennessee, Alabama & Georgia Railway",
         "logo":"18_al/TAG",
         "tokens":[
            0,
            40
         ],
         "coordinates":"E6",
         "color":"yellow",
         "text_color":"black",
         "abilities": [
            {
               "type": "assign_hexes",
               "hexes": [
                 "G4"
               ],
               "count": 1
            }
         ]
      }
   ],
   "trains":[
      {
         "name":"2",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":2,
               "visit":2
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":100,
         "rusts_on":"4",
         "num":5
      },
      {
         "name":"3",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":3,
               "visit":3
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":180,
         "rusts_on":"6",
         "num":4
      },
      {
         "name":"4",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":4,
               "visit":4
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":300,
         "obsolete_on":"7",
         "num":3
      },
      {
         "name":"5",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":5,
               "visit":5
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "events":[
           {"type": "close_companies"}
         ],
         "price":450,
         "num":2
      },
      {
         "name":"6",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":6,
               "visit":6
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":630,
         "num":1,
         "events": [
            {"type": "remove_tokens"}
         ]
      },
      {
         "name":"7",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":7,
               "visit":7
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":700,
         "num":1
      },
      {
         "name":"4D",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":4,
               "visit":4
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":800,
         "num":5
      }
   ],
   "hexes":{
      "white":{
         "":[
            "A2",
            "B5",
            "D1",
            "E2",
            "E4",
            "F3",
            "F5",
            "H1",
            "H7",
            "I2",
            "I4",
            "I6",
            "I8",
            "J1",
            "J3",
            "J5",
            "K6",
            "K8",
            "L7",
            "M4",
            "M6",
            "N1",
            "N7",
            "P1",
            "P3"
         ],
         "border=edge:0,type:impassable":[
            "B3"
         ],
         "upgrade=cost:20,terrain:water;border=edge:3,type:impassable":[
            "D3"
         ],
         "town=revenue:0;upgrade=cost:20,terrain:water":[
            "C2",
            "C6"
         ],
         "city=revenue:0;upgrade=cost:20,terrain:water":[
            "C4"
         ],
         "upgrade=cost:20,terrain:water":[
            "L3",
            "N3",
            "O2"
         ],
         "upgrade=cost:20,terrain:swamp":[
            "G2",
            "M2",
            "N5",
            "O4",
            "P5"
         ],
         "upgrade=cost:60,terrain:mountain|water":[
            "D5"
         ],
         "upgrade=cost:60,terrain:mountain":[
            "F7"
         ],
         "city=revenue:0;upgrade=cost:60,terrain:mountain;label=B;icon=image:18_al/coal,sticky:1":[
            "G4"
         ],
         "city=revenue:0":[
            "J7",
            "K2",
            "L5"
         ],
         "city=revenue:0;icon=image:18_al/coal,sticky:1":[
            "G6",
            "H3"
         ],
         "town=revenue:0":[
            "O6"
         ]
      },
      "red":{
         "city=revenue:yellow_40|brown_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1":[
            "A4"
         ],
         "offboard=revenue:yellow_40|brown_30;path=a:5,b:_0":[
            "B1"
         ],
         "offboard=revenue:yellow_30|brown_50;path=a:1,b:_0":[
            "B7"
         ],
         "offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:1,b:_0":[
            "G8"
         ],
         "offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0":[
            "P7"
         ],
         "city=revenue:yellow_40|brown_50;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1":[
            "Q2"
         ]
      },
      "gray":{
         "town=revenue:10;path=a:0,b:_0;path=a:_0,b:1":[
            "D7"
         ],
         "city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0":[
            "F1"
         ],
         "city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;icon=image:18_al/coal,sticky:1":[
            "H5"
         ],
         "city=revenue:yellow_30|brown_40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0":[
            "L1"
         ],
         "town=revenue:10;path=a:1,b:_0;path=a:_0,b:2":[
            "M8"
         ]
      },
      "yellow":{
         "city=revenue:20;path=a:3,b:_0;path=a:4,b:_0;icon=image:18_al/coal,sticky:1":[
            "E6"
         ],
         "city=revenue:20;path=a:1,b:_0;path=a:_0,b:5":[
            "K4"
         ]
      }
   },
   "phases":[
      {
         "name":"2",
         "train_limit":4,
         "tiles":[
            "yellow"
         ],
         "operating_rounds": 1,
         "status":[
            "can_buy_companies_from_other_players",
            "limited_train_buy"
         ]
      },
      {
         "name":"3",
         "on":"3",
         "train_limit":4,
         "tiles":[
            "yellow",
            "green"
         ],
         "status":[
            "can_buy_companies",
            "can_buy_companies_from_other_players",
            "limited_train_buy"
         ],
         "operating_rounds": 2
      },
      {
         "name":"4",
         "on":"4",
         "train_limit":3,
         "tiles":[
            "yellow",
            "green"
         ],
         "status":[
            "can_buy_companies",
            "can_buy_companies_from_other_players",
            "limited_train_buy"
         ],
         "operating_rounds": 2
      },
      {
         "name":"5",
         "on":"5",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown"
         ],
         "operating_rounds": 3
      },
      {
         "name":"6",
         "on":"6",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown"
         ],
         "operating_rounds": 3
      },
      {
         "name":"7",
         "on":"7",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown"
         ],
         "operating_rounds": 3
      },
      {
         "name":"4D",
         "on":"4D",
         "train_limit":2,
         "tiles":[
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
