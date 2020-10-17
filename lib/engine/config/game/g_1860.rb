# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1860
        JSON = <<-'DATA'
{
  "filename": "1860",
  "modulename": "1860",
  "currencyFormatStr": "£%d",
  "bankCash": 10000,
  "certLimit": {
    "2": 32,
    "3": 21,
    "4": 16
  },
  "startingCash": {
    "2": 1000,
    "3": 670,
    "4": 500
  },
  "capitalization": "full",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "A5": "Norton Green",
    "A7": "Totland",
    "G1": "East Cowes",
    "F2": "Cowes",
    "J2": "Ryde Pier",
    "G3": "Whippingham",
    "I3": "Ryde",
    "B4": "Yarmouth",
    "F4": "Cement Mills",
    "H4": "Wooton & Havenstreet",
    "J4": "Ryde",
    "H8": "Horringford",
    "G11": "Whitwell",
    "F6": "Carisbrooke",
    "D6": "Calbourne",
    "E5": "Watchingwell",
    "C5": "Ningwood",
    "F10": "Chale Green",
    "G5": "Newport",
    "I5": "Ashey",
    "K5": "St. Helens",
    "B6": "Freshwater",
    "J8": "Sandown",
    "J6": "Brading",
    "L6": "Bembridge",
    "C7": "Shalcombe",
    "H10": "Wroxall",
    "H12": "St. Lawrence",
    "G7": "Merstone",
    "I7": "Newchurch & Alverstone",
    "E9": "Shorwell",
    "G9": "Godshill",
    "I9": "Shanklin",
    "I11": "Ventnor",
    "F12": "Chale"
  },
  "tiles": {
    "5": 2,
    "6": 2,
    "7": 2,
    "8": 4,
    "9": 4,
    "12": 2,
    "16": 2,
    "17": 2,
    "18": 2,
    "19": 2,
    "20": 2,
    "21": 1,
    "22": 1,
    "57": 2,
    "115": 2,
    "205": 1,
    "206": 1,
    "625": 1,
    "626": 1,
    "741": {
      "count": 5,
      "color": "yellow",
      "code": "halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0"
    },
    "742": {
      "count": 10,
      "color": "yellow",
      "code": "halt=symbol:£;path=a:0,b:_0;path=a:2,b:_0"
    },
    "743": {
      "count": 7,
      "color": "yellow",
      "code": "halt=symbol:£;path=a:0,b:_0;path=a:3,b:_0"
    },
    "744": {
      "count": 2,
      "color": "yellow",
      "code": "halt=symbol:£,loc:0;halt=symbol:£,loc:3;path=a:0,b:_0;path=a:3,b:_1;path=a:_0,b:_1"
    },
    "745": {
      "count": 2,
      "color": "yellow",
      "code": "halt=symbol:£,loc:0;halt=symbol:£,loc:2;path=a:0,b:_0;path=a:2,b:_1;path=a:_0,b:_1"
    },
    "746": {
      "count": 2,
      "color": "yellow",
      "code": "city=revenue:20;path=a:0,b:_0;path=a:_0,b:3;label=B"
    },
    "747": {
      "count": 3,
      "color": "green",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:_0,b:1"
    },
    "748": {
      "count": 3,
      "color": "green",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:_0,b:2"
    },
    "749": {
      "count": 2,
      "color": "green",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:_0,b:3"
    },
    "750": {
      "count": 3,
      "color": "green",
      "code": "halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0"
    },
    "751": {
      "count": 3,
      "color": "green",
      "code": "halt=symbol:£;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0"
    },
    "752": {
      "count": 3,
      "color": "green",
      "code": "halt=symbol:£;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0"
    },
    "753": {
      "count": 3,
      "color": "green",
      "code": "halt=symbol:£;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0"
    },
    "754": {
      "count": 2,
      "color": "green",
      "code": "halt=symbol:£,loc:0;town=revenue:10,loc:center;path=a:0,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:_0,b:_1"
    },
    "755": {
      "count": 2,
      "color": "green",
      "code": "halt=symbol:£,loc:0;town=revenue:10,loc:center;path=a:0,b:_0;path=a:4,b:_1;path=a:3,b:_1;path=a:_0,b:_1"
    },
    "756": {
      "count": 2,
      "color": "green",
      "code": "city=revenue:30;path=a:0,b:_0;path=a:1,b:_0"
    },
    "757": {
      "count": 2,
      "color": "green",
      "code": "city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B"
    },
    "758": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:50;path=a:4,b:_0;path=a:5,b:_0;label=R"
    },
    "759": {
      "count": 3,
      "color": "green",
      "code": "city=revenue:30;path=a:0,b:_0"
    },
    "760": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:40,loc:4;city=revenue:40,loc:0.5;path=a:1,b:_1;path=a:2,b:_0;label=V"
    },
    "761": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:20,loc:center;halt=symbol:£,loc:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_1;path=a:_0,b:_1;label=M"
    },
    "762": {
      "count": 2,
      "color": "green",
      "code": "city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=B"
    },
    "763": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:50,loc:center;city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_1;label=N"
    },
    "764": {
      "count": 2,
      "color": "brown",
      "code": "town=revenue:20;path=a:0,b:_0;path=a:_0,b:1"
    },
    "765": {
      "count": 2,
      "color": "brown",
      "code": "town=revenue:20;path=a:0,b:_0;path=a:_0,b:3"
    },
    "766": {
      "count": 2,
      "color": "brown",
      "code": "town=revenue:20;path=a:0,b:_0;path=a:_0,b:2"
    },
    "767": {
      "count": 2,
      "color": "brown",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0"
    },
    "768": {
      "count": 2,
      "color": "brown",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0"
    },
    "769": {
      "count": 2,
      "color": "brown",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0"
    },
    "770": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B"
    },
    "771": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0"
    },
    "772": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:40;path=a:0,b:_0;path=a:1,b:_0"
    },
    "773": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,slots:2,loc:1.5;city=revenue:20,loc:4.5;path=a:0,b:_0;path=a:2,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_1;path=a:4,b:_1;path=a:_0,b:_1;label=N"
    },
    "774": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:50,loc:4;city=revenue:50,loc:1;path=a:2,b:_0;path=a:1,b:_1,loc:0.5;label=V"
    },
    "775": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:20,slots:2,loc:center;town=revenue:10,loc:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1;label=M"
    },
    "776": {
      "count": 3,
      "color": "brown",
      "code": "city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0"
    },
    "777": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:60;path=a:0,b:_0"
    },
    "778": {
      "count": 1,
      "color": "brown",
      "code": "path=a:0,b:3;path=a:1,b:5;path=a:2,b:4"
    },
    "779": {
      "count": 1,
      "color": "brown",
      "code": "path=a:4,b:5;path=a:1,b:3;path=a:0,b:2"
    },
    "780": {
      "count": 1,
      "color": "brown",
      "code": "path=a:1,b:2;path=a:4,b:5;path=a:0,b:3"
    },
    "781": {
      "count": 1,
      "color": "brown",
      "code": "path=a:0,b:1;path=a:2,b:3;path=a:4,b:5"
    },
    "782": {
      "count": 1,
      "color": "brown",
      "code": "town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1"
    },
    "783": {
      "count": 1,
      "color": "brown",
      "code": "town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;path=a:_0,b:_1"
    },
    "784": {
      "count": 1,
      "color": "brown",
      "code": "town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:_0,b:_1"
    },
    "785": {
      "count": 1,
      "color": "brown",
      "code": "town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:_0,b:_1"
    },
    "786": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60;path=a:4,b:_0;path=a:5,b:_0;label=R"
    },
    "787": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:20,loc:3;town=revenue:10,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;path=a:_2,b:_1;path=a:_0,b:_1;label=C"
    },
    "788": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:30,loc:3;town=revenue:10,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;path=a:1,b:_2;path=a:_2,b:_1;path=a:_0,b:_1;label=C"
    },
    "789": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:60,loc:3;town=revenue:20,loc:center;halt=symbol:£,loc:0;path=a:0,b:_2;path=a:1,b:_2;path=a:_2,b:_1;path=a:_0,b:_1;label=C"
    }
  },
  "market": [
    [
      "0c",
      "7",
      "14",
      "20",
      "26",
      "31",
      "36",
      "40",
      "44",
      "47",
      "50",
      "52",
      "54p",
      "56",
      "58p",
      "60",
      "62p",
      "65",
      "68p",
      "71",
      "74p",
      "78",
      "82p",
      "86",
      "90p",
      "95",
      "100p",
      "105",
      "110",
      "116",
      "122",
      "128",
      "134",
      "142",
      "150",
      "158",
      "166",
      "174",
      "182",
      "191",
      "200",
      "210",
      "220",
      "230",
      "240",
      "250",
      "260",
      "270",
      "280",
      "290",
      "300",
      "310",
      "320",
      "330",
      "340e"
    ]
  ],
  "companies": [
    {
      "name": "Brading Harbour Company",
      "value": 30,
      "revenue": 5,
      "desc": "Can be exchanged for a share in the BHI&R pubilc company.",
      "sym": "BHC",
      "abilities": [
        {
          "type": "exchange",
          "corporation": "BHI&R",
          "owner_type": "player",
          "from": "ipo"
        }
      ]
    },
    {
      "name": "Yarmouth Harbour Company",
      "value": 50,
      "revenue": 10,
      "desc": "Can be exchanged for a share in the FYN public company.",
      "sym": "YHC",
      "abilities": [
        {
          "type": "exchange",
          "corporation": "FYN",
          "owner_type": "player",
          "from": "ipo"
        }
      ]
    },
    {
      "name": "Cowes Marina and Harbour",
      "value": 90,
      "revenue": 20,
      "desc": "Can be exchanged for a share in the C&N public company.",
      "sym": "CMH",
      "abilities": [
        {
          "type": "exchange",
          "corporation": "C&N",
          "owner_type": "player",
          "from": "ipo"
        }
      ]
    },
    {
      "name": "Ryde Pier & Shipping Company",
      "value": 130,
      "revenue": 30,
      "desc": "Can be exchanged for a share in the IOW public company.",
      "sym": "RPSC",
      "abilities": [
        {
          "type": "exchange",
          "corporation": "IOW",
          "owner_type": "player",
          "from": "ipo"
        }
      ]
    },
    {
      "name": "Fishbourne Ferry Company",
      "value": 200,
      "revenue": 25,
      "desc": "Not available until the first 6+3 train has been purchased. Closes all other private companies.",
      "sym": "FFC"
    }
  ],
  "corporations": [
    {
      "sym": "C&N",
      "name": "Cowes & Newport",
      "logo": "1860/CN",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "F2",
      "color": "lightBlue",
      "text_color": "black"
    },
    {
      "sym": "IOW",
      "name": "Isle of Wight",
      "logo": "1860/IOW",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "I3",
      "color": "red"
    },
    {
      "sym": "IWNJ",
      "name": "Isle of Wight, Newport Juntion",
      "logo": "1860/IWNJ",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "G7",
      "color": "black"
    },
    {
      "sym": "FYN",
      "name": "Freshwater, Yarmouth & Newport",
      "logo": "1860/FYN",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "B4",
      "color": "green"
    },
    {
      "sym": "NGStL",
      "name": "Newport, Godshill & St. Lawrence",
      "logo": "1860/NGStL",
      "tokens": [
        0,
        40
      ],
      "coordinates": "G9",
      "color": "yellow",
      "text_color": "black"
    },
    {
      "sym": "BHI&R",
      "name": "Brading Harbour Improvement & Railway",
      "logo": "1860/BHIR",
      "tokens": [
        0,
        40
      ],
      "coordinates": "L6",
      "color": "pink"
    },
    {
      "sym": "S&C",
      "name": "Shanklin & Chale",
      "logo": "1860/SC",
      "tokens": [
        0,
        40
      ],
      "coordinates": "F12",
      "color": "violet"
    },
    {
      "sym": "VYSC",
      "name": "Ventor, Yarmouth & South Coast",
      "logo": "1860/VYSC",
      "tokens": [
        0,
        40
      ],
      "coordinates": "E9",
      "color": "brightGreen"
    }
  ],
  "trains": [
    {
      "name": "2+1",
      "distance": 2,
      "price": 250,
      "rusts_on": "4+2",
      "num": 5
    },
    {
      "name": "3+2",
      "distance": 3,
      "price": 300,
      "rusts_on": "6+3",
      "num": 4
    },
    {
      "name": "4+2",
      "distance": 4,
      "price": 350,
      "rusts_on": "7+4",
      "num": 3
    },
    {
      "name": "5+3",
      "distance": 5,
      "price": 400,
      "rusts_on": "8+4",
      "num": 2
    },
    {
      "name": "6+3",
      "distance": 6,
      "price": 500,
      "num": 2
    },
    {
      "name": "7+4",
      "distance": 7,
      "price": 600,
      "num": 1
    },
    {
      "name": "8+4",
      "distance": 8,
      "price": 700,
      "num": 1
    },
    {
      "name": "9+5",
      "distance": 9,
      "price": 800,
      "num": 6
    }
  ],
  "hexes": {
    "white": {
      "town=revenue:0;border=edge:1,type:impassable": [
        "G1"
      ],
      "town=revenue:0;border=edge:1,type:impassable;border=edge:2,type:impassable": [
        "G3"
      ],
      "town=revenue:0": [
        "H8",
        "G11",
        "F6",
        "D6",
        "E5",
        "C5",
        "F10"
      ],
      "town=revenue:0;border=edge:4,type:impassable": [
        "A5",
        "F4"
      ],
      "town=revenue:0;border=edge:0,type:impassable": [
        "I5"
      ],
      "city=revenue:0,loc:3;town=revenue:0,loc:1;town=revenue:0,loc:0;label=C;border=edge:4,type:impassable;border=edge:5,type:impassable": [
        "F2"
      ],
      "upgrade=cost:60,terrain:water": [
        "H2",
        "D4"
      ],
      "": [
        "E3",
        "K7",
        "D8"
      ],
      "city=revenue:0;border=edge:1,type:impassable": [
        "B4"
      ],
      "city=revenue:0": [
        "J4",
        "A7",
        "B6",
        "J8",
        "L6",
        "F12"
      ],
      "city=revenue:0;border=edge:0,type:impassable": [
        "I9"
      ],
      "town=revenue:0;town=revenue:0": [
        "H4"
      ],
      "town=revenue:0;town=revenue:0;border=edge:3,type:impassable": [
        "I7"
      ],
      "town=revenue:0;upgrade=cost:60,terrain:water": [
        "K5"
      ],
      "town=revenue:0;upgrade=cost:60,terrain:mountain": [
        "C7",
        "H10",
        "H12"
      ],
      "upgrade=cost:60,terrain:mountain": [
        "H6",
        "E7",
        "F8",
        "G13"
      ],
      "city=revenue:0;label=B": [
        "J6",
        "E9",
        "G9"
      ]
    },
    "blue": {
      "offboard=revenue:yellow_0|green_20|brown_40;path=a:1,b:_0": [
        "J2"
      ]
    },
    "yellow": {
      "city=revenue:30;path=a:5,b:_0;label=R": [
        "I3"
      ],
      "city=revenue:30;path=a:2,b:_0;path=a:3,b:_0;label=N": [
        "G5"
      ],
      "city=revenue:10;town=revenue:0;path=a:5,b:_0;label=M": [
        "G7"
      ],
      "city=revenue:30;path=a:2,b:_0;label=V;border=edge:3,type:impassable": [
        "I11"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ]
    },
    {
      "name": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ]
    },
    {
      "name": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ]
    },
    {
      "name": "5",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "6",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "7",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "8",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ]
    },
    {
      "name": "9",
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
