# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18MS
        JSON = <<-'DATA'
{
   "filename":"18_ms",
   "modulename":"18MS",
   "currencyFormatStr":"$%d",
   "bankCash":10000,
   "certLimit":{
      "2":20,
      "3":14,
      "4":10
   },
   "startingCash":{
      "2":900,
      "3":625,
      "4":525
   },
   "capitalization":"full",
   "layout":"pointy",
   "axes":{
      "rows":"numbers",
      "columns":"letters"
   },
   "mustSellInBlocks":false,
   "locationNames":{
      "A1":"Memphis",
      "B2":"Grenada",
      "B12":"Chattanooga",
      "C5":"Starkville",
      "C7":"Tuscaloosa",
      "C9":"Birmingham",
      "D6":"York",
      "E1":"Jackson",
      "E5":"Meridian",
      "E9":"Selma",
      "E11":"Montgomery",
      "E15":"Atlanta",
      "G3":"Hattiesburg",
      "H4":"Gulfport",
      "H6":"Mobile",
      "H8":"Pensacola",
      "H10":"Tallahassee",
      "I1":"New Orleans"
   },
   "tiles":{
      "3":3,
      "4":3,
      "5":2,
      "6":3,
      "7":4,
      "8":10,
      "9":10,
      "57":3,
      "58":3,
      "14":3,
      "15":3,
      "16":1,
      "19":1,
      "20":1,
      "23":4,
      "24":4,
      "25":2,
      "26":1,
      "27":1,
      "28":1,
      "29":1,
      "87":2,
      "88":2,
      "143":2,
      "204":2,
      "619":3,
      "39":1,
      "40":2,
      "41":2,
      "42":2,
      "43":1,
      "45":1,
      "46":1,
      "47":2,
      "63":4,
      "446":{
         "count":1,
         "color":"gray",
         "code":"city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=BM"
      },
      "X31b":{
         "count":1,
         "color":"brown",
         "code":"city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Mob"
      }
   },
   "market":[
      [
         "65y",
         "70",
         "75",
         "80",
         "90p",
         "100",
         "110",
         "130",
         "150",
         "170",
         "200",
         "230",
         "265",
         "300"
      ],
      [
         "60y",
         "65y",
         "70p",
         "75p",
         "80p",
         "90",
         "100",
         "110",
         "130",
         "150",
         "170",
         "200",
         "230",
         "265"
      ],
      [
         "50y",
         "60y",
         "65y",
         "70",
         "75",
         "80",
         "90",
         "100",
         "110",
         "130",
         "150"
      ],
      [
         "45y",
         "50y",
         "60y",
         "65y",
         "70",
         "75",
         "80"
      ],
      [
         "40y",
         "45y",
         "50y",
         "60y"
      ]
   ],
   "companies":[
      {
         "name":"Alabama Great Southern Railroad",
         "value":30,
         "revenue":15,
         "desc":"The owning Major Corporation may lay an extra yellow tile for free. This extra tile must extend existing track and could be used to extend from a yellow or green tile played as a Major Corporation’s  normal tile lay. This ability can only be used once, and using it does not close the Private Company. Alabama Great Southern Railroad can be bought for exactly face value during OR 1 by an operating Major Corporation if the president owns the Private Company.",
         "sym":"AGS",
         "abilities": [
           {
             "type": "tile_lay",
             "owner_type": "corporation",
             "count": 1,
             "free": true,
             "special": false,
             "reachable": true,
             "hexes": [
             ],
             "tiles": [
             ],
             "when":"track"
           }
         ]
        },
      {
         "name":"Birmingham Southern Railroad",
         "value":40,
         "revenue":10,
         "desc":"The owning Major Corporation may lay one or two extra yellow tiles for free. This extra tile lay must extend existing track and could be used to extend from a yellow or green tile played as a corporation’s normal tile lay. This ability can only be used once during a single operating round, and using it does not close the Private Company. Birmingham Southern Railroad can be bought for exactly face value during OR 1 by an operating Major Corporation if the president owns the Private Company.",
         "sym":"BS",
         "abilities": [
           {
             "type": "tile_lay",
             "owner_type": "corporation",
             "count": 2,
             "free": true,
             "special": false,
             "reachable": true,
             "must_lay_together": true,
             "hexes": [
             ],
             "tiles": [
             ],
             "when":"track",
             "blocks": false
           }
         ]
      },
      {
         "name":"Meridian and Memphis Railway",
         "value":50,
         "revenue":15,
         "desc":"The owning Major Corporation may lay their cheapest available token for half price. This is not an extra token placement. This ability can only be used once, and using it does not close the Private Company.",
         "sym":"M&M",
         "abilities": [
            {
              "type": "token",
              "owner_type":"corporation",
              "hexes": [],
              "discount": 0.5,
              "count": 1,
              "from_owner": true
            }
         ]
      },
      {
         "name":"Mississippi Central Railway",
         "value":60,
         "revenue":5,
         "desc":"The owning Major Corporation exchanges this private for a special 2+ train when purchased. (This 2+ train may not be sold.) This exchange occurs immediately when purchased. If this exchange would place the Major Corporation over the train limit of 3, the purchase is not allowed. If this Private Company is not purchased by the end of OR 4, it may not be sold to a Major Corporation and counts against the owner's certificate limit until it closes upon the start of Phase 6.",
         "sym":"MC"
      },
      {
         "name":"Mobile & Ohio Railway",
         "value":70,
         "revenue":5,
         "desc":"The owning Major Corporation may purchase an available 3+ Train or 4+ Train from the bank for a discount of $100. Using this discount closes this Private Company. The discounted purchase is subject to the normal rules governing train purchases - only during the train-buying step and train limits apply.",
         "sym":"M&O",
         "abilities": [
            {
              "type": "train_discount",
              "discount": 100,
              "owner_type": "corporation",
              "trains": [
                 "3+",
                 "4+"
              ],
              "count": 1,
              "when": "train"
            }
         ]
      }
   ],
   "corporations":[
      {
         "float_percent":60,
         "max_ownership_percent":70,
         "sym":"GMO",
         "name":"Gulf, Mobile and Ohio Railroad",
         "logo":"18_ms/GMO",
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
         "float_percent":60,
         "max_ownership_percent":70,
         "sym":"IC",
         "name":"Illinois Central Railroad",
         "logo":"18_ms/IC",
         "tokens":[
            0,
            40,
            100
         ],
         "coordinates":"A1",
         "color":"#397641"
      },
      {
         "float_percent":60,
         "max_ownership_percent":70,
         "sym":"L&N",
         "name":"Louisville and Nashville Railroad",
         "logo":"18_ms/LN",
         "tokens":[
            0,
            40,
            100
         ],
         "coordinates":"C9",
         "color":"#0d5ba5"
      },
      {
         "float_percent":60,
         "max_ownership_percent":70,
         "sym":"Fr",
         "name":"Frisco",
         "logo":"18_ms/Fr",
         "tokens":[
            0,
            40,
            100
         ],
         "coordinates":"E1",
         "color":"#ed1c24"
      },
      {
         "float_percent":60,
         "max_ownership_percent":70,
         "sym":"WRA",
         "name":"Western Railway of Alabama",
         "logo":"18_ms/WRA",
         "tokens":[
            0,
            40,
            100
         ],
         "coordinates":"E11",
         "color":"#c7c4e2",
         "text_color":"black"
      }
   ],
   "trains":[
      {
         "name":"2+",
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
         "price":80,
         "num":5
      },
      {
         "name":"3+",
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
         "num":4
      },
      {
         "name":"4+",
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
         "num":3
      },
      {
         "name":"5",
         "distance":5,
         "price":500,
         "num":2
      },
      {
         "name":"6",
         "distance":6,
         "price":550,
         "num":2,
         "events":[
           {"type": "close_companies"},
           {"type": "remove_tokens"}
         ]
      },
      {
         "name":"2D",
         "distance":2,
         "multiplier":2,
         "price":500,
         "num":4,
         "available_on":"6",
         "variants":[
            {
               "name":"4D",
               "price":750,
               "multiplier":2,
               "available_on":"6",
               "distance":4
            }
         ]
      },
      {
         "name":"5D",
         "multiplier":2,
         "distance":5,
         "price":850,
         "num":1,
         "available_on":"6"
      }
   ],
   "hexes":{
      "empty": {
        "": ["B14"]
      },
      "white":{
         "":[
            "B4",
            "B6",
            "B8",
            "B10",
            "C1",
            "C3",
            "C11",
            "D2",
            "D4",
            "D8",
            "D10",
            "E3",
            "F4",
            "F10",
            "G5",
            "G9",
            "G11"
         ],
         "upgrade=cost:20,terrain:water":[
            "E7",
            "F2",
            "F6",
            "F8",
            "G1",
            "G7"
         ],
         "upgrade=cost:40,terrain:water":[
            "H2"
         ],
         "town=revenue:0;upgrade=cost:20,terrain:water":[
            "H8"
         ],
         "city=revenue:0":[
            "C7",
            "C9",
            "E5",
            "E9",
            "E11",
            "H6"
         ],
         "town=revenue:0":[
            "B2",
            "C5",
            "D6",
            "G3",
            "H4"
         ]
      },
      "red":{
         "offboard=revenue:yellow_40|brown_60;path=a:1,b:_0;icon=image:18_ms/coins":[
            "B12"
         ],
         "offboard=revenue:yellow_30|brown_50;path=a:1,b:_0":[
            "H10"
         ],
         "city=revenue:yellow_40|brown_50;path=a:5,b:_0;path=a:4,b:_0;border=edge:4":[
            "A1"
         ],
         "city=revenue:yellow_50|brown_80,loc:center;town=revenue:10,loc:5.5;path=a:3,b:_0;path=a:_1,b:_0;icon=image:18_ms/coins":[
            "I1"
         ],
         "path=a:1,b:5;border=edge:1":[
            "A3"
         ],
         "path=a:0,b:5;border=edge:5":[
            "D12"
         ],
         "path=a:0,b:4;path=a:1,b:4;path=a:2,b:4;border=edge:0;border=edge:2;border=edge:4":[
            "E13"
         ],
         "path=a:2,b:3;border=edge:3":[
            "F12"
         ],
         "offboard=revenue:yellow_40|brown_50;path=a:1,b:_0;border=edge:1":[
            "E15"
         ]
      },
      "gray":{
         "city=revenue:yellow_30|brown_60,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0":[
            "E1"
         ]
      }
   },
   "phases":[
      {
         "name":"2",
         "train_limit":3,
         "tiles":[
            "yellow"
         ],
         "operating_rounds":2,
         "status":[
            "can_buy_companies_operation_round_one"
         ]
      },
      {
         "name":"3",
         "train_limit":3,
         "tiles":[
            "yellow",
            "green"
         ],
         "operating_rounds":2,
         "status":[
            "can_buy_companies"
         ]
      },
      {
         "name":"6",
         "train_limit":3,
         "tiles":[
            "yellow",
            "green",
            "brown"
         ],
         "operating_rounds":2
      },
      {
         "name":"D",
         "train_limit":3,
         "tiles":[
            "yellow",
            "green",
            "brown",
            "gray"
         ],
         "operating_rounds":2
      }
   ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
