# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1849
        JSON = <<-'DATA'
{
  "filename": "1849",
  "modulename": "1849",
  "currencyFormatStr": "L.%d",
  "bankCash": 7760,
  "certLimit": {
    "4": 11
  },
  "startingCash": {
    "4": 375
  },
  "capitalization": "incremental",
  "layout": "flat",
  "mustSellInBlocks": true,
  "locationNames": {
    "A13": "Milazzo",
    "B14": "Messina",
    "C1": "Trapani",
    "C5": "Palermo",
    "C9": "St. Stefano",
    "C15": "Calabria",
    "D4": "Partinico",
    "E1": "Marsala",
    "E5": "Corleone",
    "E7": "Termini Imerese",
    "E11": "Bronte",
    "E13": "Taormina",
    "F10": "Troina",
    "G1": "Mazzara",
    "G3": "Castelvetrano",
    "G9": "Castrogiovanni",
    "G13": "Acireale",
    "H4": "Sciacca",
    "H8": "Caltanissetta",
    "H12": "Catania",
    "I7": "Canicatti",
    "I9": "Piazza Armerina",
    "J6": "Girgenti",
    "J10": "Caltagirone",
    "K7": "Licata",
    "K13": "Augusta",
    "M9": "Terranova",
    "M11": "Ragusa",
    "M13": "Siracusa",
    "N10": "Vittoria",
    "F12": "Etna"
  },
  "tiles": {
    "3": 4,
    "4": 4,
    "7": 4,
    "8": 10,
    "9": 6,
    "58": 4,
    "73": 4,
    "74": 3,
    "77": 4,
    "78": 10,
    "79": 7,
    "644": 2,
    "545": 2,
    "657": 2,
    "658": 2,
    "659": 2,
    "679": 2,

    "23": 3,
    "24": 3,
    "25": 2,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "30": 1,
    "31": 1,
    "624": 1,
    "650": 1,
    "651": 1,
    "653": 1,
    "655": 1,
    "660": 1,
    "661": 1,
    "662": 1,
    "663": 1,
    "664": 1,
    "665": 1,
    "666": 1,
    "667": 1,
    "668": 1,
    "669": 1,
    "670": 1,
    "671": 1,
    "675": 1,
    "677": 3,
    "678": 3,
    "680": 1,
    "681": 1,
    "682": 1,
    "683": 1,
    "684": 1,
    "685": 1,
    "686": 1,
    "687": 1,
    "688": 1,
    "689": 1,
    "690": 1,
    "691": 1,
    "692": 1,
    "693": 1,
    "694": 1,
    "695": 1,
    "699": 2,
    "700": 1,
    "701": 1,
    "702": 1,
    "703": 1,
    "704": 1,
    "705": 1,
    "706": 1,
    "707": 1,
    "708": 1,
    "709": 1,
    "710": 1,
    "711": 1,
    "712": 1,
    "713": 1,
    "714": 1,
    "715": 1,

    "39": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "646": 1,
    "647": 1,
    "648": 1,
    "649": 1,
    "652": 1,
    "654": 1,
    "656": 1,
    "672": 1,
    "673": 2,
    "674": 2,
    "676": 1,
    "696": 3,
    "697": 2,
    "698": 2
  },
  "market": [
    [
      "72",
      "83",
      "95",
      "107",
      "120",
      "133",
      "147",
      "164",
      "182",
      "202",
      "224",
      "248",
      "276",
      "306u",
      "340u",
      "377e"
    ],
    [
      "63",
      "72",
      "82",
      "93",
      "104",
      "116",
      "128",
      "142",
      "158",
      "175",
      "195",
      "216p",
      "240",
      "266u",
      "295u",
      "328u"
    ],
    [
      "57",
      "66",
      "75",
      "84",
      "95",
      "105",
      "117",
      "129",
      "144p",
      "159",
      "177",
      "196",
      "218",
      "242u",
      "269u",
      "298u"
    ],
    [
      "54",
      "62",
      "71",
      "80",
      "90",
      "100p",
      "111",
      "123",
      "137",
      "152",
      "169",
      "187",
      "208",
      "230"
    ],
    [
      "52",
      "59",
      "68p",
      "77",
      "86",
      "95",
      "106",
      "117",
      "130",
      "145",
      "160",
      "178",
      "198"
    ],
    [
      "47",
      "54",
      "62",
      "70",
      "78",
      "87",
      "96",
      "107",
      "118",
      "131",
      "146",
      "162"
    ],
    [
      "41",
      "47",
      "54",
      "61",
      "68",
      "75",
      "84",
      "93",
      "103",
      "114",
      "127"
    ],
    [
      "34",
      "39",
      "45",
      "50",
      "57",
      "63",
      "70",
      "77",
      "86",
      "95"
    ],
    [
      "27",
      "31",
      "36",
      "40",
      "45",
      "50",
      "56"
    ],
    [
      "0c",
      "24",
      "27",
      "31"
    ]
  ],
  "hexes": {
    "white": {
      "": [
        "H2",
        "L8",
        "O11",
        "B12",
        "J12",
        "D14"
      ],
      "border=edge:0,type:impassable": [
        "C11"
      ],
      "border=edge:1,type:impassable": [
        "B4",
        "C7"
      ],
      "border=edge:2,type:impassable": [
        "N12"
      ],
      "border=edge:4,type:impassable": [
        "D6"
      ],
      "border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:5,type:impassable": [
        "D8",
        "D10"
      ],
      "border=edge:3,type:impassable;upgrade=cost:160,terrain:mountain": [
        "F8"
      ],
      "border=edge:4,type:impassable;upgrade=cost:160,terrain:mountain": [
        "L10"
      ],
      "border=edge:2,type:impassable;border=edge:4,type:impassable;upgrade=cost:160,terrain:mountain": [
        "E9"
      ],
      "town=revenue:0": [
        "G1",
        "G3",
        "K7",
        "N10",
        "G13"
      ],
      "town=revenue:0;border=edge:4,type:impassable": [
        "C3",
        "E7"
      ],
      "border=edge:1,type:impassable;upgrade=cost:40,terrain:rough": [
        "B2"
      ],
      "border=edge:0,type:impassable;border=edge:1,type:impassable;upgrade=cost:40,terrain:rough": [
        "K11"
      ],
      "town=revenue:0;border=edge:3,type:impassable;upgrade=cost:160,terrain:mountain": [
        "F10"
      ],
      "upgrade=cost:40,terrain:rough": [
        "H6",
        "H10"
      ],
      "upgrade=cost:80,terrain:hills": [
        "E3",
        "F6",
        "I5",
        "G7"
      ],
      "upgrade=cost:160,terrain:mountain": [
        "D2",
        "F2",
        "F4",
        "G5",
        "J8",
        "G11",
        "D12",
        "L12"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:rough": [
        "D4",
        "I7",
        "J10"
      ],
      "town=revenue:0;upgrade=cost:80,terrain:hills": [
        "H4",
        "G9"
      ],
      "town=revenue:0;upgrade=cost:160,terrain:mountain": [
        "E5",
        "I9"
      ],
      "town=revenue:0;border=edge:2,type:impassable;border=edge:3,type:impassable;upgrade=cost:160,terrain:mountain": [
        "E11"
      ],
      "city=revenue:0;upgrade=cost:80,terrain:hills": [
        "H8"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:rough": [
        "J6"
      ]
    },
    "yellow": {
      "upgrade=cost:160,terrain:mountain;path=a:0,b:3,track:narrow": [
        "K9"
      ],
      "label=P;city=revenue:30;path=a:5,b:_0;path=a:2,b:_0;path=a:3,b:_0": [
        "C5"
      ],
      "label=C;city=revenue:40;path=a:1,b:_0": [
        "H12"
      ],
      "label=S;city=revenue:10;path=a:2,b:_0,track:narrow": [
        "M13"
      ],
      "label=M;city=revenue:30;path=a:0,b:_0": [
        "B14"
      ],
      "city=revenue:20;upgrade=cost:40,terrain:rough;path=a:1,b:_0;path=a:4,b:_0,track:narrow;border=edge:3,type:impassable;border=edge:5,type:impassable": [
        "M11"
      ],
      "path=a:2,b:4": [
        "I11"
      ]
    },
    "blue": {
      "offboard=revenue:20;path=a:5,b:_0": [
        "a12"
      ],
      "offboard=revenue:10;path=a:0,b:_0": [
        "A5"
      ],
      "offboard=revenue:20;path=a:4,b:_0,track:dual": [
        "N8"
      ],
      "offboard=revenue:60;path=a:2,b:_0": [
        "L14"
      ]
    },
    "gray": {
      "": [
        "F12"
      ],
      "path=a:1,b:5,track:dual": [
        "A15"
      ],
      "path=a:1,b:2,track:dual": [
        "B16"
      ],
      "offboard=revenue:yellow_10|green_30|brown_90;path=a:4,b:_0,track:dual": [
        "C15"
      ],
      "town=revenue:10;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:5,b:_0": [
        "C9"
      ],
      "path=a:1,b:4,track:narrow;path=a:2,b:3": [
        "C13"
      ],
      "town=revenue:10;path=a:0,b:_0;path=a:2,b:_0,track:narrow;path=a:4,b:_0": [
        "E13"
      ],
      "town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:5,b:_0": [
        "A13",
        "K13"
      ],
      "border=edge:4,type:impassable;city=revenue:yellow_20|green_30|brown_40;path=a:0,b:_0,track:dual;path=a:5,b:_0,track:dual": [
        "C1"
      ],
      "city=revenue:yellow_20|green_30|brown_40;path=a:0,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual": [
        "E1"
      ],
      "city=slots:2,revenue:yellow_20|green_30|brown_40;path=a:1,b:_0,track:dual;path=a:2,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;path=a:5,b:_0": [
        "M9"
      ]
    }
  },
  "phases": [
    {
      "name": "4",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    }
  ],
  "companies": [
  ],
  "corporations": [
  ],
  "trains": [
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
