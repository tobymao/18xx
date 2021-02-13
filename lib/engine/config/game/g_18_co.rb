# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18CO
        JSON = <<-'DATA'
{
	"filename": "18_co",
	"modulename": "18CO",
	"currencyFormatStr": "$%d",
	"bankCash": 10000,
	"certLimit": {
		"3": 17,
		"4": 14,
		"5": 12,
		"6": 10
	},
	"startingCash": {
		"3": 500,
		"4": 375,
		"5": 300,
		"6": 250
	},
	"capitalization": "incremental",
	"layout": "pointy",
	"axes": {
		"rows": "numbers",
		"columns": "letters"
	},
	"mustSellInBlocks": false,
	"locationNames": {
		"A11": "Laramie, WY",
		"A17": "Cheyenne, WY",
		"B10": "Walden",
		"B22": "Sterling",
		"B26": "Lincoln, NE (SLC +100)",
		"C7": "Craig",
		"C9": "Steamboat Springs",
		"C15": "Fort Collins",
		"C17": "Greeley",
		"C21": "Fort Morgan",
		"D4": "Meeker",
		"D14": "Boulder",
		"D24": "Wray",
		"E1": "Salt Lake City, UT",
		"E5": "Rifle",
		"E7": "Glenwood Springs",
		"E11": "Dillon",
		"E15": "Denver",
		"E27": "Kansas City, KS (SLC +100)",
		"F8": "Aspen",
		"F12": "South Park",
		"F20": "Limon",
		"F24": "Burlington",
		"G3": "Grand Junction",
		"G17": "Colorado Springs",
		"G27": "Kansas City, KS (SLC +100)",
		"H6": "Montrose",
		"H8": "Gunnison",
		"H12": "Salida",
		"H14": "Canon City",
		"I17": "Pueblo",
		"I21": "La Junta",
		"I23": "Lamar",
		"J6": "Silverton",
		"J26": "Wichita, KS (SLC +100)",
		"K5": "Durango",
		"K13": "Alamosa",
		"K17": "Trinidad",
		"L2": "Farmington, NM",
		"L14": "Santa Fe, NM",
		"L20": "Fort Worth, TX"
	},
	"tiles": {
		"3a": {
			"count": 6,
			"color": "yellow",
			"code": "town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:1"
		},
		"4a": {
			"count": 6,
			"color": "yellow",
			"code": "town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:3"
		},
		"5": 3,
		"6": 6,
		"7": 15,
		"8": 25,
		"9": 25,
		"57": 6,
		"58a": {
			"count": 6,
			"color": "yellow",
			"code": "town=revenue:10,to_city:1;path=a:0,b:_0;path=a:_0,b:2"
		},
		"co1": {
			"count": 1,
			"color": "yellow",
			"code": "city=revenue:30,slots:2;city=revenue:30;city=revenue:30;path=a:5,b:_0;path=a:_0,b:0;path=a:1,b:_1;path=a:_1,b:2;path=a:3,b:_2;path=a:_2,b:4;label=D;"
		},
		"co5": {
			"count": 1,
			"color": "yellow",
			"code": "city=revenue:20;city=revenue:20,hide:1;path=a:0,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:4;label=C;"
		},
		"14": 4,
		"15": 4,
		"16": 2,
		"17": 2,
		"18": 2,
		"19": 2,
		"20": 2,
		"21": 1,
		"22": 1,
		"23": 3,
		"24": 3,
		"25": 2,
		"26": 2,
		"27": 2,
		"28": 2,
		"29": 2,
		"co8": {
			"count": 5,
			"color": "green",
			"code": "town=revenue:20,to_city:1;junction;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0"
		},
		"co9": {
			"count": 5,
			"color": "green",
			"code": "town=revenue:20,to_city:1;junction;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0"
		},
		"co10": {
			"count": 2,
			"color": "green",
			"code": "town=revenue:20,to_city:1;junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0"
		},
		"co2": {
			"count": 1,
			"color": "green",
			"code": "city=revenue:50,slots:3,loc:16.5;city=revenue:50;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=D;"
		},
		"co6": {
			"count": 1,
			"color": "green",
			"code": "city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C;"
		},
		"39": 1,
		"40": 2,
		"41": 1,
		"42": 1,
		"43": 1,
		"44": 1,
		"45": 1,
		"46": 1,
		"47": 1,
		"63": 6,
		"co3": {
			"count": 1,
			"color": "brown",
			"code": "city=revenue:70,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=D;"
		},
		"co4": {
			"count": 3,
			"color": "brown",
			"code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;"
		},
		"co7": {
			"count": 1,
			"color": "brown",
			"code": "city=revenue:60,slots:3;path=a:0,b:_0,;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C;"
		}
	},
	"market": [
		[
			"140",
			"145",
			"150",
			"155",
			"165",
			"175",
			"190",
			"205",
			"225",
			"250",
			"280",
			"315",
			"355",
			"395",
			"440",
			"485"
		],
		[
			"110",
			"115",
			"120",
			"125",
			"135",
			"145z",
			"160z",
			"175",
			"195",
			"220",
			"250",
			"280",
			"315",
			"350",
			"385",
			"425"
		],
		[
			"85",
			"90",
			"95",
			"100x",
			"110x",
			"120z",
			"135z",
			"150",
			"170",
			"195",
			"220",
			"245",
			"275",
			"305",
			"335",
			"370"
		],
		[
			"65",
			"70",
			"75p",
			"80x",
			"90x",
			"100",
			"115",
			"130",
			"150",
			"170",
			"195",
			"215",
			"240",
			"265",
			"290",
			"320"
		],
		[
			"50",
			"55",
			"60p",
			"65",
			"75",
			"85",
			"100",
			"115",
			"130",
			"150",
			"170",
			"185",
			"205"
		],
		[
			"40",
			"45",
			"50p",
			"55",
			"65",
			"75",
			"85",
			"100",
			"115",
			"130"
		],
		[
			"30",
			"35",
			"40p",
			"45",
			"55",
			"65",
			"75",
			"85"
		],
		[
			"25",
			"30",
			"35",
			"40",
			"45",
			"55",
			"65"
		],
		[
			"20",
			"25",
			"30",
			"35",
			"40",
			"45"
		],
		[
			"15",
			"20",
			"25",
			"30",
			"35",
			"40"
		],
		[
			"10a",
			"15",
			"20",
			"25",
			"30"
		],
		[
			"10a",
			"10a",
			"15",
			"20",
			"20"
		],
		[
			"10a",
			"10a",
			"10a",
			"15a",
			"15a"
		]
	],
	"companies": [
		{
			"sym": "IMC",
			"name": "Idarado Mining Company",
			"value": 30,
			"revenue": 5,
			"desc": "Money gained from mine tokens is doubled for the owning Corporation. If owned by a Corporation, closes on purchase of “6” train, otherwise closes on purchase of “5” train.",
			"abilities": [
				{
					"type": "close",
					"owner_type": "corporation",
					"on_phase": "6"
				}
			]
		},
		{
			"sym": "GJGR",
			"name": "Grand Junction and Grand River Valley Railway",
			"value": 40,
			"revenue": 10,
			"desc": "An owning Corporation may upgrade a yellow town to a green city in additional to its normal tile lay at any time during its turn. This tile does not need to be reachable by the corporation's trains. Action closes the company or closes on purchase of “5” train.",
			"abilities": [
				{
					"type": "tile_lay",
					"free": true,
					"owner_type": "corporation",
					"when": ["track", "special_track"],
					"count": 1,
					"special": true,
					"tiles": [
						"14",
						"15"
					],
					"hexes": [
						"B10",
						"B22",
						"C7",
						"C9",
						"C17",
						"C21",
						"D4",
						"D14",
						"D24",
						"E5",
						"E7",
						"E11",
						"F8",
						"F12",
						"F20",
						"F24",
						"H8",
						"H12",
						"H14",
						"I21",
						"I23",
						"J6",
						"K13"
					]
				}
			]
		},
		{
			"sym": "DNP",
			"name": "Denver, Northwestern and Pacific Railroad",
			"value": 50,
			"revenue": 10,
			"desc": "An owning Corporation may return a station token to its charter to gain the token cost. The token is placed on the rightmost (most expensive) empty token slot with money gained corresponding to empty token slot's price. The corporation must always have at least one token on the board. Action closes the company or closes on purchase of “5” train.",
			"abilities": [
				{
					"type": "return_token",
					"owner_type": "corporation",
					"count": 1,
					"reimburse": true
				}
			]
		},
		{
			"sym": "Toll",
			"name": "Saguache & San Juan Toll Road Company",
			"value": 60,
			"revenue": 10,
			"desc": "An owning Corporation receives a $20 discount on the cost of tile lays. Closes on purchase of “5” train.",
			"abilities": [
				{
					"type": "tile_discount",
					"discount": 20
				}
			]
		},
		{
			"sym": "LNPW",
			"name": "Laramie, North Park and Western Railroad",
			"value": 70,
			"revenue": 15,
			"desc": "When laying track tiles, an owning Corporation may lay an extra yellow tile at no cost in addition to its normal tile lay. Action closes the company or closes on purchase of “5” train.",
			"abilities": [
				{
					"type": "tile_lay",
					"free": true,
					"special": false,
					"reachable": true,
					"owner_type": "corporation",
					"when": "track",
					"count": 1,
					"hexes": [

					],
					"tiles": [
						"co1",
						"co5",
						"3a",
						"4a",
						"5",
						"6",
						"7",
						"8",
						"9",
						"57",
						"58a"
					]
				}
			]
		},
		{
			"sym": "DPRT",
			"name": "Denver Pacific Railway and Telegraph Company",
			"value": 100,
			"revenue": 15,
			"desc": "The owner immediately receives one share of either Denver Pacific Railroad, Colorado and Southern Railroad, Kansas Pacific Railway or Colorado Midland Railway. The railroad receives money equal to the par value when the President’s Certificate is purchased. Closes on purchase of “5” train.",
			"abilities": [
				{
					"type": "shares",
					"shares": "random_share",
					"corporations": [
						"CS",
						"DPAC",
						"KPAC",
						"CM"
					]
				}
			]
		},
		{
			"sym": "DRGR",
			"name": "Denver & Rio Grande Railway Silverton Branch",
			"value": 120,
			"revenue": 25,
			"desc": "The owner receives the Presidency of Durango and Silverton Narrow Gauge, which floats immediately. Closes when the DSNG runs a train or on purchase of “5” train. Cannot be purchased by a Corporation. Does not count towards net worth.",
			"abilities": [
				{
					"type": "shares",
					"shares": "DSNG_0"
				},
				{
					"type": "close",
					"when": "run_train",
					"corporation": "DSNG"
				},
				{
					"type": "no_buy"
				}
			]
		}
	],
	"corporations": [
		{
			"sym": "KPAC",
			"name": "Kansas Pacific Railway",
			"group": "III",
			"float_percent": 40,
			"always_market_price": true,
			"logo": "18_co/KPAC",
			"simple_logo": "18_co/KPAC.alt",
			"tokens": [
				0,
				40,
				100
			],
			"coordinates": "E27",
			"color": "brown",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - C"
				}
			]
		},
		{
			"sym": "CM",
			"name": "Colorado Midland Railway",
			"group": "III",
			"float_percent": 40,
			"always_market_price": true,
			"logo": "18_co/CM",
			"simple_logo": "18_co/CM.alt",
			"tokens": [
				0,
				40,
				100,
				100
			],
			"coordinates": "G17",
			"color": "lightBlue",
      "text_color": "black",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - C"
				}
			]
		},
		{
			"sym": "CS",
			"name": "Colorado & Southern Railway",
			"group": "III",
			"float_percent": 40,
			"always_market_price": true,
			"logo": "18_co/CS",
			"simple_logo": "18_co/CS.alt",
			"tokens": [
				0,
				40,
				100,
				100
			],
			"coordinates": "K17",
			"color": "#232b2b",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - C"
				}
			]
		},
		{
			"sym": "DPAC",
			"name": "Denver Pacific Railway",
			"group": "III",
			"float_percent": 40,
			"always_market_price": true,
			"logo": "18_co/DPAC",
			"simple_logo": "18_co/DPAC.alt",
			"tokens": [
				0,
				40
			],
			"city": 2,
			"coordinates": "E15",
			"color": "#82009c",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - C"
				}
			]
		},
		{
			"sym": "DSL",
			"name": "Denver & Salt Lake Railroad",
			"group": "III",
			"float_percent": 40,
			"always_market_price": true,
			"logo": "18_co/DSL",
			"simple_logo": "18_co/DSL.alt",
			"tokens": [
				0,
				40
			],
			"city": 1,
			"coordinates": "E15",
			"color": "green",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - C"
				}
			]
		},
		{
			"sym": "DRG",
			"name": "Denver & Rio Grande Railroad",
			"group": "II",
			"float_percent": 50,
			"always_market_price": true,
			"logo": "18_co/DRG",
			"simple_logo": "18_co/DRG.alt",
			"tokens": [
				0,
				40,
				80,
				100,
				100,
				100
			],
			"city": 0,
			"coordinates": "E15",
			"color": "gold",
			"text_color": "black",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - B"
				}
			]
		},
		{
			"sym": "ATSF",
			"name": "Atchison, Topeka & Santa Fe",
			"group": "II",
			"float_percent": 50,
			"always_market_price": true,
			"logo": "18_co/ATSF",
			"simple_logo": "18_co/ATSF.alt",
			"tokens": [
				0,
				40,
				80,
				100,
				100,
				100
			],
			"coordinates": "J26",
			"color": "#0323ad",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - B"
				}
			]
		},
		{
			"sym": "CBQ",
			"name": "Chicago, Burlington & Quincy",
			"group": "I",
			"float_percent": 60,
			"always_market_price": true,
			"logo": "18_co/CBQ",
			"simple_logo": "18_co/CBQ.alt",
			"tokens": [
				0,
				40,
				80,
				100,
				100,
				100,
				100
			],
			"coordinates": "B26",
			"color": "orange",
			"text_color": "black",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - A"
				}
			]
		},
		{
			"sym": "ROCK",
			"name": "Chicago, Rock Island & Pacific",
			"group": "I",
			"float_percent": 60,
			"always_market_price": true,
			"logo": "18_co/ROCK",
			"simple_logo": "18_co/ROCK.alt",
			"tokens": [
				0,
				40,
				80,
				100,
				100,
				100,
				100,
				100
			],
			"coordinates": "G27",
			"color": "red",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - A"
				}
			]
		},
		{
			"sym": "UP",
			"name": "Union Pacific",
			"group": "I",
			"float_percent": 60,
			"always_market_price": true,
			"logo": "18_co/UP",
			"simple_logo": "18_co/UP.alt",
			"tokens": [
				0,
				40,
				80,
				100,
				100,
				100,
				100,
				100
			],
			"coordinates": "A17",
			"color": "#ffffeb",
      "text_color":"black",
			"abilities": [
				{
					"type": "description",
					"description": "Par Group - A"
				}
			]
		},
		{
			"sym": "DSNG",
			"name": "Durango & Silverton Narrow Gauge",
			"group": "X",
			"float_percent": 20,
			"always_market_price": true,
			"logo": "18_co/DSNG",
			"simple_logo": "18_co/DSNG.alt",
			"shares":[20, 10, 20, 20, 10, 10, 10],
			"tokens": [
				0,
				40
			],
			"coordinates": "K5",
			"color": "#db00c0",
			"abilities": [
				{
					"type": "description",
					"description": "Pars @ $75(C) via DRG Silverton Branch"
				},
        {
					"type": "base",
					"description": "Shares: 2P/2/2/1/1/1/1"
				}
			]
		}
	],
	"trains": [
		{
			"name": "2P",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 2,
					"visit": 2
				},
				{
					"nodes": [
						"town"
					],
					"pay": 99,
					"visit": 99
				}
			],
			"price": 0,
			"num": 1
		},
		{
			"name": "2",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 2,
					"visit": 2
				},
				{
					"nodes": [
						"town"
					],
					"pay": 99,
					"visit": 99
				}
			],
			"price": 100,
			"rusts_on": "4",
			"num": 6
		},
		{
			"name": "3",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 3,
					"visit": 3
				},
				{
					"nodes": [
						"town"
					],
					"pay": 99,
					"visit": 99
				}
			],
			"price": 180,
			"rusts_on": "4D",
			"num": 5
		},
		{
			"name": "4",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 4,
					"visit": 4
				},
				{
					"nodes": [
						"town"
					],
					"pay": 99,
					"visit": 99
				}
			],
			"price": 280,
			"rusts_on": "6",
			"num": 4
		},
		{
			"name": "5",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 5,
					"visit": 5
				},
				{
					"nodes": [
						"town"
					],
					"pay": 99,
					"visit": 99
				}
			],
			"events": [
				{
					"type": "close_companies"
				},
				{
					"type": "unreserve_home_stations"
				}
			],
			"price": 500,
			"rusts_on": "E",
			"num": 2
		},
		{
			"name": "4D",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 4,
					"visit": 4,
					"multiplier": 2
				},
				{
					"nodes": [
						"town"
					],
					"pay": 0,
					"visit": 99
				}
			],
			"available_on": "5",
			"price": 650,
			"num": 3
		},
		{
			"name": "6",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 6,
					"visit": 6
				},
				{
					"nodes": [
						"town"
					],
					"pay": 99,
					"visit": 99
				}
			],
			"events": [
				{
					"type": "remove_mines"
				}
			],
			"price": 720,
			"num": 10
		},
		{
			"name": "5D",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 5,
					"visit": 5,
					"multiplier": 2
				},
				{
					"nodes": [
						"town"
					],
					"pay": 0,
					"visit": 99
				}
			],
			"events": [
				{
					"type": "presidents_choice"
				}
			],
			"available_on": "6",
			"price": 850,
			"num": 2
		},
		{
			"name": "E",
			"distance": [
				{
					"nodes": [
						"city",
						"offboard"
					],
					"pay": 99,
					"visit": 99
				},
				{
					"nodes": [
						"town"
					],
					"pay": 99,
					"visit": 99
				}
			],
			"events": [
				{
					"type": "presidents_choice"
				}
			],
			"available_on": "6",
			"price": 1000,
			"num": 1
		}
	],
	"hexes": {
		"white": {
			"": [
				"B2",
				"B4",
				"B6",
				"B16",
				"B18",
				"B20",
				"B24",
				"C3",
				"C5",
				"C19",
				"C23",
				"C25",
				"D2",
				"D16",
				"D18",
				"D20",
				"D22",
				"E3",
				"E17",
				"E19",
				"E21",
				"E23",
				"E25",
				"F2",
				"F18",
				"F22",
				"G13",
				"G19",
				"G21",
				"G23",
				"G25",
				"H18",
				"H20",
				"H22",
				"H24",
				"I5",
				"I19",
				"I25",
				"J2",
				"J16",
				"J18",
				"J20",
				"J22",
				"J24",
				"K3",
				"K19",
				"K21",
				"K23",
				"K25"
			],
			"city=revenue:0": [
				"C15",
				"K17"
			],
			"city=revenue:10;path=a:5,b:_0;path=a:_0,b:0;label=C;border=edge:1,type:mountain,cost:40;": [
				"G17"
			],
			"city=revenue:10;city=revenue:0,loc:7;city=revenue:10;path=a:5,b:_0;path=a:3,b:_2;label=D;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;": [
				"E15"
			],
			"town=revenue:0": [
				"B22",
				"C7",
				"D4",
				"D24",
				"F20",
				"F24",
				"I21",
				"I23"
			],
			"town=revenue:0;icon=image:18_co/upgrade,sticky:1,name:upgrade": [
				"C17",
				"C21"
			],
			"border=edge:1,type:mountain,cost:40;": [
				"B14",
				"K11"
			],
			"border=edge:3,type:mountain,cost:40;": [
				"I3"
			],
			"border=edge:4,type:mountain,cost:40;": [
				"J12"
			],
			"border=edge:5,type:mountain,cost:40;": [
				"F4"
			],
			"border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;": [
				"F16"
			],
			"border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;": [
				"H16"
			],
			"border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;": [
				"I11"
			],
			"border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;": [
				"G5"
			],
			"border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;": [
				"H2"
			],
			"border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;": [
				"D10"
			],
			"town=revenue:0;border=edge:3,type:mountain,cost:40;": [
				"E5"
			],
			"town=revenue:0;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;": [
				"B10"
			],
			"town=revenue:0;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;": [
				"F12"
			],
			"town=revenue:0;icon=image:18_co/upgrade,sticky:1,name:upgrade;border=edge:4,type:mountain,cost:40;": [
				"K13"
			],
			"town=revenue:0;icon=image:18_co/upgrade,sticky:1,name:upgrade;border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"H8"
			],
			"town=revenue:0;icon=image:18_co/mine,sticky:1,name:mine;icon=image:18_co/upgrade,sticky:1,name:upgrade;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;": [
				"D14"
			],
			"town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"F8"
			],
			"town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:1,type:mountain,cost:40;": [
				"H12"
			],
			"town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"E11"
			],
			"town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"J6"
			],
			"town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/upgrade,sticky:1,name:upgrade;border=edge:0,type:mountain,cost:40;": [
				"H14"
			],
			"town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/upgrade,sticky:1,name:upgrade;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;": [
				"E7"
			],
			"town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:18_co/upgrade,sticky:1,name:upgrade;border=edge:3,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"C9"
			],
			"city=revenue:0;border=edge:0,type:mountain,cost:40;": [
				"G3"
			],
			"city=revenue:0;border=edge:1,type:mountain,cost:40;": [
				"I17"
			],
			"city=revenue:0;border=edge:3,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"H6"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:4,type:mountain,cost:40;": [
				"B8",
				"B12"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:5,type:mountain,cost:40;": [
				"C11",
				"J4"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;": [
				"H4"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"D6"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;": [
				"K7"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;": [
				"F14"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"D8"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"J14"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;": [
				"K9"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:2,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"D12"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"I13"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"H10"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;": [
				"I15"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;": [
				"G9"
			],
			"upgrade=cost:40,terrain:mountain;border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"E9"
			],
			"upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"F6"
			],
			"upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;": [
				"K15"
			],
			"upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"I7"
			],
			"upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"G15"
			],
			"upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;": [
				"E13"
			],
			"upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;": [
				"F10"
			],
			"upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"J8"
			],
			"upgrade=cost:40,terrain:mountain;icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;border=edge:4,type:mountain,cost:40;border=edge:5,type:mountain,cost:40;": [
				"G7",
				"I9"
			],
			"icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;border=edge:1,type:mountain,cost:40;": [
				"G11"
			],
			"icon=image:18_co/mine,sticky:1,name:mine;border=edge:0,type:mountain,cost:40;border=edge:2,type:mountain,cost:40;": [
				"J10"
			]
		},
		"red": {
			"offboard=revenue:yellow_50|brown_20;path=a:0,b:_0,terminal:1;": [
				"A11"
			],
			"city=revenue:yellow_40|brown_50;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1;": [
				"A17"
			],
			"city=revenue:yellow_50|brown_30;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;": [
				"B26"
			],
			"offboard=revenue:yellow_50|brown_70;path=a:3,b:_0;path=a:5,b:_0,terminal:1;": [
				"E1"
			],
			"city=revenue:yellow_50|brown_30;path=a:0,b:_0,terminal:1;": [
				"E27"
			],
			"city=revenue:yellow_50|brown_30;path=a:2,b:_0,terminal:1;": [
				"G27"
			],
			"city=revenue:yellow_40|brown_20;path=a:0,b:_0;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1": [
				"J26"
			],
			"offboard=revenue:yellow_20|brown_30;path=a:4,b:_0,terminal:1;": [
				"L2"
			],
			"offboard=revenue:yellow_30|brown_50;path=a:1,b:_0,terminal:1;": [
				"L14",
				"L20"
			]
		},
		"gray": {
			"": [
				"C13"
			],
			"path=a:0,b:5;path=a:1,b:5;path=a:1,b:3;path=a:2,b:3": [
				"F26"
			],
			"path=a:2,b:1;path=a:3,b:1;": [
				"L4"
			],
			"path=a:2,b:4;path=a:3,b:4;": [
				"L12",
				"L18"
			]
		},
		"yellow": {
			"city=revenue:0;border=edge:2,type:mountain,cost:40;border=edge:3,type:mountain,cost:40;": [
				"K5"
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
			"operating_rounds": 2
		},
		{
			"name": "3",
			"on": "3",
			"train_limit": 4,
			"tiles": [
				"yellow",
				"green"
			],
			"status": [
				"can_buy_companies"
			],
			"operating_rounds": 2
		},
		{
			"name": "4",
			"on": "4",
			"train_limit": 3,
			"tiles": [
				"yellow",
				"green"
			],
			"status": [
				"can_buy_companies"
			],
			"operating_rounds": 2
		},
		{
			"name": "5",
			"on": "5",
			"train_limit": 3,
			"tiles": [
				"yellow",
				"green",
				"brown"
			],
			"status": [
				"closable_corporations"
			],
			"operating_rounds": 2
		},
		{
			"name": "5b",
			"on": "4D",
			"train_limit": 2,
			"tiles": [
				"yellow",
				"green",
				"brown"
			],
			"status": [
				"closable_corporations"
			],
			"operating_rounds": 2
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
			"status": [
				"closable_corporations"
			],
			"operating_rounds": 2
		},
		{
			"name": "6b",
			"on": ["5D", "E"],
			"train_limit": 2,
			"tiles": [
				"yellow",
				"green",
				"brown"
			],
			"status": [
				"closable_corporations",
				"corporate_shares_open"
			],
			"operating_rounds": 2
		},
		{
			"name": "7",
			"on": "E",
			"train_limit": 2,
			"tiles": [
				"yellow",
				"green",
				"brown"
			],
			"status":[
				"closable_corporations",
				"corporate_shares_open",
				"reduced_tile_lay"
			],
			"operating_rounds": 2
		}
	]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
