# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1822
        JSON = <<-'DATA'
{
  "filename": "1822",
  "modulename": "1822",
  "currencyFormatStr": "£%d",
  "bankCash": 12000,
  "certLimit": {
    "3": 26,
    "4": 20,
    "5": 16,
    "6": 13,
    "7": 11
  },
  "startingCash": {
    "3": 700,
    "4": 525,
    "5": 420,
    "6": 350,
    "7": 300
  },
  "capitalization": "incremental",
  "layout": "flat",
  "mustSellInBlocks": false,
  "locationNames": {
    "A42": "Cornwall",
    "B43": "Plymouth",
    "C34": "Fishguard",
    "C38": "Barnstaple",
    "D11": "Stranraer",
    "D35": "Swansea & Oystermouth",
    "D41": "Exeter",
    "E2": "Highlands",
    "E6": "Glasgow",
    "E28": "Mid Wales",
    "E32": "Merthyr Tydfil & Pontypool",
    "E40": "Taunton",
    "F3": "Stirling",
    "F5": "Castlecary",
    "F7": "Hamilton & Coatbridge",
    "F11": "Dumfries",
    "F23": "Holyhead",
    "F35": "Cardiff",
    "G4": "Falkirk",
    "G12": "Carlisle",
    "G16": "Barrow",
    "G20": "Blackpool",
    "G22": "Liverpool",
    "G24": "Chester",
    "G28": "Shrewbury",
    "G32": "Hereford",
    "G34": "Newport",
    "G36": "Bristol",
    "G42": "Dorehester",
    "H1": "Aberdeen",
    "H3": "Dunfermline",
    "H5": "Edinburgh",
    "H13": "Penrith",
    "H17": "Lancaster",
    "H19": "Preston",
    "H21": "Wigan & Bolton",
    "H23": "Warrington",
    "H25": "Crewe",
    "H33": "Gloucester",
    "H37": "Bath & Radstock",
    "I22": "Manchester",
    "I26": "Stoke-on-Trent",
    "I30": "Birmingham",
    "I40": "Salisbury",
    "I42": "Bournemouth",
    "J15": "Darlington",
    "J21": "Bradford",
    "J29": "Derby",
    "J31": "Coventry",
    "J41": "Southamton",
    "K10": "Newcastle",
    "K12": "Durham",
    "K14": "Middlesbrough",
    "K20": "Leeds",
    "K24": "Sheffield",
    "K28": "Nottingham",
    "K30": "Leicester",
    "K36": "Oxford",
    "K38": "Reading",
    "K42": "Portsmouth",
    "L19": "York",
    "L33": "Northamton",
    "M16": "Scarborough",
    "M26": "Lincoln",
    "M30": "Peterborough",
    "M36": "Hertford",
    "M42": "Brighton",
    "N21": "Hull",
    "N23": "Grimsby",
    "N33": "Cambridge",
    "O30": "King's Lynn",
    "O36": "Colchester",
    "O40": "Maidstone",
    "O42": "Folkstone",
    "P35": "Ipswich",
    "P39": "Canterbury",
    "P41": "Dover",
    "P43": "English Channel",
    "Q44": "France"
  },
  "tiles": {
    "1": 1,
    "2": 1,
    "3": 6,
    "4": 6,
    "5": 6,
    "6": 8,
    "7": "unlimited",
    "8": "unlimited",
    "9": "unlimited",
    "55": 1,
    "56": 1,
    "57": 6,
    "58": 6,
    "69": 1,
    "14": 6,
    "15": 6,
    "80": 6,
    "81": 6,
    "82": 8,
    "83": 8,
    "141": 4,
    "142": 4,
    "143": 4,
    "144": 4,
    "207": 2,
    "208": 1,
    "619": 6,
    "622": 1,
    "63": 8,
    "544": 6,
    "545": 6,
    "546": 8,
    "611": 4,
    "60": 2,
    "X20": {
      "count": 1,
      "color": "yellow",
      "code": "city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;label=London"
    },
    "405": {
      "count": 3,
      "color": "green",
      "code": "city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T"
    },
    "X1": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:30,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C"
    },
    "X2": {
      "count": 2,
      "color": "green",
      "code": "city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=BM"
    },
    "X3": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:30,slots:2;path=a:1,b:_0;path=a:4,b:_0;label=S"
    },
    "X4": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;upgrade=cost:100;label=EC"
    },
    "X21": {
      "count": 1,
      "color": "green",
      "code": "city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;label=London"
    },
    "145": {
      "count": 4,
      "color": "brown",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0"
    },
    "146": {
      "count": 4,
      "color": "brown",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0"
    },
    "147": {
      "count": 6,
      "color": "brown",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0"
    },
    "X5": {
      "count": 3,
      "color": "brown",
      "code": "city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y"
    },
    "X6": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:50,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C"
    },
    "X7": {
      "count": 2,
      "color": "brown",
      "code": "city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=BM"
    },
    "X8": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:40,slots:2;path=a:1,b:_0;path=a:4,b:_0;label=S"
    },
    "X9": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:0,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0,lanes:2;upgrade=cost:100;label=EC"
    },
    "X10": {
      "count": 3,
      "color": "brown",
      "code": "city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T"
    },
    "X22": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;city=revenue:80;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;label=London"
    },
    "169": {
      "count": 2,
      "color": "gray",
      "code": "junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0"
    },
    "X11": {
      "count": 2,
      "color": "gray",
      "code": "city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y"
    },
    "X12": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C"
    },
    "X13": {
      "count": 2,
      "color": "gray",
      "code": "city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=BM"
    },
    "X14": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:60,slots:2;path=a:1,b:_0;path=a:4,b:_0;label=S"
    },
    "X15": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:0,slots:3;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0,lanes:2;label=EC"
    },
    "X16": {
      "count": 2,
      "color": "gray",
      "code": "city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;label=T"
    },
    "X17": {
      "count": 2,
      "color": "gray",
      "code": "town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0"
    },
    "X18": {
      "count": 2,
      "color": "gray",
      "code": "city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0"
    },
    "X19": {
      "count": 4,
      "color": "gray",
      "code": "city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0"
    },
    "X23": {
      "count": 1,
      "color": "gray",
      "code": "city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=London"
    }
  },
  "market": [
    [
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "550",
      "600",
      "650",
      "700e"
    ],
    [
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "330",
      "360",
      "400",
      "450",
      "500",
      "550",
      "600",
      "650"
    ],
    [
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "200",
      "220",
      "245",
      "270",
      "300",
      "330",
      "360",
      "400",
      "450",
      "500",
      "550",
      "600"
    ],
    [
      "70",
      "80",
      "90",
      "100",
      "110",
      "120",
      "135",
      "150",
      "165",
      "180",
      "200",
      "220",
      "245",
      "270",
      "300",
      "330",
      "360",
      "400",
      "450",
      "500",
      "550"
    ],
    [
      "60",
      "70",
      "80",
      "90",
      "100px",
      "110",
      "120",
      "135",
      "150",
      "165",
      "180",
      "200",
      "220",
      "245",
      "270",
      "300",
      "330",
      "360",
      "400",
      "450",
      "500"
    ],
    [
      "50",
      "60",
      "70",
      "80",
      "90px",
      "100",
      "110",
      "120",
      "135",
      "150",
      "165",
      "180",
      "200",
      "220",
      "245",
      "270",
      "300",
      "330"
    ],
    [
      "45y",
      "50",
      "60",
      "70",
      "80px",
      "90",
      "100",
      "110",
      "120",
      "135",
      "150",
      "165",
      "180",
      "200",
      "220",
      "245"
    ],
    [
      "40y",
      "45y",
      "50",
      "60",
      "70px",
      "80",
      "90",
      "100",
      "110",
      "120",
      "135",
      "150",
      "165",
      "180"
    ],
    [
      "35y",
      "40y",
      "45y",
      "50",
      "60px",
      "70",
      "80",
      "90",
      "100",
      "110",
      "120",
      "135"
    ],
    [
      "30y",
      "35y",
      "40y",
      "45y",
      "50p",
      "60",
      "70",
      "80",
      "90",
      "100"
    ],
    [
      "25y",
      "30y",
      "35y",
      "40y",
      "45y",
      "50",
      "60",
      "70",
      "80"
    ],
    [
      "20y",
      "25y",
      "30y",
      "35y",
      "40y",
      "45y",
      "50y",
      "60y"
    ],
    [
      "15y",
      "20y",
      "25y",
      "30y",
      "35y",
      "40y",
      "45y"
    ],
    [
      "10y",
      "15y",
      "20y",
      "25y",
      "30y",
      "35y"
    ],
    [
      "5y",
      "10y",
      "15y",
      "20y",
      "25y"
    ]
  ],
  "companies": [
    {
      "name": "Butterley Engineering Company",
      "sym": "P1",
      "value": 0,
      "revenue": 5,
      "desc": "MAJOR, Phase 5. 5-Train. This is a normal 5-train that is subject to all of the normal rules. Note that a company can acquire this private company at the start of its turn, even if it is already at its train limit as this counts as an acquisition action, not a train buying action. However, once acquired the acquiring company needs to check whether it is at train limit and discard any trains held in excess of limit.",
      "abilities": [
      ]
    },
    {
      "name": "Middleton Railway",
      "sym": "P2",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR/MINOR, Phase 2. Remove Small Station. Allows the owning company to place a plain yellow track tile directly on an undeveloped small station hex location or upgrade a small station tile of one colour to a plain track tile of the next colour. This closes the company and counts as the company’s normal track laying step. All other normal track laying restrictions apply. Once acquired, the private company pays its revenue to the owning company until the power is exercised and the company is closed.",
      "abilities": [
      ]
    },
    {
      "name": "Shrewsbury and Hereford Railway",
      "sym": "P3",
      "value": 0,
      "revenue": 0,
      "desc": "MAJOR, Phase 2. Permanent 2-Train. 2P-train is a permanent 2-train. It cannot be sold to another company. It does not count against train limit. It does not count as a train for the purpose of mandatory train ownership and purchase. A company may not own more than one 2P train. Dividends can be separated from other trains and may be split, paid in full, or retained. If a company runs a 2P-train and pays a dividend (split or full), but retains its dividend from other train operations this still counts as a normal dividend for stock price movement purposes. Vice-versa, if a company pays a dividend (split or full) with its other trains, but retains the dividend from the 2P, this also still counts as a normal dividend for stock price movement purposes. Does not close.",
      "abilities": [
      ]
    },
    {
      "name": "South Devon Railway",
      "sym": "P4",
      "value": 0,
      "revenue": 0,
      "desc": "MAJOR, Phase 2. Permanent 2-Train. 2P-train is a permanent 2-train. It cannot be sold to another company. It does not count against train limit. It does not count as a train for the purpose of mandatory train ownership and purchase. A company may not own more than one 2P train. Dividends can be separated from other trains and may be split, paid in full, or retained. If a company runs a 2P-train and pays a dividend (split or full), but retains its dividend from other train operations this still counts as a normal dividend for stock price movement purposes. Vice-versa, if a company pays a dividend (split or full) with its other trains, but retains the dividend from the 2P, this also still counts as a normal dividend for stock price movement purposes. Does not close.",
      "abilities": [
      ]
    },
    {
      "name": "London, Chatham and Dover Railway",
      "sym": "P5",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR, Phase 3. English Channel. The owning company may place an exchange station token on the map, free of charge, in a token space in the English Channel. The company does not need to be able to trace a route to the English Channel to use this property (i.e. any company can use this power to place a token in the English Channel). If no token spaces are available, but a space could be created by upgrading the English Channel track then this power may be used to place a token and upgrade the track simultaneously. This counts as the acquiring company’s tile lay action and incurs the usual costs for doing so. Alternatively, it can move an exchange station token to the available station token section on its company charter.",
      "abilities": [
      ]
    },
    {
      "name": "Leeds & Selby Railway",
      "sym": "P6",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR, Phase 3. Mail Contract. After running trains, the owning company receives income into its treasury equal to one half of the base value of the start and end stations from one of the trains operated. Doubled values (for E trains or destination tokens) do not count. The company is not required to maximise the dividend from its run if it wishes to maximise its revenue from the mail contract by stopping at a large city and not running beyond it to include small stations. Does not close.",
      "abilities": [
      ]
    },
    {
      "name": "Shrewsbury and Birmingham Railway",
      "sym": "P7",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR, Phase 3. Mail Contract. After running trains, the owning company receives income into its treasury equal to one half of the base value of the start and end stations from one of the trains operated. Doubled values (for E trains or destination tokens) do not count. The company is not required to maximise the dividend from its run if it wishes to maximise its revenue from the mail contract by stopping at a large city and not running beyond it to include small stations. Does not close.",
      "abilities": [
      ]
    },
    {
      "name": "Edinburgh and Glasgow Railway",
      "sym": "P8",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR/MINOR, Phase 3. Mountain/Hill Discount. Either: The acquiring company receives a discount token that can be used to pay the full cost of a single track tile lay on a rough terrain, hill or mountain hex. This closes the company. Or: The acquiring company rejects the token and receives a £20 discount off the cost of all hill and mountain terrain (i.e. NOT off the cost of rough terrain). The private company does not close. Closes if free token taken when acquired. Otherwise, flips when acquired and does not close.",
      "abilities": [
      ]
    },
    {
      "name": "Midland and Great Northern Joint Railway",
      "sym": "P9",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR/MINOR, Phase 3. Declare 2x Cash Holding. If held by a player, the holding player may declare double their actual cash holding at the end of a stock round to determine player turn order in the next stock round. If held by a company it pays revenue of £20 (green)/£40 (brown)/£60 (grey). Does not close.",
      "abilities": [
      ]
    },
    {
      "name": "Glasgow and South- Western Railway",
      "sym": "P10",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR/MINOR, Phase 3. River/Estuary Discount. The acquiring company receives two discount tokens each of which can be used to pay the cost for one track lay over an estuary crossing. They can be used on the same or different tile lays. Use of the second token closes the company. In addition, until the company closes it provides a discount of £10 against the cost of all river terrain (excluding estuary crossings).",
      "abilities": [
      ]
    },
    {
      "name": "Bristol & Exeter Railway",
      "sym": "P11",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR/MINOR, Phase 2. Advanced Tile Lay. The owning company may lay one plain or small station track upgrade using the next colour of track to be available, before it is actually made available by phase progression. The normal rules for progression of track lay must be followed (i.e. grey upgrades brown upgrades green upgrades yellow) it is not possible to skip a colour using this private. All other normal track laying restrictions apply. This is in place of its normal track lay action. Once acquired, the private company pays its revenue to the owning company until the power is exercised and the company closes.",
      "abilities": [
      ]
    },
    {
      "name": "Leicester & Swannington Railway",
      "sym": "P12",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR/MINOR, Phase 3. Extra Tile Lay. The owning company may lay an additional yellow tile (or two for major companies), or make one additional tile upgrade in its track laying step. The upgrade can be to a tile laid in its normal tile laying step. All other normal track laying restrictions apply. Once acquired, the private company pays its revenue to the owning company until the power is exercised and the company closes.",
      "abilities": [
      ]
    },
    {
      "name": "York, Newcastle and Berwick Railway",
      "sym": "P13",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR/MINOR, Phase 5. Pullman. A “Pullman” carriage train that can be added to another train owned by the company. It converts the train into a + train. Does not count against train limit and does not count as a train for the purposes of train ownership. Cannot be sold to another company. Does not close.",
      "abilities": [
      ]
    },
    {
      "name": "Kilmarnock and Troon Railway",
      "sym": "P14",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR/MINOR, Phase 5. Pullman. A “Pullman” carriage train that can be added to another train owned by the company. It converts the train into a + train. Does not count against train limit and does not count as a train for the purposes of train ownership. Cannot be sold to another company. Does not close.",
      "abilities": [
      ]
    },
    {
      "name": "Highland Railway",
      "sym": "P15",
      "value": 0,
      "revenue": 0,
      "desc": "MAJOR/MINOR, Phase 2. £10x Phase. Pays revenue of £10 x phase number to the player, and pays treasury credits of £10 x phase number to the private company. This credit is retained on the private company charter. When acquired, the acquiring company receives this treasury money and this private company closes. If not acquired beforehand, this company closes at the start of Phase 7 and all treasury credits are returned to the bank.",
      "abilities": [
      ]
    },
    {
      "name": "Off-Shore Tax Haven",
      "sym": "P16",
      "value": 0,
      "revenue": 0,
      "desc": "CAN NOT BE AQUIRED. Tax Haven. As a stock round action, under the direction and funded by the owning player, the off-shore Tax Haven may purchase an available share certificate and place it onto P16’s charter. The certificate is not counted for determining directorship of a company. The share held in the tax haven does NOT count against the 60% share limit for purchasing shares. If at 60% (or more) in hand in a company, a player can still purchase an additional share in that company and place it in the tax haven. Similarly, if a player holds 50% of a company, plus has 10% of the same company in the tax haven, they can buy a further 10% share. A company with a share in the off-shore tax haven CAN be “all sold out” at the end of a stock round. Dividends paid to the share are also placed onto the off-shore tax haven charter. At the end of the game, the player receives the share certificate from the off-shore tax haven charter and includes it in their portfolio for determining final worth. The player also receives the cash from dividend income accumulated on the charter. Cannot be acquired. Does not count against the certificate limit.",
      "abilities": [
      ]
    },
    {
      "name": "Lancashire Union Railway",
      "sym": "P17",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR, Phase 2. Move Card. Allows the director of the owning company to select one concession, private company, or minor company from the relevant stack of certificates, excluding those items currently in the bidding boxes, and move it to the top or the bottom of the stack. Closes when the power is exercised.",
      "abilities": [
      ]
    },
    {
      "name": "Cromford Union and High Peak Railway",
      "sym": "P18",
      "value": 0,
      "revenue": 10,
      "desc": "MAJOR, Phase 5. Station Marker Swap. Allows the owning company to move a token from the exchange token area of its charter to the available token area, or vice versa. This company closes when its power is exercised.",
      "abilities": [
      ]
    },
    {
      "name": "CONCESSION: London and North West Railway",
      "sym": "C1",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and converts into the LNWR's 10% director certificate. LNWR may also put it's destination token into Manchester when converted.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["LNWR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "lnwrBlack",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: Great Western Railway",
      "sym": "C2",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the GWR director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["GWR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "gwrGreen",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: London, Brighton and South Coast Railway",
      "sym": "C3",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the LBSCR director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["LBSCR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "lbscrYellow",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: South Eastern & Chatham Railway",
      "sym": "C4",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the SECR director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["SECR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "secrOrange",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: Caledonian Railway",
      "sym": "C5",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the CR director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["CR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "crBlue",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: Midland Railway",
      "sym": "C6",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the MR director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["MR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "mrRed",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: Lancashire & Yorkshire",
      "sym": "C7",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the LYR director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["LYR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "lyrPurple",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: North British Railway",
      "sym": "C8",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the NBR director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["NBR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "nbrBrown",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: South Wales Railway",
      "sym": "C9",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the SWR director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["SWR"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "swrGray",
      "text_color": "white"
    },
    {
      "name": "CONCESSION: North Eastern Railway",
      "sym": "C10",
      "value": 100,
      "revenue": 10,
      "desc": "Have a face value £100 and contribute £100 to the conversion into the NER director’s certificate.",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["NER"],
          "owner_type": "player",
          "from": "par"
        }
      ],
      "color": "nerGreen",
      "text_color": "white"
    },
    {
      "name": "MINOR: 1. Great North of Scotland Railway",
      "sym": "M1",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is H1.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 2. Lanarkshire & Dumbartonshire Railway",
      "sym": "M2",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is E2.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 3. Edinburgh & Dalkeith Railway",
      "sym": "M3",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is H5.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 4. Newcastle & North shields Railway",
      "sym": "M4",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is K10.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 5. Stockton and Darlington Railway",
      "sym": "M5",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is J15.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 6. Furness railway",
      "sym": "M6",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is G16.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 7. Warrington & Newton Railway",
      "sym": "M7",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is H23.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 8. Manchester Sheffield & Lincolnshire Railway",
      "sym": "M8",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is K24.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 9. East Lincolnshire Railway",
      "sym": "M9",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is N23.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 10. Grand Junction Railway",
      "sym": "M10",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is I30.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 11. Great Northern Railway",
      "sym": "M11",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is M30.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 12. Eastern Union Railway",
      "sym": "M12",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is P35.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 13. Headcorn & Maidstone Junction Light Railway",
      "sym": "M13",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is O40.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 14. Metropolitan Railway",
      "sym": "M14",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is M38.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 15. London Tilbury & Southend Railway",
      "sym": "M15",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is M38.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 16. Wycombe Railway",
      "sym": "M16",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is M38.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 17. London & Southampton Railway",
      "sym": "M17",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is J41.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 18. Somerset & Dorset Joint Railway",
      "sym": "M18",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is I42.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 19. Penarth Harbour & Dock Railway Company",
      "sym": "M19",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is F35.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 20. Monmouthshire Railway & Canal Company",
      "sym": "M20",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is F33.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 21. Taff Vale railway",
      "sym": "M21",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is E34.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 22. Exeter and Crediton Railway",
      "sym": "M22",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is D41.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 23. West Cornwall Railway",
      "sym": "M23",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is A42.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    },
    {
      "name": "MINOR: 24. The Swansea and Mumbles Railway",
      "sym": "M24",
      "value": 100,
      "revenue": 0,
      "desc": "A 50% director’s certificate in the associated minor company. Starting location is D35.",
      "abilities": [
      ],
      "color": "white",
      "text_color": "black"
    }
  ],
  "minors": [
  ],
  "corporations": [
    {
      "sym": "1",
      "name": "Great North of Scotland Railway",
      "logo": "1822/1",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "H1",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "2",
      "name": "Lanarkshire & Dumbartonshire Railway",
      "logo": "1822/2",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "E2",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "3",
      "name": "Edinburgh & Dalkeith Railway",
      "logo": "1822/3",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "H5",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "4",
      "name": "Newcastle & North shields Railway",
      "logo": "1822/4",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "K10",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "5",
      "name": "Stockton and Darlington Railway",
      "logo": "1822/5",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "J15",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "6",
      "name": "Furness railway",
      "logo": "1822/6",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "G16",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "7",
      "name": "Warrington & Newton Railway",
      "logo": "1822/7",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "H23",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "8",
      "name": "Manchester Sheffield & Lincolnshire Railway",
      "logo": "1822/8",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "K24",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "9",
      "name": "East Lincolnshire Railway",
      "logo": "1822/9",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "N23",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "10",
      "name": "Grand Junction Railway",
      "logo": "1822/10",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "I30",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "11",
      "name": "Great Northern Railway",
      "logo": "1822/11",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "M30",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "12",
      "name": "Eastern Union Railway",
      "logo": "1822/12",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "P35",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "13",
      "name": "Headcorn & Maidstone Junction Light Railway",
      "logo": "1822/13",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "O40",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "14",
      "name": "Metropolitan Railway",
      "logo": "1822/14",
      "tokens": [
        20
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "R38",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "15",
      "name": "London Tilbury & Southend Railway",
      "logo": "1822/15",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "M38",
      "city": 4,
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "16",
      "name": "Wycombe Railway",
      "logo": "1822/16",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "M38",
      "city": 2,
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "17",
      "name": "London & Southampton Railway",
      "logo": "1822/17",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "J41",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "18",
      "name": "Somerset & Dorset Joint Railway",
      "logo": "1822/18",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "I42",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "19",
      "name": "Penarth Harbour & Dock Railway Company",
      "logo": "1822/19",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "F35",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "20",
      "name": "Monmouthshire Railway & Canal Company",
      "logo": "1822/20",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "F33",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "21",
      "name": "Taff Vale railway",
      "logo": "1822/21",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "E34",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "22",
      "name": "Exeter and Crediton Railway",
      "logo": "1822/22",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "D41",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "23",
      "name": "West Cornwall Railway",
      "logo": "1822/23",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "A42",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "24",
      "name": "The Swansea and Mumbles Railway",
      "logo": "1822/24",
      "tokens": [
        0
      ],
      "type": "minor",
      "always_market_price": true,
      "float_percent": 100,
      "hide_shares": true,
      "shares": [100],
      "max_ownership_percent": 100,
      "coordinates": "D35",
      "color": "white",
      "text_color": "black"
    },
    {
      "sym": "LNWR",
      "name": "London and North West Railway",
      "logo": "1822/LNWR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 10,
      "shares": [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
      "always_market_price": true,
      "coordinates": "M38",
      "city": 3,
      "color": "lnwrBlack"
    },
    {
      "sym": "GWR",
      "name": "Great Western Railway",
      "logo": "1822/GWR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "M38",
      "city": 1,
      "color": "gwrGreen"
    },
    {
      "sym": "LBSCR",
      "name": "London, Brighton and South Coast Railway",
      "logo": "1822/LBSCR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "M38",
      "city": 0,
      "color": "lbscrYellow",
      "text_color": "black"
    },
    {
      "sym": "SECR",
      "name": "South Eastern & Chatham Railway",
      "logo": "1822/SECR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "M38",
      "city": 5,
      "color": "secrOrange"
    },
    {
      "sym": "CR",
      "name": "Caledonian Railway",
      "logo": "1822/CR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "E6",
      "color": "crBlue"
    },
    {
      "sym": "MR",
      "name": "Midland Railway",
      "logo": "1822/MR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "J29",
      "color": "mrRed"
    },
    {
      "sym": "LYR",
      "name": "Lancashire & Yorkshire",
      "logo": "1822/LYR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "G22",
      "color": "lyrPurple"
    },
    {
      "sym": "NBR",
      "name": "North British Railway",
      "logo": "1822/NBR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "H5",
      "color": "nbrBrown"
    },
    {
      "sym": "SWR",
      "name": "South Wales Railway",
      "logo": "1822/SWR",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "H33",
      "color": "swrGray",
      "text_color": "black"
    },
    {
      "sym": "NER",
      "name": "North Eastern Railway",
      "logo": "1822/NER",
      "tokens": [
        0,
        100
      ],
      "type": "major",
      "float_percent": 20,
      "always_market_price": true,
      "coordinates": "L19",
      "color": "nerGreen"
    }
  ],
  "trains": [
    {
      "name": "L",
      "distance": [
        {
          "nodes": ["city"],
          "pay": 1,
          "visit": 1
        },
        {
          "nodes": ["town"],
          "pay": 1,
          "visit": 1
        }
      ],
      "num": 22,
      "price": 60,
      "rusts_on": "3",
      "variants": [
        {
          "name": "2",
          "distance": 2,
          "price": 120,
          "rusts_on": "4",
          "available_on": "1"
        }
      ]
    },
    {
      "name": "3",
      "distance": 3,
      "num": 9,
      "price": 200,
      "rusts_on": "6"
    },
    {
      "name": "4",
      "distance": 4,
      "num": 6,
      "price": 300,
      "rusts_on": "7"
    },
    {
      "name": "5",
      "distance": 5,
      "num": 5,
      "price": 500
    },
    {
      "name": "6",
      "distance": 6,
      "num": 3,
      "price": 600
    },
    {
      "name": "7",
      "distance": 7,
      "num": 20,
      "price": 750,
      "variants": [
        {
          "name": "E",
          "distance": 99,
          "num": 20,
          "price": 1000
        }
      ]
    }
  ],
  "hexes": {
    "white": {
      "": [
        "B39",
        "C10",
        "D9",
        "E8",
        "E12",
        "F41",
        "G2",
        "G6",
        "G26",
        "G38",
        "G40",
        "H11",
        "H27",
        "H29",
        "H31",
        "H41",
        "I6",
        "I28",
        "I34",
        "I36",
        "J9",
        "J11",
        "J13",
        "J17",
        "J27",
        "J33",
        "J35",
        "J37",
        "K8",
        "K16",
        "K18",
        "K22",
        "K26",
        "K32",
        "K34",
        "K40",
        "L15",
        "L17",
        "L23",
        "L25",
        "L27",
        "L29",
        "L31",
        "L35",
        "L41",
        "M18",
        "M20",
        "M24",
        "M32",
        "M34",
        "N19",
        "N25",
        "N31",
        "N35",
        "N41",
        "O32",
        "O34",
        "P27",
        "P29",
        "P31",
        "P33",
        "Q28",
        "Q32",
        "Q34"
      ],
      "border=edge:4,type:impassable": [
        "H43"
      ],
      "border=edge:3,type:impassable;border=edge:4,type:impassable": [
        "D37"
      ],
      "border=edge:0,type:impassable;border=edge:5,type:impassable": [
        "N27"
      ],
      "border=edge:0,type:impassable;border=edge:1,type:impassable;border=edge:5,type:impassable": [
        "E36"
      ],
      "border=edge:0,type:water,cost:40": [
        "G10"
      ],
      "border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40;border=edge:5,type:impassable": [
        "O38"
      ],
      "border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:40;stub=edge:1": [
        "N37"
      ],
      "stub=edge:5": [
        "L37"
      ],
      "stub=edge:4": [
        "L39"
      ],
      "stub=edge:3": [
        "M40"
      ],
      "upgrade=cost:20,terrain:swamp": [
        "C42",
        "F39",
        "L21",
        "M28"
      ],
      "upgrade=cost:20,terrain:swamp;border=edge:1,type:impassable;border=edge:2,type:impassable": [
        "O28"
      ],
      "upgrade=cost:20,terrain:swamp;border=edge:3,type:impassable": [
        "E38"
      ],
      "upgrade=cost:20,terrain:swamp;border=edge:2,type:water,cost:40": [
        "H35"
      ],
      "upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40;stub=edge:2": [
        "N39"
      ],
      "upgrade=cost:20,terrain:swamp;border=edge:2,type:impassable;border=edge:3,type:impassable": [
        "F37"
      ],
      "upgrade=cost:40,terrain:swamp": [
        "D43",
        "I32",
        "M22"
      ],
      "upgrade=cost:40,terrain:swamp;border=edge:3,type:impassable;border=edge:4,type:impassable": [
        "N29"
      ],
      "upgrade=cost:40,terrain:hill": [
        "B41",
        "D39",
        "G14",
        "G30",
        "H39",
        "I12",
        "I24",
        "I38",
        "J39"
      ],
      "upgrade=cost:60,terrain:hill": [
        "C40",
        "E10",
        "F9",
        "G8",
        "H7",
        "H9",
        "H15",
        "I8",
        "I10",
        "J7",
        "J23",
        "J25"
      ],
      "upgrade=cost:80,terrain:mountain": [
        "I14",
        "I16",
        "I18",
        "I20",
        "J19"
      ],
      "town=revenue:0": [
        "C38",
        "D11",
        "E40",
        "F3",
        "F5",
        "G20",
        "G28",
        "G32",
        "G42",
        "H13",
        "H25",
        "I26",
        "J31",
        "K12",
        "K36",
        "M16",
        "M26",
        "N33",
        "O42"
      ],
      "town=revenue:0;border=edge:2,type:impassable": [
        "H17",
        "P39"
      ],
      "town=revenue:0;border=edge:1,type:impassable;border=edge:0,type:water,cost:40": [
        "H3"
      ],
      "town=revenue:0;border=edge:5,type:impassable": [
        "F11"
      ],
      "town=revenue:0;border=edge:0,type:water,cost:40": [
        "O36"
      ],
      "town=revenue:0;stub=edge:0": [
        "M36"
      ],
      "town=revenue:0;town=revenue:0": [
        "F7",
        "H21"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:20,terrain:swamp": [
        "H37"
      ],
      "town=revenue:0;upgrade=cost:20,terrain:swamp": [
        "O30"
      ],
      "town=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:40": [
        "G34"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:swamp": [
        "G24"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:hill": [
        "I40"
      ],
      "town=revenue:0;upgrade=cost:60,terrain:hill": [
        "J21"
      ],
      "city=revenue:0": [
        "D41",
        "H19",
        "J15",
        "J29",
        "J41",
        "K10",
        "K14",
        "K20",
        "K24",
        "K28",
        "K30",
        "K38",
        "L33",
        "M30",
        "P35",
        "P41",
        "R38"
      ],
      "city=revenue:0;border=edge:1,type:impassable": [
        "I42"
      ],
      "city=revenue:0;border=edge:4,type:impassable": [
        "G4"
      ],
      "city=revenue:0;border=edge:5,type:impassable": [
        "G16"
      ],
      "city=revenue:0;border=edge:2,type:impassable;border=edge:3,type:water,cost:40": [
        "G12"
      ],
      "city=revenue:20,loc:center;town=revenue:10,loc:1;path=a:_0,b:_1;border=edge:0,type:impassable;label=S":[
        "D35"
      ],
      "city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;upgrade=cost:20;label=London": [
        "M38"
      ],
      "city=revenue:0;label=T": [
        "B43",
        "K42",
        "M42"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:swamp": [
        "L19",
        "Q30"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:swamp": [
        "H23",
        "H33"
      ],
      "city=revenue:0;upgrade=cost:40,terrain:hill": [
        "O40"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:0,type:water,cost:40": [
        "N21"
      ],
      "city=revenue:0;upgrade=cost:20,terrain:swamp;border=edge:3,type:water,cost:40": [
        "N23"
      ]
    },
    "yellow": {
      "city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;border=edge:0,type:impassable;border=edge:5,type:impassable;label=C": [
        "F35"
      ],
      "city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=Y": [
        "G22"
      ],
      "city=revenue:30,slots:2;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:2,type:impassable;border=edge:3,type:water,cost:40;upgrade=cost:20,terrain:swamp;label=Y": [
        "G36"
      ],
      "city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;border=edge:3,type:water,cost:40;label=Y": [
        "H5"
      ],
      "city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;upgrade=cost:60,terrain:hill;label=BM": [
        "I22"
      ],
      "city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;upgrade=cost:40,terrain:swamp;label=BM": [
        "I30"
      ],
      "city=revenue:0;upgrade=cost:100;label=EC": [
        "P43"
      ]
    },
    "gray": {
      "city=revenue:yellow_40|green_30|brown_30|gray_40,slots:2,loc:1.5;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1": [
        "A42"
      ],
      "city=revenue:yellow_10|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1": [
        "C34"
      ],
      "city=revenue:yellow_10|green_10|brown_20|gray_20,slots:2;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1": [
        "E2"
      ],
      "path=a:0,b:3": [
        "E4"
      ],
      "city=revenue:yellow_40|green_50|brown_60|gray_70,slots:3,loc:1;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0": [
        "E6"
      ],
      "path=a:0,b:4,lanes:2": [
        "E26"
      ],
      "city=revenue:yellow_10|green_20|brown_20|gray_30,slots:3;path=a:0,b:_0,lanes:2,terminal:1;path=a:3,b:_0,lanes:2,terminal:1;path=a:4,b:_0,lanes:2,terminal:1;path=a:5,b:_0,lanes:2,terminal:1": [
        "E28"
      ],
      "path=a:3,b:5,lanes:2": [
        "E30"
      ],
      "path=a:0,b:5": [
        "E32"
      ],
      "city=revenue:yellow_30|green_40|brown_30|gray_10,slots:2,loc:0;path=a:3,b:_0;path=a:4,b:_0,terminal:1;path=a:5,b:_0": [
        "E34"
      ],
      "city=revenue:yellow_20|green_20|brown_30|gray_40,slots:2;path=a:5,b:_0,terminal:1": [
        "F23"
      ],
      "path=a:1,b:4,a_lane:2.0;path=a:1,b:5,a_lane:2.1": [
        "F25",
        "F27"
      ],
      "path=a:2,b:4,a_lane:2.0;path=a:2,b:5,a_lane:2.1": [
        "F29",
        "F31"
      ],
      "city=revenue:yellow_20|green_40|brown_30|gray_10,slots:2,loc:4;path=a:1,b:_0;path=a:2,b:_0,terminal:1;path=a:5,b:_0": [
        "F33"
      ],
      "city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1": [
        "H1"
      ],
      "offboard=revenue:yellow_0|green_60|brown_90|gray_120;path=a:2,b:_0": [
        "Q44"
      ]
    },
    "blue": {
      "junction;path=a:2,b:_0,terminal:1": [
        "L11",
        "J43",
        "Q36",
        "Q42",
        "R31"
      ],
      "junction;path=a:4,b:_0,terminal:1": [
        "F17"
      ],
      "junction;path=a:5,b:_0,terminal:1": [
        "F15",
        "F21"
      ]
    }
  },
  "phases": [
    {
      "name": "1",
      "on": "",
      "train_limit": {
        "minor": 2,
        "major": 4
      },
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "2",
      "on": ["2", "3"],
      "train_limit": {
        "minor": 2,
        "major": 4
      },
      "tiles": [
        "yellow"
      ],
      "status": [
        "can_convert_concessions"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3",
      "on": "3",
      "train_limit": {
        "minor": 2,
        "major": 4
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_trains",
        "can_convert_concessions"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": {
        "minor": 1,
        "major": 3
      },
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_trains",
        "can_convert_concessions"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5",
      "on": "5",
      "train_limit": {
        "minor": 1,
        "major": 2
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "status": [
        "can_buy_trains"
      ],
      "operating_rounds": 2
    },
    {
      "name": "6",
      "on": "6",
      "train_limit": {
        "minor": 1,
        "major": 2
      },
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "status": [
        "can_buy_trains"
      ],
      "operating_rounds": 2
    },
    {
      "name": "7",
      "on": "7",
      "train_limit": {
        "minor": 1,
        "major": 2
      },
      "tiles": [
        "yellow",
        "green",
        "brown",
        "gray"
      ],
      "status": [
        "can_buy_trains"
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
