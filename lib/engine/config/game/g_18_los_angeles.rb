# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18LosAngeles
        JSON = <<-'DATA'
{
  "filename": "18_los_angeles",
  "modulename": "18LosAngeles",
  "certLimit": {
    "2": 19,
    "3": 14,
    "4": 12,
    "5": 11
  },
  "locationNames": {
    "A2": "Reseda",
    "A4": "Van Nuys",
    "A6": "Burbank",
    "A8": "Pasadena",
    "A10": "Lancaster",
    "A12": "Victorville",
    "A14": "San Bernardino",
    "B1": "Oxnard",
    "B3": "Beverly Hills",
    "B5": "Hollywood",
    "B7": "South Pasadena",
    "B9": "Alhambra",
    "B11": "Azusa",
    "B13": "San Dimas",
    "B15": "Pomona",
    "C2": "Santa Monica",
    "C4": "Culver City",
    "C6": "Los Angeles",
    "C8": "Montebello",
    "C10": "Puente",
    "C12": "Walnut",
    "C14": "Riverside",
    "D3": "El Segundo",
    "D5": "Gardena",
    "D7": "Compton",
    "D9": "Norwalk",
    "D11": "La Habra",
    "D13": "Yorba Linda",
    "D15": "Palm Springs",
    "E4": "Redondo Beach",
    "E6": "Torrance",
    "E8": "Long Beach",
    "E10": "Cypress",
    "E12": "Anaheim",
    "E14": "Alta Vista",
    "E16": "Corona",
    "F5": "San Pedro",
    "F7": "Port of Long Beach",
    "F9": "Westminster",
    "F11": "Garden Grove",
    "F13": "Santa Ana",
    "F15": "Irvine"
  },
  "tiles": {
    "5": 3,
    "6": 4,
    "7": 4,
    "8": 4,
    "9": 4,
    "14": 4,
    "15": 5,
    "16": 2,
    "17": 1,
    "18": 1,
    "19": 2,
    "20": 2,
    "21": 1,
    "22": 1,
    "23": 4,
    "24": 4,
    "25": 2,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "30": 1,
    "31": 1,
    "39": 1,
    "40": 1,
    "41": 2,
    "42": 2,
    "43": 2,
    "44": 1,
    "45": 2,
    "46": 2,
    "47": 2,
    "51": 2,
    "57": 4,
    "70": 1,
    "290": 1,
    "291": 1,
    "292": 1,
    "293": 1,
    "294": 2,
    "295": 2,
    "296": 1,
    "297": 2,
    "298LA": 1,
    "299LA": 1,
    "300LA": 1,
    "611": 4,
    "619": 3
  },
  "companies": [
    {
      "name": "Gardena Tramway",
      "value": 140,
      "treasury": 60,
      "revenue": 0,
      "desc": "Starts with $60 in treasury, a 2 train, and a token in Gardena (D5). In ORs, this is the first minor to operate. May only lay or upgrade 1 tile per OR. Splits revenue evenly with owner. May be sold to a corporation for up to $140.",
      "sym": "GT"
    },
    {
      "name": "Orange County Railroad",
      "value": 100,
      "treasury": 40,
      "revenue": 0,
      "desc": "Starts with $40 in treasury, a 2 train, and a token in Cypress (E10). In ORs, this is the second minor to operate. May only lay or upgrade 1 tile per OR. Splits revenue evenly with owner. May be sold to a corporation for up to $100.",
      "sym": "OCR"
    },
    {
      "name": "Pacific Maritime",
      "value": 60,
      "revenue": 10,
      "desc": "Reserves a token slot in Long Beach (E8), in the city next to Norwalk (D9). The owning corporation may place an extra token there at no cost, with no connection needed. Once this company is purchased by a corporation, the slot that was reserved may be used by other corporations.",
      "sym": "PMC",
      "abilities": [
        {
          "type": "token",
          "owner_type":"corporation",
          "hexes": [
            "E8"
          ],
          "city": 2,
          "price": 0,
          "teleport_price": 0,
          "count": 1,
          "extra": true
        },
        {
          "type": "reservation",
          "remove": "sold",
          "hex": "E8",
          "city": 2
        }
      ]
    },
    {
      "name": "United States Mail Contract",
      "value": 80,
      "revenue": 0,
      "desc": "Adds $10 per location visited by any one train of the owning corporation. Never closes once purchased by a corporation.",
      "sym": "MAIL",
      "abilities": [
        {
          "type": "close",
          "when": "never",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Chino Hills Excavation",
      "value": 60,
      "revenue": 20,
      "desc": "Reduces, for the owning corporation, the cost of laying all hill tiles and tunnel/pass hexsides by $20.",
      "sym": "CHE",
      "abilities": [
        {
          "type":"tile_discount",
          "discount": 20,
          "terrain": "mountain",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Los Angeles Citrus",
      "value": 60,
      "revenue": 15,
      "desc": "The owning corporation may assign Los Angeles Citrus to either Riverside (C14) or Port of Long Beach (F7), to add $30 to all routes it runs to this location.",
      "sym": "LAC",
      "abilities": [
        {
          "type": "assign_hexes",
          "hexes": [
            "C14",
            "F7"
          ],
          "count": 1,
          "owner_type": "corporation"
        },
        {
          "type": "assign_corporation",
          "when": "sold",
          "count": 1,
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Los Angeles Steamship",
      "value": 40,
      "revenue": 10,
      "desc": "The owning corporation may assign the Los Angeles Steamship to one of Oxnard (B1), Santa Monica (C2), Port of Long Beach (F7), or Westminster (F9), to add $20 per port symbol to all routes it runs to this location.",
      "sym": "LAS",
      "abilities": [
        {
          "type": "assign_hexes",
          "hexes": [
            "B1",
            "C2",
            "F7",
            "F9"
          ],
          "count_per_or": 1,
          "owner_type": "corporation"
        },
        {
          "type": "assign_corporation",
          "when": "sold",
          "count": 1,
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "South Bay Line",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may make an extra $0 cost tile upgrade of either Redondo Beach (E4) or Torrance (E6), but not both.",
      "sym": "SBL",
      "abilities": [
        {
           "type":"tile_lay",
           "owner_type":"corporation",
           "free":true,
           "hexes":[
              "E4",
              "E6"
           ],
            "tiles": [
              "14",
              "15",
              "619"
            ],
           "special": false,
           "when":"track",
           "count": 1
        }
      ]
    },
    {
      "name": "Puente Trolley",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may lay an extra $0 cost yellow tile in Puente (C10), even if they are not connected to Puente.",
      "sym": "PT",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "C10"
          ]
        },
        {
           "type":"tile_lay",
           "owner_type":"corporation",
           "free":true,
           "hexes":[
              "C10"
           ],
            "tiles": [
              "7",
              "8",
              "9"
            ],
           "when":"track",
           "blocks":false,
           "count": 1
        }
      ]
    },
    {
      "name": "Beverly Hills Carriage",
      "value": 40,
      "revenue": 15,
      "desc": "The owning corporation may lay an extra $0 cost yellow tile in Beverly Hills (B3), even if they are not connected to Beverly Hills. Any terrain costs are ignored.",
      "sym": "BHC",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "B3"
          ]
        },
        {
           "type":"tile_lay",
           "owner_type":"corporation",
           "free":true,
           "hexes":[
              "B3"
           ],
            "tiles": [
              "7",
              "8",
              "9"
            ],
           "when":"track",
           "blocks": false,
           "count": 1
        }
      ]
    },
    {
      "name": "Dewey, Cheatham, and Howe",
      "value": 40,
      "revenue": 10,
      "desc": "The owning corporation may place a token (from their charter, paying the normal cost) in a city they are connected to that does not have any open token slots. If a later tile placement adds a new slot, this token fills that slot. This ability may not be used in Long Beach (E8).",
      "sym": "DC&H",
      "min_players": 3,
      "abilities": [
        {
          "type": "token",
          "owner_type":"corporation",
          "count": 1,
          "from_owner": true,
          "cheater": 0,
          "discount": 0,
          "hexes": [
            "A2", "A4", "A6", "A8", "B5", "B7", "B9", "B11", "B13", "C2", "C4",
            "C6", "C8", "C12", "D5", "D7", "D9", "D11", "D13", "E4", "E6",
            "E10", "E12", "F7", "F9", "F11", "F13"
          ]
        }
      ]
    },
    {
      "name": "Los Angeles Title",
      "value": 40,
      "revenue": 10,
      "desc": "The owning corporation may place an Open City token in any unreserved slot except for Long Beach (E8). The owning corporation need not be connected to the city where the token is placed.",
      "sym": "LAT",
      "min_players": 3,
      "abilities": [
        {
          "type": "token",
          "owner_type":"corporation",
          "price": 0,
          "teleport_price": 0,
          "count": 1,
          "neutral": true,
          "hexes": [
            "A4", "A6", "A8", "B5", "B7", "B9", "B11", "B13", "C4", "C6", "C8",
            "C12", "D5", "D7", "D9", "D11", "D13", "E4", "E6", "E10", "E12",
            "F7", "F9", "F11", "F13"
          ]
        }
      ]
    }
  ],
  "minors": [
    {
      "sym": "GT",
      "name": "Gardena Tramway",
      "logo": "18_los_angeles/GT",
      "tokens": [0],
      "coordinates": "D5",
      "color": "brown",
      "text_color": "white"
    },
    {
      "sym": "OCR",
      "name": "Orange County Railroad",
      "logo": "18_los_angeles/OCR",
      "tokens": [0],
      "coordinates": "E10",
      "color": "purple",
      "text_color": "white"
    }
  ],
  "corporations": [
    {
      "float_percent": 20,
      "sym": "ELA",
      "name": "East Los Angeles & San Pedro Railroad",
      "logo": "18_los_angeles/ELA",
      "tokens": [
        0,
        80,
        80,
        80,
        80,
        80
      ],
      "abilities": [
        {
          "type": "token",
          "description": "Reserved $40/$60 Culver City (C4) token",
          "hexes": [
            "C4"
          ],
          "price": 40,
          "teleport_price": 60
        },
        {
          "type": "reservation",
          "hex": "C4",
          "remove": "IV"
        }
      ],
      "coordinates": "C12",
      "color": "red",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "LA",
      "name": "Los Angeles Railway",
      "logo": "18_los_angeles/LA",
      "tokens": [
        0,
        80,
        80,
        80,
        80
      ],
      "abilities": [
        {
          "type": "token",
          "description": "Reserved $40 Alhambra (B9) token",
          "hexes": [
            "B9"
          ],
          "count": 1,
          "price": 40
        },
        {
          "type": "reservation",
          "hex": "B9",
          "remove": "IV"
        }
      ],
      "coordinates": "A8",
      "color": "green",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "LAIR",
      "name": "Los Angeles and Independence Railroad",
      "logo": "18_los_angeles/LAIR",
      "tokens": [
        0,
        80,
        80,
        80,
        80
      ],
      "coordinates": "A2",
      "color": "lightBlue",
      "text_color": "black",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "PER",
      "name": "Pacific Electric Railroad",
      "logo": "18_los_angeles/PER",
      "tokens": [
        0,
        80,
        80,
        80
      ],
      "coordinates": "F13",
      "color": "orange",
      "text_color": "black",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "SF",
      "name": "Santa Fe Railroad",
      "logo": "18_los_angeles/SF",
      "tokens": [
        0,
        80,
        80,
        80,
        80
      ],
      "abilities": [
        {
          "type": "token",
          "description": "Reserved $40 Montebello (C8) token",
          "hexes": [
            "C8"
          ],
          "count": 1,
          "price": 40
        },
        {
          "type": "reservation",
          "hex": "C8",
          "remove": "IV"
        }
      ],
      "coordinates": "D13",
      "color": "pink",
      "text_color": "black",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "SP",
      "name": "Southern Pacific Railroad",
      "logo": "18_los_angeles/SP",
      "tokens": [
        0,
        80,
        80,
        80,
        80
      ],
      "abilities": [
        {
          "type": "token",
          "description": "Reserved $40/$100 Los Angeles (C6) token",
          "hexes": [
            "C6"
          ],
          "price": 40,
          "count": 1,
          "teleport_price": 100
        },
        {
          "type": "reservation",
          "hex": "C6",
          "remove": "IV"
        }
      ],
      "coordinates": "C2",
      "color": "blue",
      "always_market_price": true
    },
    {
      "float_percent": 20,
      "sym": "UP",
      "name": "Union Pacific Railroad",
      "logo": "18_los_angeles/UP",
      "tokens": [
        0,
        80,
        80,
        80,
        80
      ],
      "coordinates": "B11",
      "color": "black",
      "always_market_price": true
    }
  ],
  "hexes": {
    "white": {
      "": [
        "C10"
      ],
      "upgrade=cost:40,terrain:water": [
        "D3"
      ],
      "city=revenue:0;border=edge:0,type:mountain,cost:20": [
        "A4"
      ],
      "border=edge:3,type:mountain,cost:20;border=edge:4,type:mountain,cost:20": [
        "B3"
      ],
      "city=revenue:0;border=edge:3,type:mountain,cost:20;border=edge:1,type:water,cost:40": [
        "B9"
      ],
      "city=revenue:0;border=edge:2,type:mountain,cost:20;border=edge:3,type:mountain,cost:20;label=Z": [
        "B13"
      ],
      "city=revenue:0;border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40": [
        "B7"
      ],
      "city=revenue:0;border=edge:2,type:water,cost:40": [
        "C8"
      ],
      "city=revenue:0;border=edge:3,type:water,cost:40": [
        "D5"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:mountain": [
        "C12"
      ],
      "city=revenue:0;border=edge:4,type:water,cost:40;stub=edge:0": [
        "D9"
      ],
      "city=revenue:0;border=edge:1,type:water,cost:40": [
        "D11"
      ],
      "city=revenue:0;icon=image:18_los_angeles/sbl,sticky:1": [
        "E4"
      ],
      "city=revenue:0;icon=image:18_los_angeles/sbl,sticky:1;stub=edge:4": [
        "E6"
      ],
      "city=revenue:0;border=edge:0,type:water,cost:40;stub=edge:1": [
        "E10"
      ],
      "city=revenue:0;label=Z": [
        "E12"
      ],
      "upgrade=cost:40,terrain:mountain;border=edge:5,type:mountain,cost:20": [
        "E14"
      ],
      "city=revenue:0": [
        "A6",
        "C4",
        "F11"
      ],
      "city=revenue:0;stub=edge:5": [
        "D7"
      ]
    },
    "gray": {
      "city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:1,type:mountain,cost:20": [
        "B5"
      ],
      "city=revenue:10;icon=image:port;icon=image:port;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;": [
        "C2"
      ],
      "city=revenue:20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;": [
        "D13"
      ],
      "city=revenue:10;border=edge:3,type:water,cost:40;icon=image:port;icon=image:port;path=a:3,b:_0;path=a:4,b:_0": [
        "F9"
      ],
      "path=a:2,b:3": [
        "F5"
      ],
      "offboard=revenue:0,visit_cost:100;path=a:0,b:_0": [
        "a9"
      ],
      "offboard=revenue:0,visit_cost:100;path=a:2,b:_0": [
        "G14"
      ]
    },
    "red": {
      "city=revenue:yellow_30|brown_50,groups:NW;label=N/W;icon=image:1846/20;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1": [
        "A2"
      ],
      "offboard=revenue:yellow_20|brown_40,groups:N|NW|NE;label=N;border=edge:0,type:mountain,cost:20;border=edge:1,type:mountain,cost:20;border=edge:5,type:mountain,cost:20;icon=image:1846/30;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0": [
        "A10"
      ],
      "offboard=revenue:yellow_20|brown_40,groups:N|NW|NE;label=N;border=edge:0,type:mountain,cost:20;border=edge:5,type:mountain,cost:20;icon=image:1846/20;path=a:0,b:_0;path=a:5,b:_0": [
        "A12"
      ],
      "offboard=revenue:yellow_20|brown_40,groups:NE;label=N/E;border=edge:0,type:mountain,cost:20;icon=image:1846/20;path=a:0,b:_0": [
        "A14"
      ],
      "offboard=revenue:yellow_40|brown_10,groups:W|NW|SW;label=W;icon=image:port;icon=image:1846/30;path=a:4,b:_0;path=a:5,b:_0": [
        "B1"
      ],
      "offboard=revenue:yellow_20|brown_50,groups:E|NE|SE;label=E;icon=image:1846/30;path=a:1,b:_0": [
        "B15"
      ],
      "offboard=revenue:yellow_30|brown_70,groups:E|NE|SE;label=E;icon=image:1846/30;icon=image:18_los_angeles/meat;path=a:1,b:_0;path=a:2,b:_0": [
        "C14"
      ],
      "offboard=revenue:yellow_20|brown_40,groups:E|NE|SE;label=E;icon=image:1846/30;path=a:0,b:_0;path=a:1,b:_0": [
        "D15"
      ],
      "offboard=revenue:yellow_20|brown_40,groups:SE;label=S/E;icon=image:1846/20;path=a:1,b:_0": [
        "E16"
      ],
      "offboard=revenue:yellow_20|brown_50,groups:SE;label=S/E;border=edge:2,type:mountain,cost:20;path=a:1,b:_0;path=a:2,b:_0;icon=image:1846/20": [
        "F15"
      ],
      "offboard=revenue:yellow_20|brown_40,groups:S|SE|SW;label=S;path=a:3,b:_0;icon=image:1846/50;icon=image:18_los_angeles/meat;icon=image:port": [
        "F7"
      ]
    },
    "yellow": {
      "city=revenue:20;path=a:1,b:_0;path=a:5,b:_0;border=edge:4,type:mountain,cost:20": [
        "A8"
      ],
      "city=revenue:20;border=edge:2,type:mountain,cost:20;border=edge:3,type:mountain,cost:20;path=a:1,b:_0;path=a:4,b:_0": [
        "B11"
      ],
      "city=revenue:40,slots:2;path=a:0,b:_0;path=a:4,b:_0;label=Z;border=edge:0,type:water,cost:40": [
        "C6"
      ],
      "city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;city=revenue:10,groups:LongBeach;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_2;path=a:4,b:_3;stub=edge:0;label=LB": [
        "E8"
      ],
      "city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0": [
        "F13"
      ]
    }
  }
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
