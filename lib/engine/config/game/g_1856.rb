# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1856
        JSON = <<-'DATA'
{
  "filename": "1856",
  "modulename": "1856",
  "currencyFormatStr": "$%d",
  "bankCash": 12000,
  "certLimit": {
    "3": 20,
    "4": 16,
    "5": 13,
    "6": 11
  },
  "startingCash": {
    "3": 500,
    "4": 375,
    "5": 300,
    "6": 250
  },
  "capitalization": "full",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "A20": "Detroit - Windsor",
    "A14": "Port Huron",
    "B13": "Sarnia",
    "F9": "Goderich",
    "H5": "Lake Huron",
    "K2": "Georgian Bay",
    "O2": "Canadian West",
    "Q8": "Lower Canada",
    "P17": "Buffalo",
    "F15": "London",
    "M4": "Barrie",
    "N11": "Toronto",
    "I12": "Kitchener",
    "L15": "Hamilton",
    "N17": "Welland",
    "H15": "Woodstock",
    "J13": "Galt",
    "B19": "Chatham",
    "L13": "Burlington",
    "P9": "Oshawa",
    "F17": "St. Thomas",
    "O18": "Fort Erie",
    "C14": "Maudaumin",
    "D17": "Glencoe",
    "J11": "Guelph",
    "J15": "Brantford",
    "K8": "Orangeville",
    "O16": "Niagara Falls"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 3,
    "4": 3,
    "5": 2,
    "6": 2,
    "7": 7,
    "8": 13,
    "9": 13,
    "14": 4,
    "15": 4,
    "16": 1,
    "17": 1,
    "18": 1,
    "19": 1,
    "20": 1,
    "23": 4,
    "24": 4,
    "25": 1,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "39": 1,
    "40": 1,
    "41": 3,
    "42": 3,
    "43": 2,
    "44": 1,
    "45": 2,
    "46": 2,
    "47": 2,
    "55": 1,
    "56": 1,
    "57": 4,
    "58": 3,
    "59": 2,
    "63": 4,
    "64": 1,
    "65": 1,
    "66": 1,
    "67": 1,
    "68": 1,
    "69": 1,
    "70": 1,
    "120": 1,
    "121": 2,
    "122": 1,
    "123": 1,
    "124": 1,
    "125": {
      "count": 4,
      "color": "brown",
      "code": "city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L"
    },
    "126": 1,
    "127": 1
  },
  "market":[
     [
        "70",
        "75",
        "80",
        "90",
        "100p",
        "110",
        "125",
        "150",
        "175",
        "200",
        "225",
        "250",
        "275",
        "300",
        "325",
        "350",
        "375",
        "400",
        "425",
        "450"
     ],
     [
        "65",
        "70",
        "75",
        "80",
        "90p",
        "100",
        "110",
        "125",
        "150",
        "175",
        "200",
        "225",
        "250",
        "275",
        "300",
        "325",
        "350",
        "375",
        "400",
        "425"
     ],
     [
        "60",
        "65",
        "70",
        "75",
        "80p",
        "90",
        "100",
        "110",
        "125",
        "150",
        "175",
        "200",
        "225",
        "250",
        "275"
     ],
     [
        "55",
        "60",
        "65",
        "70",
        "75p",
        "80",
        "90",
        "100",
        "110",
        "125",
        "150",
        "175",
        "200"
     ],
     [
        "50y",
        "55",
        "60",
        "65",
        "70p",
        "75",
        "80",
        "90",
        "100",
        "110",
        "125"
     ],
     [
        "45y",
        "50y",
        "55",
        "60",
        "65p",
        "70",
        "75",
        "80",
        "90"
     ],
     [
        "40o",
        "45y",
        "50y",
        "55",
        "60",
        "65",
        "70"
     ],
     [
        "35o",
        "40o",
        "45y",
        "50y",
        "55",
        "60"
     ],
     [
        "30o",
        "35o",
        "40o",
        "45y",
        "50y"
     ],
     [
        "0c",
        "30o",
        "35o",
        "40o",
        "45y"
     ],
     [
        "0c",
        "0c",
        "30o",
        "35o",
        "40o"
     ]
  ],
  "companies": [
    {
      "name": "Flos Tramway",
      "sym": "FT",
      "value": 20,
      "revenue": 5,
      "desc": "No special abilities."
    },
    {
      "name": "Waterloo & Saugeen Railway Co.",
      "sym": "WSRC",
      "value": 40,
      "revenue": 10,
      "desc": "The public company that owns this private company may place a free station marker and green #59 tile on the Kitchener hex (I12). This action closes the private company."
    },
    {
      "name": "The Canada Company",
      "sym": "TCC",
      "value": 50,
      "revenue": 10,
      "desc": "During its operating turn, the public company owning this private company may place a track tile in the hex occupied by this private company (H11). This track lay is in addition to the public company's normal track lay. This action does not close the private company."
    },
    {
      "name": "Great Lakes Shipping Company",
      "sym": "GLSC",
      "value": 70,
      "revenue": 15,
      "desc": "At any time during its operating turn, the owning public company may place the port token in any one city adjacent to Lake Erie, Lake Huron or Georgian Bay. Placement of this token closes the Great Lakes Shipping Company."
    },
    {
      "name": "Niagara Falls Suspension Bridge Company",
      "sym": "NFSBC",
      "value": 100,
      "revenue": 20,
      "desc": "The public company that owns this private company may add a $10 bonus when running to Buffalo (P17/P19). Other public companies may purchase the right for $50."
    },
    {
      "name": "St. Clair Frontier Tunnel Company",
      "sym": "SCFTC",
      "value": 100,
      "revenue": 20,
      "desc": "The public company that owns this private company may add a $10 Port Huron bonus when running to Sarnia (B13). Other public companies may purchase the right for $50."
    }
  ],
  "corporations": [
    {
      "sym": "BBG",
      "logo": "1856/BBG",
      "name": "Buffalo, Brantford & Goderich Railway",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "J15",
      "color": "bbgPink",
      "text_color": "black"
    },
    {
      "sym": "CA",
      "logo": "1856/CA",
      "name": "Canada Air Line Railway",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "D17",
      "color": "caRed"
    },
    {
      "sym": "CPR",
      "logo": "1856/CPR",
      "name": "Canadian Pacific Railroad",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "M4",
      "color": "cprPink"
    },
    {
      "sym": "CV",
      "logo": "1856/CV",
      "name": "Credit Valley Railway",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "N11",
      "city": 0,
      "color": "cvPurple"
    },
    {
      "sym": "GT",
      "logo": "1856/GT",
      "name": "Grand Trunk Railway",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "P9",
      "color": "gtGreen"
    },
    {
      "sym": "GW",
      "logo": "1856/GW",
      "name": "Great Western Railway",
      "tokens": [
        0,
        40,
        100,
        100
      ],
      "coordinates": "F15",
      "color": "gwGray"
    },
    {
      "sym": "LPS",
      "logo": "1856/LPS",
      "name": "London & Port Sarnia Railway",
      "tokens": [
        0,
        40
      ],
      "coordinates": "C14",
      "color": "lpsBlue",
      "text_color": "black"
    },
    {
      "sym": "TGB",
      "logo": "1856/TGB",
      "name": "Toronto, Grey & Bruce Railway",
      "tokens": [
        0,
        40
      ],
      "coordinates": "K8",
      "color": "tgbOrange"
    },
    {
      "sym": "THB",
      "logo": "1856/THB",
      "name": "Toronto, Hamilton and Buffalo Railway",
      "tokens": [
        0,
        40
      ],
      "coordinates": "L15",
      "color": "thbYellow",
      "text_color": "black"
    },
    {
      "sym": "WR",
      "logo": "1856/WR",
      "name": "Welland Railway",
      "tokens": [
        0,
        40,
        100
      ],
      "coordinates": "O16",
      "color": "wrBrown"
    },
    {
      "sym": "WGB",
      "logo": "1856/WGB",
      "name": "Wellington, Grey & Bruce Railway",
      "tokens": [
        0,
        40
      ],
      "coordinates": "J11",
      "color": "wgbBlue"
    },
    {
      "sym": "CGR",
      "logo": "1856/CGR",
      "name": "Canadian Government Railway",
      "tokens": [
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100,
        100
      ],
      "color": "cgrBlack"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 5
    },
    {
      "name": "2'",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 1
    },
    {
      "name": "3",
      "distance": 3,
      "price": 225,
      "rusts_on": "6",
      "num": 4
    },
    {
      "name": "3'",
      "distance": 3,
      "price": 225,
      "rusts_on": "6",
      "num": 1
    },
    {
      "name": "4",
      "distance": 4,
      "price": 350,
      "rusts_on": "D",
      "num": 3
    },
    {
      "name": "4'",
      "distance": 4,
      "price": 350,
      "rusts_on": "D",
      "num": 1
    },
    {
      "name": "5",
      "distance": 5,
      "price": 550,
      "num": 2,
      "events":[
      {
         "type":"close_companies"
      }
      ]
    },
    {
      "name": "5'",
      "distance": 5,
      "price": 550,
      "num": 1
    },
    {
      "name": "6",
      "distance": 6,
      "price": 700,
      "num": 2,
      "events":[
      {
         "type":"Nationalization"
      }
      ]
    },
    {
      "name": "D",
      "distance": 999,
      "price": 1100,
      "num": 6,
      "available_on": "6",
      "discount": {
        "4": 350,
        "4'": 350,
        "5": 350,
        "5'": 350,
        "6": 350
      }
    }
  ],
  "hexes": {
    "red": {
      "offboard=revenue:yellow_30|brown_50|gray_60;path=a:4,b:_0;path=a:5,b:_0": [
        "A20"
      ],
      "border=edge:4": [
        "A14"
      ],
      "offboard=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:5,b:_0;border=edge:1": [
        "B13"
      ],
      "offboard=revenue:yellow_30|brown_50|gray_40;path=a:0,b:_0;path=a:_0,b:4;path=a:4,b:_0;path=a:_0,b:5;path=a:0,b:_0;path=a:_0,b:5": [
        "F9"
      ],
      "offboard=revenue:yellow_30|brown_50|gray_40;path=a:0,b:_0;path=a:5,b:_0": [
        "H5"
      ],
      "offboard=revenue:yellow_20|brown_30;path=a:0,b:_0;path=a:5,b:_0": [
        "K2"
      ],
      "offboard=revenue:yellow_20|brown_30|gray_50;path=a:0,b:_0;path=a:1,b:_0;border=edge:5": [
        "N1"
      ],
      "offboard=revenue:yellow_20|brown_30|gray_50;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;border=edge:2": [
        "O2"
      ],
      "offboard=revenue:yellow_20|brown_30|gray_50;path=a:1,b:_0;path=a:2,b:_0;border=edge:0": [
        "Q8"
      ],
      "offboard=revenue:yellow_20|brown_30|gray_50;path=a:2,b:_0;border=edge:3": [
        "Q10"
      ],
      "offboard=revenue:yellow_30|brown_40;path=a:2,b:_0;border=edge:3": [
        "P19"
      ],
      "offboard=revenue:yellow_30|brown_40;path=a:1,b:_0;path=a:2,b:_0;border=edge:0": [
        "P17"
      ]
    },
    "yellow": {
      "city=revenue:30;path=a:0,b:_0;path=a:4,b:_0": [
        "F15",
        "M4"
      ],
      "city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1": [
        "N11"
      ],
      "city=revenue:0;city=revenue:0;label=OO": [
        "I12",
        "N17"
      ],
      "city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:mountain": [
        "L15"
      ]
    },
    "blue": {
      "": [
        "N5"
      ]
    },
    "white": {
      "city=revenue:0": [
        "H15",
        "G12",
        "I8",
        "J13",
        "D17",
        "J11",
        "J15",
        "K8",
        "O16"
      ],
      "city=revenue:0;label=L": [
        "B19",
        "L13",
        "P9",
        "F17",
        "O18",
        "C14"
      ],
      "city=revenue:0;label=L;upgrade=cost:40,terrain:water": [
        "N3"
      ],
      "town=revenue:0": [
        "J9",
        "K16",
        "L9",
        "M6",
        "N9",
        "D19",
        "H17",
        "J5",
        "M18",
        "H11"
      ],
      "town=revenue:0;town=revenue:0": [
        "I14",
        "F13",
        "M10",
        "E18",
        "H7",
        "J17"
      ],
      "upgrade=cost:40,terrain:mountain": [
        "K10",
        "K12",
        "K14",
        "M16",
        "N15"
      ],
      "upgrade=cost:40,terrain:water": [
        "N19",
        "P7"
      ],
      "blank": [
        "L3",
        "B15",
        "B17",
        "B21",
        "C16",
        "C18",
        "C20",
        "D13",
        "D15",
        "E12",
        "E14",
        "E16",
        "F11",
        "G8",
        "G10",
        "G14",
        "G16",
        "G18",
        "H9",
        "H13",
        "I6",
        "I10",
        "I16",
        "I18",
        "J7",
        "K4",
        "K6",
        "K18",
        "L5",
        "L7",
        "L11",
        "L17",
        "M2",
        "M8",
        "M12",
        "N7",
        "O4",
        "O6",
        "O8",
        "O10",
        "P3",
        "P5"
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
        "status":[
        "escrow",
        "facing_2"
        ],
        "operating_rounds":1
     },
     {
        "name":"2'",
        "on":"2'",
        "train_limit":4,
        "tiles":[
        "yellow"
        ],
        "status":[
        "escrow",
        "facing_3"
        ],
        "operating_rounds":1
     },
     {
        "name":"3",
        "on":"3",
        "train_limit":4,
        "tiles":[
        "yellow",
        "green"
        ],
        "operating_rounds":2,
        "status":[
        "escrow",
        "facing_3",
        "can_buy_companies"
        ]
     },
     {
        "name":"3'",
        "on":"3'",
        "train_limit":4,
        "tiles":[
        "yellow",
        "green"
        ],
        "operating_rounds":2,
        "status":[
        "escrow",
        "facing_4",
        "can_buy_companies"
        ]
     },
     {
        "name":"4",
        "on":"4",
        "train_limit":3,
        "tiles":[
        "yellow",
        "green"
        ],
        "operating_rounds":2,
        "status":[
        "escrow",
        "facing_4",
        "can_buy_companies"
        ]
     },
     {
        "name":"4'",
        "on":"4'",
        "train_limit":3,
        "tiles":[
        "yellow",
        "green"
        ],
        "operating_rounds":2,
        "status":[
        "incremental",
        "facing_5",
        "can_buy_companies"
        ]
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
        "status":[
        "incremental",
        "facing_5"
        ],
        "operating_rounds":3
     },
     {
        "name":"5'",
        "on":"5'",
        "train_limit":2,
        "tiles":[
        "yellow",
        "green",
        "brown"
        ],
        "status":[
        "fullcap",
        "facing_6"
        ],
        "operating_rounds":3
     },
     {
        "name":"6",
        "on":"6",
        "train_limit":2,
        "tiles":[
        "yellow",
        "green",
        "brown",
        "gray"
        ],
        "status":[
        "fullcap",
        "facing_6"
        ],
        "operating_rounds":3
     },
     {
        "name":"D",
        "on":"D",
        "train_limit":2,
        "tiles":[
        "yellow",
        "green",
        "brown",
        "gray"
        ],
        "status":[
        "fullcap",
        "facing_6"
        ],
        "operating_rounds":3
     }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
