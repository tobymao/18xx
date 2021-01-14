# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18Mag
        JSON = <<-'DATA'
{
  "filename": "18_mag",
  "modulename": "18Mag",
  "currencyFormatStr": "%d Ft",
  "bankCash": 12000,
  "certLimit": {
    "3": 18,
    "4": 14,
    "5": 11,
    "6": 9
  },
  "startingCash": {
    "3": 0,
    "4": 0,
    "5": 0,
    "6": 0
  },
  "capitalization": "full",
  "layout": "pointy",
  "mustSellInBlocks": false,
  "locationNames": {
    "B17": "Kassa",
    "B23": "Moszkva",
    "C6": "Bécs",
    "C8": "Pozsony",
    "C12": "Selmecbánya",
    "C16": "Miskolc",
    "D7": "Sopron",
    "D9": "Györ",
    "D19": "Szatmárnémeti & Nyíregyháza",
    "E10": "Székesfehérvár",
    "E12": "Buda & Pest",
    "E14": "Szolnok",
    "E18": "Debrecen",
    "F13": "Kecskemét",
    "F19": "Nagyvárad",
    "F23": "Kolozsvár",
    "G10": "Pécs & Mohács",
    "G14": "Szeged & Szabadka",
    "G16": "Arad",
    "H1": "Trieszt",
    "H5": "Zágráb",
    "H17": "Temesvár",
    "H23": "Nagyzeben",
    "H27": "Brassó",
    "I2": "Fiume",
    "I14": "Újvidék & Pétrovárad",
    "I26": "Isztambul",
    "J15": "Belgrád"
  },
  "tiles": {
    "6": 7,
    "7": 4,
    "8": 21,
    "9": 21,
    "3": 5,
    "58": 13,
    "4": 13,
    "5": 10,
    "57": 10,
    "6": 7,
    "L32": {
      "count": 4,
      "color": "yellow",
      "code": "city=revenue:30,loc:2;city=revenue:0,loc:0;path=a:2,b:_0;label=OO;upgrade=cost:20,terrain:water"
    },
    "L33": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_1;path=a:0,b:_1;label=B;upgrade=cost:20,terrain:water"
    },
    "16": 2,
    "19": 2,
    "20": 1,
    "23": 6,
    "24": 6,
    "25": 2,
    "26": 4,
    "27": 4,
    "28": 2,
    "29": 2,
    "30": 2,
    "31": 2,
    "209": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B"
    },
    "204": 3,
    "88": 6,
    "87": 6,
    "619": 5,
    "14": 8,
    "15": 8,
    "8860": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:5,b:_1;label=OO"
    },
    "8859": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:3,b:_1;label=OO"
    },
    "8858": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_1;path=a:3,b:_1;label=OO"
    },
    "8863": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40,loc:1.5;city=revenue:40;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_1;path=a:3,b:_1;label=OO"
    },
    "8864": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40,loc:3.5;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=OO"
    },
    "8865": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40;city=revenue:40,loc:4.5;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_1;path=a:5,b:_1;label=OO"
    },
    "236": 1,
    "237": 2,
    "238": 2,
    "39": 2,
    "40": 2,
    "41": 2,
    "42": 2,
    "43": 2,
    "70": 2,
    "44": 2,
    "47": 2,
    "45": 2,
    "46": 2,
    "G17": {
      "count": 4,
      "color": "brown",
      "code": "town=revenue:20;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0"
    },
    "611": 8,
    "L17": {
      "count": 3,
      "color": "brown",
      "code": "city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO"
    },
    "L34": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K"
    },
    "L35": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K"
    },
    "L38": {
      "count": 1,
      "color": "gray",
      "code": "town=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0"
    },
    "455": 2,
    "X9": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO"
    },
    "L36": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:60,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=K"
    },
    "L37": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B"
    }
  },
  "market": [
    [
      "37",
      "60p",
      "65p",
      "70p",
      "75p",
      "80p",
      "85",
      "90",
      "95",
      "100",
      "110",
      "120",
      "130",
      "140",
      "152",
      "164",
      "178",
      "192",
      "208",
      "224",
      "242",
      "260",
      "280",
      "300",
      "320",
      "340",
      "360",
      "380",
      "400"
    ]
  ],
  "minors": [
    {
      "sym":"1",
      "name":"Magyar Északi Vasút",
      "logo":"18_mag/1",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"E12",
       "city":1,
       "color":"black"
    },
    {
      "sym":"2",
      "name":"Magyar Keleti Vasút",
      "logo":"18_mag/2",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"D19",
       "city":0,
       "color":"black"
    },
    {
      "sym":"3",
      "name":"Magyar Nyugoti Vasút",
      "logo":"18_mag/3",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"E10",
       "color":"black"
    },
    {
      "sym":"4",
      "name":"Tisza Vidéki Vasút",
      "logo":"18_mag/4",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"G14",
       "city":1,
       "color":"black"
    },
    {
      "sym":"5",
      "name":"Első Erdélyi Vasút",
      "logo":"18_mag/5",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"H27",
       "color":"black"
    },
    {
      "sym":"6",
      "name":"Kassa-Oderbergi Vasút",
      "logo":"18_mag/6",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"B17",
       "color":"black"
    },
    {
      "sym":"7",
      "name":"Mohács-Pécsi Vasút",
      "logo":"18_mag/7",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"G10",
       "city":1,
       "color":"black"
    },
    {
      "sym":"8",
      "name":"Hrvatske željeznice",
      "logo":"18_mag/8",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"H5",
       "color":"black"
    },
    {
      "sym":"9",
      "name":"Szeged-Petrovaradin-Zemun Vasútvonal",
      "logo":"18_mag/9",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"I14",
       "city":1,
       "color":"black"
    },
    {
      "sym":"10",
      "name":"Arad-Temesvári Vasúttársaság",
      "logo":"18_mag/10",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"H17",
       "city":0,
       "color":"black"
    },
    {
      "sym":"11",
      "name":"Győr-Sopron-Ebenfurti Vasút Zrt.",
      "logo":"18_mag/11",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"D7",
       "color":"black"
    },
    {
      "sym":"12",
      "name":"Calea ferată îngustă Sibiu-Agnita",
      "logo":"18_mag/12",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"H23",
       "color":"black"
    },
    {
      "sym":"13",
      "name":"Déli Vasút",
      "logo":"18_mag/13",
       "tokens":[
         0,
         40,
         80
       ],
       "coordinates":"I2",
       "color":"black"
    },
    {
      "sym":"mine",
      "name":"mine",
      "logo":"18_mag/mine",
       "tokens":[
         0,
         0,
         0,
         0
       ],
       "coordinates":[
         "A10",
         "A18",
         "E26",
         "I20"
        ],
       "color":"white"
    }
  ],
  "corporations": [
    {
      "sym": "RABA",
      "name": "RÁBA Company",
      "logo": "18_mag/RABA",
      "float_percent": 0,
      "max_ownership_percent": 60,
      "tokens": [
        40,
        80
      ],
      "color": "red"
    },
    {
      "sym": "G&C",
      "name": "Ganz & Cie",
      "logo": "18_mag/GC",
      "float_percent": 0,
      "max_ownership_percent": 60,
      "tokens": [
        40,
        80
      ],
      "color": "lightblue",
      "text_color": "black"
    },
    {
      "sym": "SNW",
      "name": "Schlick-Nicholsonsche Waggon-Fabrik A.-G.",
      "logo": "18_mag/SNW",
      "float_percent": 0,
      "max_ownership_percent": 60,
      "tokens": [
        40,
        80
      ],
      "color": "black"
    },
    {
      "sym": "SIK",
      "name": "Károly Széchy Tunnelbau",
      "logo": "18_mag/SIK",
      "float_percent": 0,
      "max_ownership_percent": 60,
      "tokens": [
        40,
        80
      ],
      "color": "green"
    },
    {
      "sym": "SKEV",
      "name": "Gróf Széchenyi István Konsortium",
      "logo": "18_mag/SKEV",
      "float_percent": 0,
      "max_ownership_percent": 60,
      "tokens": [
        40,
        80
      ],
      "color": "yellow",
      "text_color": "black"
    },
    {
      "sym": "LdStEG",
      "name": "Lokomotivfabrik der StEG",
      "logo": "18_mag/LdStEG",
      "float_percent": 0,
      "max_ownership_percent": 60,
      "tokens": [
        40,
        80
      ],
      "color": "orange"
    },
    {
      "sym": "MAVAG",
      "name": "Magyar Királyi Államvasutak Gépgyára",
      "logo": "18_mag/MAVAG",
      "float_percent": 0,
      "max_ownership_percent": 60,
      "tokens": [
        40,
        80
      ],
      "color": "purple"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "num": 25
    },
    {
      "name": "3",
      "distance": 3,
      "price": 120,
      "num": 25,
      "events": [
        {"type": "first_three"}
      ]
    },
    {
      "name": "4",
      "distance": 4,
      "price": 200,
      "num": 25,
      "events": [
        {"type": "first_four"}
      ]
    },
    {
      "name": "6",
      "distance": 6,
      "price": 320,
      "num": 25,
      "events": [
        {"type": "first_six"}
      ]
    }
  ],
  "hexes": {
    "white": {
      "city=revenue:20,loc:0.5;city=revenue:20,loc:3.5;path=a:0,b:_0;path=a:3,b:_1;label=B": [
        "E12"
      ],
      "city=revenue:0;city=revenue:0;label=OO": [
        "D19",
        "G10",
        "G14",
        "I14"
      ],
      "city=revenue:0": [
        "C12",
        "C16",
        "E10",
        "E14",
        "E18",
        "F13",
        "F19",
        "G16",
        "H5",
        "H17"
      ],
      "city=revenue:0;label=K": [
        "I2"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:mountain": [
        "B17",
        "F23"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:water": [
        "D9"
      ],
      "city=revenue:0;border=edge:0,type:impassable": [
        "C8"
      ],
      "city=revenue:0;border=edge:3,type:impassable": [
        "D7"
      ],
      "city=revenue:0;upgrade=cost:10,terrain:mountain;label=K": [
        "H23",
        "H27"
      ],
      "town=revenue:0": [
        "B15",
        "D13",
        "E6",
        "F17",
        "G18",
        "G22",
        "H7",
        "H13"
      ],
      "town=revenue:0;upgrade=cost:10,terrain:water": [
        "D17",
        "G6",
        "J19"
      ],
      "town=revenue:0;upgrade=cost:10,terrain:mountain": [
        "B9",
        "G24"
      ],
      "town=revenue:0;upgrade=cost:20,terrain:water|mountain": [
        "C20"
      ],
      "town=revenue:0;upgrade=cost:20,terrain:mountain": [
        "E22",
        "E24",
        "F25",
        "G26"
      ],
      "town=revenue:0;upgrade=cost:30,terrain:water": [
        "H11"
      ],
      "upgrade=cost:10,terrain:mountain": [
        "B11",
        "I4",
        "I18",
        "J3"
      ],
      "upgrade=cost:10,terrain:water": [
        "C18",
        "F15",
        "G8",
        "H9",
        "H15"
      ],
      "upgrade=cost:20,terrain:water": [
        "D11",
        "F11",
        "G12",
        "I12"
      ],
      "upgrade=cost:20,terrain:water|mountain": [
        "D21"
      ],
      "upgrade=cost:20,terrain:mountain": [
        "B13",
        "C14",
        "C22",
        "F21",
        "G20",
        "H3",
        "H19",
        "H21",
        "H25"
      ],
      "upgrade=cost:30,terrain:water|mountain": [
        "D23"
      ],
      "upgrade=cost:30,terrain:mountain": [
        "A12",
        "A14",
        "A16",
        "B19",
        "B21",
        "C24",
        "D25",
        "F27",
        "G28"
      ],
      "border=edge:0,type:impassable;upgrade=cost:10,terrain:mountain": [
        "I6"
      ],
      "border=edge:3,type:impassable;upgrade=cost:10,terrain:mountain": [
        "J5"
      ],
      "border=edge:0,type:impassable": [
        "F5"
      ],
      "border=edge:3,type:impassable": [
        "G4"
      ],
      "partition=a:1,b:4,type:water": [
        "F9"
      ],
      "": [
        "C10",
        "D15",
        "E8",
        "E16",
        "E20",
        "F7",
        "I8",
        "I10",
        "I16"
      ]
    },
    "red": {
      "offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0": [
        "B23"
      ],
      "offboard=revenue:yellow_30|green_40|brown_50|gray_70;path=a:4,b:_0;path=a:5,b:_0": [
        "C6"
      ],
      "offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:4,b:_0;path=a:5,b:_0": [
        "H1"
      ],
      "offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:2,b:_0;path=a:3,b:_0": [
        "I26"
      ],
      "offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0;path=a:3,b:_0": [
        "J15"
      ]
    },
    "gray": {
      "city=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "A10"
      ],
      "city=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0": [
        "A18"
      ],
      "city=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0": [
        "E26"
      ],
      "city=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0": [
        "I20"
      ]
    }
  },
  "phases": [
    {
      "name": "Yellow",
      "train_limit": 2,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "Green",
      "on": ["3", "4", "6"],
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "Brown",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 2
    },
    {
      "name": "Gray",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "operating_rounds": 3,
      "status":[
        "end_game_triggered"
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
