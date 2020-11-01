# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1841
        JSON = <<-'DATA'
{
  "filename": "1841",
  "modulename": "1841",
  "currencyFormatStr": "L.%d",
  "bankCash": 14400,
  "certLimit": {
    "3": 21,
    "4": 16,
    "5": 13,
    "6": 11,
    "7": 10,
    "8": 9
  },
  "startingCash": {
    "3": 1120,
    "4": 840,
    "5": 672,
    "6": 560,
    "7": 480,
    "8": 420
  },
  "capitalization": "full",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "A8": "Fréjus",
    "E2": "Simplon",
    "C6": "Aosta",
    "K2": "Tirano & Edolo",
    "M22": "Roma",
    "A6": "Lyon",
    "D1": "Lausanne / Lötschberg",
    "G2": "Gotthard",
    "D17": "Marseille",
    "M4": "Trento/Brennero",
    "Q6": "East",
    "Q16": "Adriatic Coast",
    "P15": "Forlí & Cesena",
    "F7": "Vercelli & Novara",
    "M18": "Pistoia & Prato",
    "E10": "Asti",
    "N21": "Siena",
    "I10": "Piacenza",
    "O10": "Rovigo",
    "O20": "Arezzo",
    "J17": "La Spezia",
    "C14": "Cuneo",
    "E16": "Albenga",
    "F15": "Savona",
    "I6": "Bergamo",
    "K6": "Brescia",
    "M8": "Verona",
    "O8": "Padova",
    "N13": "Bologna",
    "H7": "Milano",
    "G14": "Genova",
    "P7": "Venezia",
    "F11": "Alessandria",
    "N19": "Firenze",
    "K20": "Livorno",
    "K18": "Pisa",
    "L17": "Lucca",
    "G4": "Lugano",
    "G6": "Busto Arsizio",
    "H5": "Como",
    "H9": "Pavia",
    "J9": "Cremona",
    "L9": "Montova",
    "N7": "Vicenza",
    "P5": "Treviso",
    "K12": "Parma",
    "L13": "Reggio nell'Emilia",
    "M12": "Modena",
    "O12": "Ferrara",
    "P13": "Ravenna",
    "D9": "Torino"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 3,
    "4": 3,
    "5": 4,
    "6": 4,
    "7": 8,
    "8": 16,
    "9": 11,
    "12": 1,
    "13": 1,
    "14": 2,
    "15": 2,
    "16": 2,
    "17": 2,
    "18": 2,
    "19": 2,
    "20": 2,
    "21": 2,
    "22": 2,
    "23": 3,
    "24": 3,
    "25": 3,
    "26": 2,
    "27": 2,
    "28": 2,
    "29": 2,
    "30": 2,
    "31": 2,
    "39": 2,
    "40": 2,
    "41": 2,
    "42": 2,
    "43": 2,
    "44": 2,
    "45": 2,
    "46": 2,
    "47": 2,
    "55": 1,
    "56": 1,
    "57": 4,
    "58": 3,
    "63": 3,
    "69": 1,
    "70": 2,
    "87": 2,
    "88": 2,
    "144": 2,
    "201": 2,
    "202": 2,
    "204": 2,
    "205": 1,
    "206": 1,
    "207": 2,
    "208": 2,
    "216": 2,
    "602": 1,
    "603": 1,
    "604": 1,
    "605": 1,
    "606": 1,
    "607": 1,
    "609": 1,
    "610": 2,
    "611": 3,
    "612": 1,
    "613": 3,
    "614": 4,
    "615": 1,
    "616": 1,
    "617": 1,
    "618": 1,
    "619": 2,
    "621": 2,
    "622": 2,
    "623": 2,
    "624": 1,
    "625": 1,
    "626": 1,
    "627": 2,
    "628": 2,
    "629": 2,
    "630": 1,
    "631": 1,
    "632": 1,
    "633": 1
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
      "248y",
      "276y",
      "306y",
      "340y",
      "377y",
      "419o",
      "465o",
      "516o"
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
      "216y",
      "240y",
      "266y",
      "295y",
      "328y",
      "365o",
      "404o",
      "449o"
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
      "196y",
      "218y",
      "242y",
      "269y",
      "298y",
      "331o",
      "367o",
      "408o"
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
      "187y",
      "208y",
      "230y",
      "256y",
      "284y"
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
      "178y",
      "198y",
      "219y"
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
      "162y",
      "180y"
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
      "127",
      "141y"
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
      "95",
      "106"
    ],
    [
      "27",
      "31",
      "36",
      "40",
      "45",
      "50",
      "56",
      "62",
      "69",
      "76"
    ],
    [
      "21",
      "24",
      "27",
      "31",
      "35",
      "39",
      "43",
      "48",
      "53"
    ],
    [
      "16",
      "18",
      "20",
      "23",
      "26",
      "29",
      "32",
      "35"
    ],
    [
      "11",
      "13",
      "15",
      "16",
      "18",
      "20",
      "23"
    ],
    [
      "8",
      "9",
      "10",
      "11",
      "13",
      "14"
    ]
  ],
  "companies": [
    {
      "name": "Società della Strada di Ferro da Napoli a Noeera e Castellamunare",
      "value": 50,
      "revenue": 20,
      "desc": "No special abilities."
    },
    {
      "name": "Società della Dtrada Ferrata da Lucca a Pistoia",
      "value": 50,
      "revenue": 0,
      "desc": "No special abilities."
    },
    {
      "name": "Strada di Ferro da Torino a Cuneo",
      "value": 50,
      "revenue": 0,
      "desc": "No special abilities."
    },
    {
      "name": "Società per la Strada Ferrata Maria Autonia",
      "value": 50,
      "revenue": 0,
      "desc": "No special abilities."
    },
    {
      "name": "Strada di Ferro da Torina a Novara",
      "value": 50,
      "revenue": 0,
      "desc": "No special abilities."
    },
    {
      "name": "Società per la Strada Ferrata Leopolda",
      "value": 50,
      "revenue": 0,
      "desc": "No special abilities."
    },
    {
      "name": "Strada Ferrata da Torino a Genova",
      "value": 50,
      "revenue": 0,
      "desc": "No special abilities."
    },
    {
      "name": "Imperial Regia Strada Ferrata Ferdinandea",
      "value": 50,
      "revenue": 0,
      "desc": "No special abilities."
    }
  ],
  "corporations": [
    {
      "sym": "SFMA",
      "name": "Strada Ferrata Maria Antonia",
      "logo": "1841/SFMA",
      "tokens": [
        0,
        0
      ],
      "coordinates": "N19",
      "color": "red"
    },
    {
      "sym": "SFLP",
      "name": "Strada Ferrata da Lucca a Pistoia",
      "logo": "1841/SFLP",
      "tokens": [
        0,
        0
      ],
      "coordinates": "L17",
      "color": "brightGreen"
    },
    {
      "sym": "SSFL",
      "name": "Società per la Strada Ferrata Leopolda",
      "logo": "1841/SSFL",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "coordinates": "K18",
      "color": "violet"
    },
    {
      "sym": "IRSFF",
      "name": "Imperial Regia Strada Ferrata Ferdinandea",
      "logo": "1841/IRSFF",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "coordinates": "H7",
      "color": "orange"
    },
    {
      "sym": "SFTG",
      "name": "Strada Ferrata da Torina a Genova",
      "logo": "1841/SFTG",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "coordinates": "F11",
      "color": "blue"
    },
    {
      "sym": "SFTN",
      "name": "Strada di Ferro da Torina a Novara",
      "logo": "1841/SFTN",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "coordinates": "D9",
      "color": "lightBrown"
    },
    {
      "sym": "SFTC",
      "name": "Strada di Ferro da Torino a Cuneo",
      "logo": "1841/SFTC",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "coordinates": "C14",
      "color": "yellow"
    },
    {
      "sym": "SFTC",
      "name": "Strada di Ferro da Torino a Cuneo",
      "logo": "1841/SFTC",
      "tokens": [
        0,
        0
      ],
      "coordinates": "C14",
      "color": "yellow"
    },
    {
      "sym": "SFLi",
      "name": "Strade Ferrate Livornesi",
      "logo": "1841/SFLi",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "brown"
    },
    {
      "sym": "SB",
      "name": "Strade Ferrate del Sud dell'Austria",
      "logo": "1841/SB",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "gold"
    },
    {
      "sym": "SFL",
      "name": "Strade Ferrate della Lombardia & dell'Italia Centrale",
      "logo": "1841/SFL",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "lightBlue"
    },
    {
      "sym": "SFV",
      "name": "Strade di Ferro Venete",
      "logo": "1841/SFV",
      "tokens": [
        0,
        0
      ],
      "color": "gold"
    },
    {
      "sym": "SFL",
      "name": "Strade Ferrate Lombarde",
      "logo": "1841/SFL",
      "tokens": [
        0,
        0
      ],
      "color": "lightBlue"
    },
    {
      "sym": "AFI",
      "name": "Azienda Ferroviaria Italica",
      "logo": "1841/AFI",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "red"
    },
    {
      "sym": "ATFA",
      "name": "Azienda Trasporti Ferroviari Ausonia",
      "logo": "1841/ATFA",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "orange"
    },
    {
      "sym": "CFCC",
      "name": "Compagnia Ferroviaria Conte di Cavour",
      "logo": "1841/CFCC",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "brightGreen"
    },
    {
      "sym": "CGTF",
      "name": "Compagnia Garibaldi per i Trasporti Ferroviari",
      "logo": "1841/CGTF",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "green"
    },
    {
      "sym": "CTDA",
      "name": "Compagnia Trasporti Dante Alighieri",
      "logo": "1841/CTDA",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "lime"
    },
    {
      "sym": "CTS",
      "name": "Compagnia Trasporti Subalpini",
      "logo": "1841/CTS",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "turquoise"
    },
    {
      "sym": "ICSF",
      "name": "Impresa Centrale Strade Ferrate",
      "logo": "1841/ICSF",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "navy"
    },
    {
      "sym": "IFAI",
      "name": "Impresa Ferroviaria Alta Italia",
      "logo": "1841/IFAI",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "violet"
    },
    {
      "sym": "ILTF",
      "name": "Impresa Latina Trasporti su Ferro",
      "logo": "1841/ILTF",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "pink"
    },
    {
      "sym": "RATF",
      "name": "Regia Azienda Trasporti Ferroviari",
      "logo": "1841/RATF",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "lavender"
    },
    {
      "sym": "RSFS",
      "name": "Reale Società Ferroviaria Sabauda",
      "logo": "1841/RSFS",
      "tokens": [
        0,
        0,
        0,
        0,
        0
      ],
      "color": "natural"
    },
    {
      "sym": "CTLP",
      "name": "Compagnia Trasporti La Patria",
      "logo": "1841/CTLP",
      "tokens": [
        0,
        0
      ],
      "color": "white"
    },
    {
      "sym": "FTP",
      "name": "Ferrovie Trans Padane",
      "logo": "1841/FTP",
      "tokens": [
        0,
        0
      ],
      "color": "gray"
    },
    {
      "sym": "SLDV",
      "name": "Società Leonardo Da Vinci",
      "logo": "1841/SLDV",
      "tokens": [
        0,
        0
      ],
      "color": "black"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 8
    },
    {
      "name": "3",
      "distance": 3,
      "price": 200,
      "rusts_on": "5",
      "num": 6
    },
    {
      "name": "4",
      "distance": 4,
      "price": 350,
      "rusts_on": "7",
      "num": 4
    },
    {
      "name": "5",
      "distance": 5,
      "price": 550,
      "rusts_on": "8",
      "num": 2
    },
    {
      "name": "6",
      "distance": 6,
      "price": 800,
      "num": 2
    },
    {
      "name": "7",
      "distance": 7,
      "price": 1100,
      "num": 2
    },
    {
      "name": "8",
      "distance": 8,
      "price": 1450,
      "num": 7
    }
  ],
  "hexes": {
    "white": {
      "": [
        "C8",
        "C10",
        "C12",
        "D5",
        "D7",
        "D11",
        "D13",
        "E6",
        "E8",
        "E12",
        "F3",
        "F5",
        "F9",
        "G8",
        "G10",
        "H3",
        "I2",
        "I4",
        "I8",
        "J3",
        "J7",
        "J11",
        "J13",
        "K4",
        "K8",
        "K10",
        "L7",
        "L11",
        "L19",
        "L21",
        "M6",
        "M10",
        "M20",
        "N9",
        "N11",
        "N15",
        "O6",
        "O14",
        "P9"
      ],
      "upgrade=cost:50,terrain:mountain": [
        "A10",
        "B9",
        "B13",
        "D15",
        "H11",
        "H15",
        "I12",
        "I16",
        "M14",
        "O16",
        "P3",
        "P17"
      ],
      "town=revenue:0;town=revenue:0": [
        "P15",
        "F7",
        "M18"
      ],
      "town=revenue:0": [
        "E10",
        "N21",
        "I10",
        "O10",
        "O20",
        "J17"
      ],
      "town=revenue:0;upgrade=cost:50,terrain:mountain": [
        "E16",
        "F15"
      ],
      "city=revenue:0;label=Y": [
        "I6",
        "K6",
        "M8",
        "O8",
        "N13"
      ],
      "city=revenue:0;label=V;upgrade=cost:50,terrain:swamp": [
        "P7"
      ],
      "city=revenue:0": [
        "F11",
        "K20",
        "G4",
        "G6",
        "H5",
        "H9",
        "J9",
        "L9",
        "N7",
        "P5",
        "K12",
        "L13",
        "M12",
        "O12"
      ],
      "upgrade=cost:50,terrain:swamp": [
        "P11"
      ],
      "town=revenue:0;upgrade=cost:50,terrain:swamp": [
        "P13"
      ]
    },
    "yellow": {
      "city=revenue:0;upgrade=cost:100": [
        "C16",
        "E14",
        "F13",
        "G12",
        "H13",
        "I14",
        "J15",
        "K14",
        "K16",
        "L5",
        "L15",
        "M16",
        "N5",
        "N17",
        "O4",
        "O18"
      ],
      "city=revenue:30;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Y;upgrade=cost:50,terrain:mountain": [
        "C14"
      ],
      "city=revenue:60;path=a:4,b:_0;path=a:0,b:_0;label=M": [
        "H7"
      ],
      "city=revenue:0;label=G;upgrade=cost:50,terrain:mountain": [
        "G14"
      ],
      "city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_0;label=Y": [
        "N19"
      ],
      "city=revenue:20;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "K18"
      ],
      "city=revenue:20;path=a:1,b:_0;path=a:5,b:_0": [
        "L17"
      ],
      "city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:5;path=a:4,b:_0;label=T": [
        "D9"
      ]
    },
    "green": {
      "city=revenue:0;upgrade=cost:200": [
        "A8",
        "E2"
      ]
    },
    "blue": {
      "path=a:3,b:_0": [
        "F17",
        "G16"
      ],
      "path=a:4,b:_0": [
        "I18",
        "J21"
      ],
      "path=a:2,b:_0": [
        "Q8",
        "Q14"
      ]
    },
    "gray": {
      "town=revenue:10;path=a:4,b:_0": [
        "C6"
      ],
      "path=a:1,b:4;path=a:0,b:1;path=a:4,b:5": [
        "J5"
      ],
      "town=revenue:20;town=revenue:10;path=a:1,b:_0;path=a:0,b:_1": [
        "K2"
      ]
    },
    "red": {
      "path=a:3,b:_0;border=edge:4": [
        "L23",
        "C18"
      ],
      "offboard=revenue:white_10|gray_40|white_200;border=edge:1": [
        "M22"
      ],
      "path=a:3,b:_0;border=edge:2": [
        "N23",
        "E18"
      ],
      "path=a:3,b:_0;border=edge:1": [
        "O22"
      ],
      "offboard=revenue:gray_140|white_200;path=a:0,b:_0": [
        "A6"
      ],
      "offboard=revenue:gray_90|white_150;path=a:5,b:_0": [
        "D1"
      ],
      "offboard=revenue:white_20|gray_30|white_150;path=a:0,b:_0": [
        "G2"
      ],
      "offboard=revenue:white_60|gray_100|white_150;border=edge:1": [
        "D17"
      ],
      "path=a:5,b:_0;border=edge:1": [
        "N3"
      ],
      "offboard=revenue:white_20|gray_70|white_140;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;border=edge:4": [
        "M4"
      ],
      "path=a:1,b:_0;border=edge:0": [
        "Q4"
      ],
      "offboard=revenue:white_50|gray_80|white_120;path=a:1,b:_0;path=a:2,b:_0;border=edge:3": [
        "Q6"
      ],
      "offboard=revenue:white_10|gray_70|white_150;path=a:1,b:_0;path=a:2,b:_0": [
        "Q16"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "train_limit": 2,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
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
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "5",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "6",
      "train_limit": 1,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "6",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "7",
      "train_limit": 1,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "7",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "8",
      "train_limit": 1,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "8",
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
