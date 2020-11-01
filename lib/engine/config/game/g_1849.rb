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
    "3": 12,
    "4": "9/11",
    "5": 9
  },
  "startingCash": {
    "3": 500,
    "4": 375,
    "5": 300
  },
  "capitalization": "full",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "M2": "Milazzo",
    "N3": "Messina",
    "A4": "Trapani",
    "C4": "Alcamo",
    "E4": "Palermo",
    "I4": "St. Stefano",
    "O4": "Calabria",
    "D5": "Partinico",
    "A6": "Marsala",
    "E6": "Corleone",
    "G6": "Termini Imerese",
    "K6": "Bronte",
    "M6": "Taormina",
    "J7": "Troina",
    "A8": "Mazzara",
    "C8": "Castelvetrano",
    "I8": "Castrogiovanni",
    "M8": "Acireale",
    "D9": "Sciacca",
    "H9": "Caltanisetta",
    "L9": "Catania",
    "G10": "Canicatti",
    "I10": "Piazza Armerina",
    "F11": "Girgenti",
    "J11": "Caltagirone",
    "G12": "Licata",
    "M12": "Augusta",
    "I14": "Terranova",
    "K14": "Ragusa",
    "M14": "Siacusa",
    "J15": "Vittoria"
  },
  "tiles": {
    "3": 4,
    "4": 4,
    "7": 4,
    "8": 10,
    "9": 6,
    "23": 3,
    "24": 3,
    "25": 2,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "30": 1,
    "31": 1,
    "39": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "58": 4,
    "73": 4,
    "74": 3,
    "77": 4,
    "78": 10,
    "79": 7,
    "624": 1,
    "644": 2,
    "645": 2,
    "646": 1,
    "647": 1,
    "648": 1,
    "649": 1,
    "650": 1,
    "651": 1,
    "652": 1,
    "653": 1,
    "654": 1,
    "655": 1,
    "656": 1,
    "657": 2,
    "658": 2,
    "659": 2,
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
    "672": 1,
    "673": 2,
    "674": 2,
    "675": 1,
    "676": 1,
    "677": 3,
    "678": 3,
    "679": 2,
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
    "696": 3,
    "697": 2,
    "698": 2,
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
    "715": 1
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
      "306",
      "340",
      "377"
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
      "216",
      "240",
      "266",
      "295",
      "328"
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
      "144",
      "159",
      "177",
      "196",
      "218",
      "242",
      "269",
      "298"
    ],
    [
      "54",
      "62",
      "71",
      "80",
      "90",
      "100",
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
      "68",
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
      "Closed",
      "24",
      "27",
      "31"
    ]
  ],
  "companies": [
    {
      "name": "Società Corriere Etnee",
      "value": 20,
      "revenue": 5,
      "desc": "A Corporation cannot build track in the Acireale hex until this Company is either eliminated or bought by any Corporation."
    },
    {
      "name": "Studio di Ingegneria Giuseppe Incorpora",
      "value": 45,
      "revenue": 10,
      "desc": "The owning Corporation can lay or upgrade standard gauge track at half cost on Mountain, Hill or Rough hexes. Narrow gauge track is still at normal cost."
    },
    {
      "name": "Compagnia Navale Mediterranea",
      "value": 75,
      "revenue": 15,
      "desc": "The owning Corporation can place the +L. 20 token on any port. This action closes the Company but the Corporation adds L. 20 to the revenue of the port until the end of the game."
    },
    {
      "name": "Società Marittima Siciliana",
      "value": 110,
      "revenue": 20,
      "desc": "The owning Corporation can place a tile and a token on a coastal city, even if that city is not connected to one of its railheads. This action closes the Company, and is made instead of the regular Track Laying and Token Laying Steps."
    },
    {
      "name": "Reale Società d'Affari",
      "value": 150,
      "revenue": 25,
      "desc": "When a player buys the R.S.A. they immediately open the first available corporation and get the president's certificate. The R.S.A. is eliminated when the Corporation buys its first train."
    }
  ],
  "corporations": [
    {
      "sym": "AFG",
      "name": "Azienda Ferroviaria Garibaldi",
      "logo": "1849/AFG",
      "tokens": [
        40,
        0,
        0
      ],
      "color": "red"
    },
    {
      "sym": "ATA",
      "name": "Azienda Trasporti Archimede",
      "logo": "1849/ATA",
      "tokens": [
        30,
        0,
        0
      ],
      "coordinates": "M14",
      "color": "green"
    },
    {
      "sym": "CTL",
      "name": "Compagnia Trasporti Lilibeo",
      "logo": "1849/CTL",
      "tokens": [
        40,
        0,
        0
      ],
      "coordinates": "A6",
      "color": "yellow"
    },
    {
      "sym": "IFT",
      "name": "Impresa Ferroviaria Trinacria",
      "logo": "1849/IFT",
      "tokens": [
        90,
        0,
        0
      ],
      "coordinates": "L9",
      "color": "blue"
    },
    {
      "sym": "RCS",
      "name": "Rete Centrale Sicula",
      "logo": "1849/RCS",
      "tokens": [
        130,
        0,
        0
      ],
      "coordinates": "E4",
      "color": "orange"
    },
    {
      "sym": "SFA",
      "name": "Società Ferroviaria Akragas",
      "logo": "1849/SFA",
      "tokens": [
        40,
        0,
        0
      ],
      "coordinates": "F11",
      "color": "pink"
    }
  ],
  "trains": [
    {
      "name": "4H",
      "distance": 4,
      "price": 100,
      "rusts_on": "8H",
      "num": 4
    },
    {
      "name": "6H",
      "distance": 6,
      "price": 200,
      "rusts_on": "10H",
      "num": 4
    },
    {
      "name": "8H",
      "distance": 8,
      "price": 350,
      "rusts_on": "16H",
      "num": 3
    },
    {
      "name": "10H",
      "distance": 10,
      "price": 550,
      "num": 2
    },
    {
      "name": "12H",
      "distance": 12,
      "price": 800,
      "num": 1
    },
    {
      "name": "16H",
      "distance": 16,
      "price": 1100,
      "num": 5
    },
    {
      "name": "R6H",
      "distance": 999,
      "price": 350,
      "num": 2,
      "available_on": "16H"
    }
  ],
  "hexes": {
    "blue": {
      "path=a:5,b:_0": [
        "L1"
      ],
      "path=a:0,b:_0": [
        "E2"
      ],
      "path=a:2,b:_0": [
        "N13"
      ],
      "path=a:4,b:_0": [
        "H15"
      ]
    },
    "gray": {
      "town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:5,b:_0": [
        "M2",
        "M12"
      ],
      "path=a:0,b:1,track:dual": [
        "O2"
      ],
      "city=revenue:white_20|gray_30|white_40;path=a:0,b:_0,track:dual;path=a:5,b:_0,track:dual": [
        "A4"
      ],
      "town=revenue:10;path=a:1,b:_0;path=a:5,b:_0;path=a:0,b:_0,track:narrow": [
        "I4"
      ],
      "path=a:2,b:3;path=a:1,b:4,track:narrow": [
        "M4"
      ],
      "town=revenue:white_10|gray_30|white_90;path=a:3,b:_0,track:dual": [
        "O4"
      ],
      "city=revenue:white_20|gray_30|white_40;path=a:0,b:_0,track:dual;path=a:3,b:_0,track:dual;path=a:4,b:_0,track:dual;path=a:5,b:_0,track:dual": [
        "A6"
      ],
      "town=revenue:10;path=a:2,b:_0,track:narrow;path=a:4,b:_0;path=a:0,b:_0": [
        "M6"
      ],
      "": [
        "L7"
      ],
      "city=revenue:white_20|gray_30|white_40,slots:2;path=a:1,b:_0,track:dual;path=a:2,b:_0;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;path=a:5,b:_0": [
        "I14"
      ]
    },
    "white": {
      "": [
        "L3",
        "N5",
        "B9",
        "D3",
        "F5",
        "G4",
        "H5",
        "J5",
        "K4",
        "L11",
        "L15",
        "H13",
        "K16"
      ],
      "town=revenue:0": [
        "C4",
        "G6",
        "A8",
        "C8",
        "M8",
        "I10",
        "G12",
        "J15"
      ],
      "upgrade=cost:160,terrain:mountain": [
        "B5",
        "L5",
        "B7",
        "D7",
        "E8",
        "H7",
        "I6",
        "K8",
        "H11",
        "L13",
        "J13"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:mountain": [
        "D5",
        "G10",
        "J11"
      ],
      "upgrade=cost:80,terrain:mountain": [
        "C6",
        "F7",
        "G8",
        "E10"
      ],
      "town=revenue:0;upgrade=cost:160,terrain:mountain": [
        "E6",
        "K6",
        "J7"
      ],
      "town=revenue:0;upgrade=cost:80,terrain:mountain": [
        "I8",
        "D9"
      ],
      "upgrade=cost:40,terrain:mountain": [
        "B3",
        "F9",
        "J9",
        "K12"
      ],
      "city=revenue:0;upgrade=cost:80,terrain:mountain": [
        "H9"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:mountain": [
        "F11"
      ]
    },
    "yellow": {
      "city=revenue:30;path=a:0,b:_0;label=M": [
        "N3"
      ],
      "city=revenue:50;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=P": [
        "E4"
      ],
      "city=revenue:40;path=a:1,b:_0;label=C": [
        "L9"
      ],
      "path=a:2,b:4": [
        "K10"
      ],
      "path=a:0,b:3,track:narrow;upgrade=cost:160,terrain:mountain": [
        "I12"
      ],
      "city=revenue:20;path=a:1,b:_0;path=a:4,b:_0,track:narrow;upgrade=cost:40,terrain:mountain": [
        "K14"
      ],
      "city=revenue:10;path=a:2,b:_0,track:narrow;label=S": [
        "M14"
      ]
    }
  },
  "phases": [
    {
      "name": "4",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ]
    },
    {
      "name": "6",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ]
    },
    {
      "name": "8",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ]
    },
    {
      "name": "10",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "12",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "16",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
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
