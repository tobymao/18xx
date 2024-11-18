# frozen_string_literal: true

module Engine
  module Game
    module G1822CA
      module Entities
        COMPANIES = [
          {
            name: 'P1 (5-Train)',
            sym: 'P1',
            value: 0,
            revenue: 5,
            desc: 'MAJOR, Phase 5. Montréal Locomotive Works. This is a normal 5-train that is '\
                  'subject to all of the normal rules. Note that a company can acquire this '\
                  'private company at the start of its turn, even if it is already at its train '\
                  'limit as this counts as an acquisition action, not a train buying action. '\
                  'However, once acquired the acquiring company needs to check whether it is at '\
                  'train limit and discard any trains held in excess of limit.',
            abilities: [],
          },
          {
            name: 'P2 (Permanent L-Train)',
            sym: 'P2',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 1. Robert Stephenson & Company. An L-train cannot be sold to '\
                  'another company. It does not count as a train for the purposes of mandatory '\
                  'train ownership. It does not count against train ownership limit. A company '\
                  'cannot own both a permanent L-train and a permanent 2-train. Dividends can be '\
                  'separated from other trains and may be split, paid in full, or retained. If a '\
                  'company runs a permanent L-train and pays a dividend (split or full), but '\
                  'retains its dividend from other train operations this still counts as a normal '\
                  'dividend for stock price movement purposes. Vice-versa, if a company pays a '\
                  'dividend (split or full) with its other trains, but retains the dividend from '\
                  'the permanent L, this also still counts as a normal dividend for stock price '\
                  'movement purposes. Does not close.',
            abilities: [],
          },
          {
            name: 'P3 (Permanent 2-Train)',
            sym: 'P3',
            value: 0,
            revenue: 0,
            desc: 'MAJOR, Phase 2. Toronto Locomotive Works. 2P-train is a permanent 2-train. It '\
                  'can’t be sold to another company. It does not count against train limit. It '\
                  'does not count as a train for the purpose of mandatory train ownership and '\
                  'purchase. A company may not own more than one 2P train. A company cannot own '\
                  'both a permanent L-train and a permanent 2-train. Dividends can be separated '\
                  'from other trains and may be split, paid in full, or retained. If a company '\
                  'runs a 2P-train and pays a dividend (split or full), but retains its dividend '\
                  'from other train operations this still counts as a normal dividend for stock '\
                  'price movement purposes. Vice-versa, if a company pays a dividend (split or '\
                  'full) with its other trains, but retains the dividend from the 2P, this also '\
                  'still counts as a normal dividend for stock price movement purposes. Does not '\
                  'close.',
            abilities: [],
          },
          {
            name: 'P4 (Permanent 2-Train)',
            sym: 'P4',
            value: 0,
            revenue: 0,
            desc: 'MAJOR, Phase 2. The Countess of Dufferin. 2P-train is a permanent 2-train. It '\
                  'can’t be sold to another company. It does not count against train limit. It '\
                  'does not count as a train for the purpose of mandatory train ownership and '\
                  'purchase. A company may not own more than one 2P train. A company cannot own '\
                  'both a permanent L-train and a permanent 2-train. Dividends can be separated '\
                  'from other trains and may be split, paid in full, or retained. If a company '\
                  'runs a 2P-train and pays a dividend (split or full), but retains its dividend '\
                  'from other train operations this still counts as a normal dividend for stock '\
                  'price movement purposes. Vice-versa, if a company pays a dividend (split or '\
                  'full) with its other trains, but retains the dividend from the 2P, this also '\
                  'still counts as a normal dividend for stock price movement purposes. Does not '\
                  'close.',
            abilities: [],
          },
          {
            name: 'P5 (Pullman)',
            sym: 'P5',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 5. Pullman Car Company. A “Pullman” carriage train that can be '\
                  'added to another train owned by the company. It converts the train into a + '\
                  'train. Does not count against train limit and does not count as a train for the '\
                  'purposes of train ownership. Can’t be sold to another company. Does not close. '\
                  'May include a maximum of [2 × the train size] number of towns.',
            abilities: [],
          },
          {
            name: 'P6 (Pullman)',
            sym: 'P6',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 5. Fulton Car Works. A “Pullman” carriage train that can be added '\
                  'to another train owned by the company. It converts the train into a + train. '\
                  'Does not count against train limit and does not count as a train for the '\
                  'purposes of train ownership. Can’t be sold to another company. Does not close. '\
                  'May include a maximum of [2 × the train size] number of towns.',
            abilities: [],
          },
          {
            name: 'P7 (Declare 2× Cash Holding)',
            sym: 'P7',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Toronto Stock Exchange. If held by a player, the holding player '\
                  'may declare double their actual cash holding at the end of a stock round to '\
                  'determine player turn order in the next stock round. If held by a company it '\
                  'pays revenue of $20 (green)/$40 (brown)/$60 (grey). Does not close.',
            abilities: [],
          },
          {
            name: 'P8 ($10× Phase)',
            sym: 'P8',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 2. Stratford & Huron Railway revenue of $10 x phase number '\
                  'to the player, and pays treasury credits of $10 x phase number to the private '\
                  'company. This credit is retained on the private company charter. When acquired, '\
                  'the acquiring company receives this treasury money and this private company '\
                  'closes. If not acquired beforehand, this company closes at the start of Phase 7 '\
                  'and all treasury credits are returned to the bank.',
            abilities: [],
          },
          {
            name: 'P9 ($5× Phase)',
            sym: 'P9',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 2. General Mining Assoication. Pays revenue of $5 x phase '\
                  'number to the player, and pays treasury credits of $5 x phase number to the '\
                  'private company. This credit is retained on the private company charter. When '\
                  'acquired, the acquiring company receives this treasury money and this private '\
                  'company closes. If not acquired beforehand, this company closes at the start of '\
                  'Phase 7 and all treasury credits are returned to the bank.',
            abilities: [],
          },
          {
            name: 'P10 (Winnipeg Station)',
            sym: 'P10',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Manitoba South-Western Colonization Railway. The owning company '\
                  'may place an exchange station token on the map, free of charge, in a token '\
                  'space in Winnipeg (N16). The company does NOT need to be able to trace a route to the '\
                  'station in Winnipeg. Token must be specifically conjoined to one of the five '\
                  'Station slots. Pays company $10 until used. The company does not need to be '\
                  'able to trace a route to Winnipeg to use this property (i.e. any company can '\
                  'use this power to place a token in the Winnipeg hex).',
            abilities: [
              {
                type: 'token',
                check_tokenable: false,
                closed_when_used_up: true,
                connected: false,
                count: 1,
                extra_action: true,
                extra_slot: true,
                from_owner: false,
                hexes: ['N16'],
                owner_type: 'corporation',
                price: 0,
                special_only: true,
                teleport_price: 0,
                same_hex_allowed: true,
                when: 'owning_corp_or_turn',
              },
            ],
          },
          {
            name: 'P11 (Tax Haven)',
            sym: 'P11',
            value: 0,
            revenue: 0,
            desc: 'CANNOT BE ACQUIRED. Registered Retirement Savings Plan. As a stock round '\
                  'action, under the direction and funded by the owning player, the off-shore Tax '\
                  'Haven may purchase an available share certificate and place it onto P11’s '\
                  'charter. The certificate is not counted for determining directorship of a '\
                  'company. The share held in the tax haven does NOT count against the 60% share '\
                  'limit for purchasing shares. If at 60% (or more) in hand in a company, a player '\
                  'can still purchase an additional share in that company and place it in the tax '\
                  'haven. Similarly, if a player holds 50% of a company, plus has 10% of the same '\
                  'company in the tax haven, they can buy a further 10% share. A company with a '\
                  'share in the off-shore tax haven CAN be “all sold out” at the end of a stock '\
                  'round. Dividends paid to the share are also placed onto the off-shore tax haven '\
                  'charter. At the end of the game, the player receives the share certificate from '\
                  'the off-shore tax haven charter and includes it in their portfolio for '\
                  'determining final worth. The player also receives the cash from dividend income '\
                  'accumulated on the charter. Does not count against the '\
                  'certificate limit.',
            abilities: [],
          },
          {
            name: 'P12 (Advanced Tile Lay)',
            sym: 'P12',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Sir Sanford Fleming. The owning company may lay one plain '\
                  'or town track upgrade using the next colour of track to be available, before it '\
                  'is actually made available by phase progression. The normal rules for '\
                  'progression of track lay must be followed (i.e. grey upgrades brown upgrades '\
                  'green upgrades yellow) it is not possible to skip a colour using this private. '\
                  'All other normal track laying restrictions apply. This is in place of its '\
                  'normal track lay action. Once acquired, the private company pays its revenue to '\
                  'the owning company until the power is exercised and the company closes. May be '\
                  'used in conjunction with P29 and/or P30 as part of the same tile placement step.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: %w[track special_track],
                count: 1,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: %w[80 81 82 83 544 545 546 60 169 141 142 143 144 767 768 769],
                combo_entities: %w[P29 P30],
                consume_tile_lay: true,
              },
            ],
          },
          {
            name: 'P13 (Sawmill Bonus)',
            sym: 'P13',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. John Rudolphus Booth. Close this company to place a +$10 ('\
                  'closed) or +$20 (open to all) token in a town or city. Token placement is '\
                  'restricted and may not be placed in a grey pre-printed hex nor any labeled '\
                  'city (A, B, L, M, O, Q, T, W, Y). The placing company does not have to have a '\
                  'route to the city where the token is placed. The token increases the value of '\
                  'the revenue center by the indicated amount when running a train there. If the '\
                  'token is “open” then all companies receive the +20 bonus; if “closed” only the '\
                  'owning company receives the +10 bonus. Destination runs and E-trains both '\
                  'double the value of this token. A company may only include the token bonus to '\
                  'the run of one train per operating round. A town with a sawmill may not be '\
                  'removed by P29 or P30.',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[A9 AA15 AA9 AB22 AD18 AD20 AE17 AF16 AG13 AG3
                          AG9 AH10 AH12 AK3 AK5 AL2 AM5 AM9 AO9 AP6 C9
                          D10 D12 D14 D16 F10 F8 G11 G13 G17 H16 H8 I11 I15
                          I17 J12 J16 K11 K13 K17 K9 L10 L16 L8 M17 M9 N6
                          O15 O9 P14 Q7 S15 U11 W9 X12 Y17 Z10 Z26],
                count: 1,
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
                closed_when_used_up: true,
              },
            ],
          },
          {
            name: 'P14 (Free Toronto Upgrades)',
            sym: 'P14',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Ontario, Simcoe & Huron Union Railroad. Owner pays no '\
                  'upgrade fee or terrain costs for tile lays and upgrades to Toronto (AC21). This is in '\
                  'addition to the company’s normal tile placement(s), but happens during the '\
                  'company’s tile laying step. Does not close. Minor may place yellow or green '\
                  'only. The company upgrading the city must be connected to it in order to '\
                  'exercise the private company.',
            abilities: [
              {
                hexes: %w[AC21],
                tiles: %w[T1 T2 T3 T4 T5 T6 T7],
                type: 'tile_lay',
                when: %w[track special_track],
                owner_type: 'corporation',
                free: true,
                special: false,
                count_per_or: 1,
                reachable: true,
              },
            ],
          },
          {
            name: 'P15 (Free Ottawa Upgrades)',
            sym: 'P15',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Pontiac Pacific Junction Railway. Owner pays no upgrade '\
                  'fee or terrain costs for tile lays and upgrades to Ottawa (AE15). This is in addition '\
                  'to the company’s normal tile placement(s), but happens during the company’s '\
                  'tile laying step. Does not close. Minor may place yellow or green only. The '\
                  'company upgrading the city must be connected to it in order to exercise the '\
                  'private company.',
            abilities: [
              {
                hexes: %w[AE15],
                tiles: %w[O1 O2 O3 O4 O5 O6 O7 O8],
                type: 'tile_lay',
                when: %w[track special_track],
                owner_type: 'corporation',
                free: true,
                special: false,
                count_per_or: 1,
                reachable: true,
              },
            ],
          },
          {
            name: 'P16 (Free Montréal Upgrades)',
            sym: 'P16',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. South Eastern Railway. Owner pays no upgrade fee or '\
                  'terrain costs for tile lays and upgrades to Montréal (AF12). This is in addition to the '\
                  'company’s normal tile placement(s), but happens during the company’s tile '\
                  'laying step. Does not close. Minor may place yellow or green only. The company '\
                  'upgrading the city must be connected to it in order to exercise the private '\
                  'company.',
            abilities: [
              {
                hexes: %w[AF12],
                tiles: %w[M1 M2 M3 M4 M5 M6 M7 M8],
                type: 'tile_lay',
                when: %w[track special_track],
                owner_type: 'corporation',
                free: true,
                special: false,
                count_per_or: 1,
                reachable: true,
              },
            ],
          },
          {
            name: 'P17 (Free Québec Upgrades)',
            sym: 'P17',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Québec & Richmond Railway. Owner pays no upgrade fee or '\
                  'terrain costs for tile lays and upgrades to Québec (AH8). This is in addition to the '\
                  'company’s normal tile placement(s), but happens during the company’s tile '\
                  'laying step. Does not close. Minor may place yellow or green only. The company '\
                  'upgrading the city must be connected to it in order to exercise the private '\
                  'company.',
            abilities: [
              {
                hexes: %w[AH8],
                tiles: %w[Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8],
                type: 'tile_lay',
                when: %w[track special_track],
                owner_type: 'corporation',
                free: true,
                special: false,
                count_per_or: 1,
                reachable: true,
              },
            ],
          },
          {
            name: 'P18 (Free Winnipeg Upgrades)',
            sym: 'P18',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Winnipeg & Prince Albert Railway. Owner pays no upgrade '\
                  'fee or terrain costs for tile lays and upgrades to Winnipeg (N16). This is in addition '\
                  'to the company’s normal tile placement(s), but happens during the company’s '\
                  'tile laying step. Does not close. Minor may place yellow or green only. The '\
                  'company upgrading the city must be connected to it in order to exercise the '\
                  'private company.',
            abilities: [
              {
                hexes: %w[N16],
                tiles: %w[W1 W2 W3 W4 W5 W6 W7],
                type: 'tile_lay',
                when: %w[track special_track],
                owner_type: 'corporation',
                free: true,
                special: false,
                count_per_or: 1,
                reachable: true,
              },
            ],
          },
          {
            name: 'P19 (Crowsnest Pass Tile)',
            sym: 'P19',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. The Crowsnest Pass. Allows the owning company to place a tile '\
                  'into the Crowsnest Pass (F16) and ignore the terrain fee. This tile placement '\
                  'counts as the company’s full track laying step. Closed when used. The CP hex is '\
                  'not reserved; any company may pay to lay a tile there irrespective of the '\
                  'ownership of P19.',
            abilities: [
              {
                hexes: %w[F16],
                tiles: %w[7 8 9],
                type: 'tile_lay',
                when: %w[track special_track],
                owner_type: 'corporation',
                free: true,
                special: false,
                count: 1,
                reachable: true,
                consume_tile_lay: true,
                closed_when_used_up: true,
              },
            ],
          },
          {
            name: 'P20 (Yellowhead Pass Tile)',
            sym: 'P20',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. The Yellowhead Pass. Allows the owning company to place a tile '\
                  'into the Yellowhead Pass (E11) and ignore the terrain fee. This tile placement '\
                  'counts as the company’s full track laying step. Closed when used. The YP hex is '\
                  'not reserved; any company may pay to lay a tile there irrespective of the '\
                  'ownership of P20.',
            abilities: [
              {
                hexes: %w[E11],
                tiles: %w[7 8 9],
                type: 'tile_lay',
                when: %w[track special_track],
                owner_type: 'corporation',
                free: true,
                special: false,
                count: 1,
                reachable: true,
                consume_tile_lay: true,
                closed_when_used_up: true,
              },
            ],
          },
          {
            name: 'P21 (3-Tile Grant)',
            sym: 'P21',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. The National Dream. The owning company may close this company '\
                  'to place three yellow tiles in addition to its normal track lay. The owning '\
                  'company’s normal track lay and each of the three extra yellow tile lays may be '\
                  'done in any order. These lays are exempt from terrain fees, but may not be used '\
                  'to build on hexes with mountainous terrain costing $120 or in Montréal, Ottawa, '\
                  'Québec, Toronto or Winnipeg.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: %w[track special_track],
                must_lay_together: false,
                count: 3,
                reachable: true,
                closed_when_used_up: true,
                special: false,
                free: true,
                tiles: %w[1 2 3 4 5 6 7 8 9 55 56 57 58 69 201 202 621 630 631 632 633],
                hexes: %w[A7 A9 B6 B8 B10 B12 B14 C7 C9 C11 C13 D6 D8 D10 D12
                          D14 D16 E7 E9 E15 F6 F8 F10 F12 G7 G9 G11 G13 G17 G15
                          H6 H8 H10 H12 H14 H16 I7 I9 I11 I13 I15 I17 J6 J8 J10
                          J12 J14 J16 K7 K9 K11 K13 K15 K17 L6 L8 L10 L12 L14
                          L16 M7 M9 M11 M13 M15 M17 N6 N8 N10 N12 N14 N18 O7 O9
                          O11 O13 O15 O17 P8 P10 P12 P14 P16 Q7 Q9 Q11 Q13 Q15
                          Q17 R8 R10 R12 R14 R16 S9 S11 S13 S15 U9 U11 U13 U15
                          U17 V8 V10 V12 V14 V16 V18 W7 W9 W11 W13 W15 W17 W19
                          X8 X10 X12 X14 X16 X18 Y7 Y9 Y11 Y13 Y15 Y17 Z8 Z10
                          Z12 Z14 Z16 Z18 Z22 Z24 Z26 Z28 AA7 AA9 AA11 AA13 AA15
                          AA17 AA19 AA21 AA23 AA25 AA27 AB8 AB10 AB12 AB14 AB16
                          AB18 AB20 AB22 AB24 AC7 AC9 AC11 AC13 AC15 AC17 AC19
                          AD8 AD10 AD12 AD14 AD16 AD18 AD20 AE7 AE9 AE11 AE13
                          AE17 AE19 AF6 AF8 AF10 AF14 AF16 AG3 AG5 AG7 AG9 AG11
                          AG13 AG15 AH2 AH4 AH6 AH10 AH12 AH14 AI3 AI5 AI7 AI9
                          AI11 AI13 AJ2 AJ4 AJ6 AJ8 AJ10 AJ12 AK3 AK5 AK7 AK9
                          AK11 AL2 AL4 AL6 AL8 AL10 AM3 AM5 AM7 AM9 AN2 AN4 AN6
                          AO3 AO5 AO7 AO9 AP2 AP6 AP8],
              },
            ],
          },
          {
            name: 'P22 (Large Mail Contract)',
            sym: 'P22',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. National Mail Service. After running trains, the owning company '\
                  'receives income into its treasury equal to one half of the base value of the '\
                  'start and end stations from one of the trains operated. Doubled values (for E '\
                  'trains or destination tokens) do not count. The company is not required to '\
                  'maximise the dividend from its run if it wishes to maximise its revenue from '\
                  'the mail contract by stopping at a large city and not running beyond it to '\
                  'include towns. A company may own multiple Large Mail Contracts, but may only '\
                  'use one per train. Does not close.',
            abilities: [],
          },
          {
            name: 'P23 (Large Mail Contract)',
            sym: 'P23',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. National Mail Service. After running trains, the owning company '\
                  'receives income into its treasury equal to one half of the base value of the '\
                  'start and end stations from one of the trains operated. Doubled values (for E '\
                  'trains or destination tokens) do not count. The company is not required to '\
                  'maximise the dividend from its run if it wishes to maximise its revenue from '\
                  'the mail contract by stopping at a large city and not running beyond it to '\
                  'include towns. A company may own multiple Large Mail Contracts, but may only '\
                  'use one per train. Does not close.',
            abilities: [],
          },
          {
            name: 'P24 (Small Mail Contract)',
            sym: 'P24',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Regional Mail Service. Pay phase-based rate of $10 (yellow)/$'\
                  '20 (green)/$30 (brown)/$40 (grey) to the treasury of the company. The company '\
                  'must operate a train to claim the mail income. Does not close.',
            abilities: [],
          },
          {
            name: 'P25 (Small Mail Contract)',
            sym: 'P25',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Regional Mail Service. Pay phase-based rate of $10 (yellow)/$'\
                  '20 (green)/$30 (brown)/$40 (grey) to the treasury of the company. The company '\
                  'must operate a train to claim the mail income. Does not close.',
            abilities: [],
          },
          {
            name: 'P26 (Grain Train)',
            sym: 'P26',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Saskatchewan Wheat Pool. A grain train can be added to a train '\
                  'owned by the company. It converts the train into a grain train, which can '\
                  'deliver grain from the grain elevators to a port city. Does not count against '\
                  'the train limit and does not count as a train for the purposes of train '\
                  'ownership. Does not close. Cannot be sold to another company. Adds $10 to '\
                  'company revenue for each grain elevator on the run. Does not count the town '\
                  'revenue. Towns with grain elevators do not count as stops. Runs may extend '\
                  'beyond the start and end city. If the route run by the grain train '\
                  'includes at least one grain elevator and a port city, the port city adds $20 to '\
                  'the run revenue.',
            abilities: [],
          },
          {
            name: 'P27 (Grain Train)',
            sym: 'P27',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Alberta Wheat Pool. A grain train can be added to a train owned '\
                  'by the company. It converts the train into a grain train, which can deliver '\
                  'grain from the grain elevators to a port city. Does not count against the train '\
                  'limit and does not count as a train for the purposes of train ownership. Does '\
                  'not close. Cannot be sold to another company. Adds $10 to company revenue for '\
                  'each grain elevator on the run. Does not count the town revenue. Towns with '\
                  'grain elevators do not count as stops. Runs may extend beyond the start and end '\
                  'city. If the route run by the grain train includes at least one grain '\
                  'elevator and a port city, the port city adds $20 to the run revenue.',
            abilities: [],
          },
          {
            name: 'P28 (Station Token Swap)',
            sym: 'P28',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Great Southern Railway. Allows the owning company to move '\
                  'a token from the exchange token area of its charter to the available token '\
                  'area, or vice versa. This company closes when its power is exercised.',
            abilities: [],
          },
          {
            name: 'P29 (Remove Single Town)',
            sym: 'P29',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Charles Melville Hays. Allows the owning company to place '\
                  'a plain yellow track tile directly on an undeveloped single town hex location '\
                  'or upgrade a single town tile of one colour to a plain track tile of the next '\
                  'colour. This closes the company and counts as the company’s normal track laying '\
                  'step. All other normal track laying restrictions apply. Once acquired, the '\
                  'private company pays its revenue to the owning company until the power is '\
                  'exercised and the company is closed. May be used in conjunction with P12 '\
                  'as part of the same tile placement step. May not be used to remove a town '\
                  'with a sawmill token (placed by P13).',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: %w[track special_track],
                count: 1,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: %w[7 8 9 80 81 82 83 544 545 546 60 169],
                combo_entities: %w[P12],
                consume_tile_lay: true,
              },

            ],
          },
          {
            name: 'P30 (Remove Single Town)',
            sym: 'P30',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Sir William Cornelius Van Horne. Allows the owning '\
                  'company to place a plain yellow track tile directly on an undeveloped single '\
                  'town hex location or upgrade a single town tile of one colour to a plain track '\
                  'tile of the next colour. This closes the company and counts as the company’s '\
                  'normal track laying step. All other normal track laying restrictions apply. '\
                  'Once acquired, the private company pays its revenue to the owning company until '\
                  'the power is exercised and the company is closed. May be used in conjunction '\
                  'with P12 as part of the same tile placement step. May not be used to '\
                  'remove a town with a sawmill token (placed by P13).',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: %w[track special_track],
                count: 1,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: %w[7 8 9 80 81 82 83 544 545 546 60 169],
                combo_entities: %w[P12],
                consume_tile_lay: true,
              },

            ],
          },
          {
            name: 'CONCESSION: CNoR',
            sym: 'C1',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the CNoR director’s '\
                  'certificate. Home: Winnipeg (N16). Destination: Vancouver (C15).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['CNoR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#9fce63',
            text_color: 'black',
          },
          {
            name: 'CONCESSION: CPR',
            sym: 'C2',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and converts into the CPR’s 10% director certificate. CPR may also put '\
                  'its destination token into Vancouver when converted. Home: Montréal (AF12). Destination: Vancouver (C15).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['CPR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#ed242a',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: GNWR',
            sym: 'C3',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the GNWR director’s '\
                  'certificate. Home: Thunder Bay (R16). Destination: N Winnipeg (N16).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['GNWR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#8dd8f8',
            text_color: 'black',
          },
          {
            name: 'CONCESSION: GT',
            sym: 'C4',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the GT director’s '\
                  'certificate. Home: Toronto (AC21). Destination: S Montréal (AF12).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['GT'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#000000',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: GTP',
            sym: 'C5',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the GTP director’s '\
                  'certificate. Home: Winnipeg (N16). Destination: Prince Rupert (A7).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['GTP'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#f47d20',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: GWR',
            sym: 'C6',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the GWR director’s '\
                  'certificate. Home: Hamilton (AB24). Destination: Windsor (Z28).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['GWR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#395aa8',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: ICR',
            sym: 'C7',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the ICR director’s '\
                  'certificate. Home: Halifax (AP4). Destination: Any Québec (AH8).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['ICR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#eee91e',
            text_color: 'black',
          },
          {
            name: 'CONCESSION: NTR',
            sym: 'C8',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the NTR director’s '\
                  'certificate. Home: Moncton (AO3). Destination: SE Winnipeg (N16).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['NTR'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#9a6733',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: PGE',
            sym: 'C9',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the PGE director’s '\
                  'certificate. Home: Vancouver (C15). Destination: Prince George (D10).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['PGE'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#199d4a',
            text_color: 'white',
          },
          {
            name: 'CONCESSION: QMOO',
            sym: 'C10',
            value: 100,
            revenue: 10,
            desc: 'Has a face value of $100 and contributes $100 to conversion into the QMOO director’s '\
                  'certificate. Home: Québec (AH8). Destination: North Bay (AA15).',
            abilities: [
              {
                type: 'exchange',
                corporations: ['QMOO'],
                owner_type: 'player',
                from: 'par',
              },
            ],
            color: '#7f3881',
            text_color: 'white',
          },
          {
            name: 'MINOR: 1. Dominion Atlantic Railway',
            sym: 'M1',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AP4 (Halifax).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 2. European & North American Railway',
            sym: 'M2',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AN6 (Saint John).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 3. Québec & New Brunswick Railway',
            sym: 'M3',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AK3 (Edmunston).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 4. Québec Central Railway',
            sym: 'M4',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AH12 (Sherbrooke).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 5. North Shore Railway',
            sym: 'M5',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AH8 (Québec).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 6. Champlain & St Lawrence Railroad',
            sym: 'M6',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AG13 (Saint Jean & La ' \
                  'Prairie).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 7. Montréal & Lachine Railway',
            sym: 'M7',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AF12 (Montréal).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 8. Bytown & Prescott Railway',
            sym: 'M8',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AE15 (Bytown Ottawa).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 9. Canada Atlantic Railway',
            sym: 'M9',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AE15 (Bytown Ottawa).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 10. Midland Railway',
            sym: 'M10',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AD20 (Peterborough).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 11. Canada Southern Railway',
            sym: 'M11',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AC23 (Buffalo).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 12. Toronto, Hamilton & Buffalo Railway',
            sym: 'M12',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AC21 (Toronto).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 13. Ontario & Québec Railway',
            sym: 'M13',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AC21 (Toronto). Home '\
                  'token cost $20, placing home token counts as first tile lay.',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 14. London & Port Stanley Railway',
            sym: 'M14',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AA25 (London).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 15. Lake Nipissing & James’ Bay Railway',
            sym: 'M15',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is AA15 (North Bay).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 16. Windsor, Chatham & London Railway',
            sym: 'M16',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is Z28 (Windsor).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 17. Canada Central Railway',
            sym: 'M17',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is Y15 (Sudbury).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 18. Ontario & Abitibi Railway',
            sym: 'M18',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is X12 (Timmins).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 19. Algoma Central Railway',
            sym: 'M19',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is V18 (Sault Ste Marie).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 20. Port Arthur, Duluth & Western Railway',
            sym: 'M20',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is P18 (Duluth).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 21. Winnipeg & Atlantic Railway',
            sym: 'M21',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is N16 (Winnipeg).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 22. Winnipeg & Hudson’s Bay Railway',
            sym: 'M22',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is N6 (Churchill).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 23. Prince Albert & North Saskatchewan Railway',
            sym: 'M23',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is K11 (Prince Albert).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 24. Saskatoon & Northern Railway',
            sym: 'M24',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is J12 (Saskatoon).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 25. Northern Empire Railway',
            sym: 'M25',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is G17 (Lethbridge).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 26. Calgary & Fort McMurray Railway',
            sym: 'M26',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is G15 (Calgary).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 27. Athabaska Northern Railway',
            sym: 'M27',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is G11 (Edmonton).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 28. Kamloops & Yellow Head Pass Railway',
            sym: 'M28',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is D14 (Kamloops).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 29. Kootenay, Cariboo & Pacific Railway',
            sym: 'M29',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is D10 (Prince George).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 30. Pacific Northern & Omineca Railway',
            sym: 'M30',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in the associated minor company. Starting location is A7 (Prince Rupert).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: '1',
            name: 'Dominion Atlantic Railway',
            logo: '1822_ca/1',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AP4',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '2',
            name: 'European & North American Railway',
            logo: '1822_ca/2',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AN6',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '3',
            name: 'Québec & New Brunswick Railway',
            logo: '1822_ca/3',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AK3',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '4',
            name: 'Québec Central Railway',
            logo: '1822_ca/4',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AH12',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '5',
            name: 'North Shore Railway',
            logo: '1822_ca/5',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            city: 0,
            coordinates: 'AH8',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '6',
            name: 'Champlain & St Lawrence Railroad',
            logo: '1822_ca/6',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AG13',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '7',
            name: 'Montréal & Lachine Railway',
            logo: '1822_ca/7',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AF12',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '8',
            name: 'Bytown & Prescott Railway',
            logo: '1822_ca/8',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AE15',
            city: 1,
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '9',
            name: 'Canada Atlantic Railway',
            logo: '1822_ca/9',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AE15',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '10',
            name: 'Midland Railway',
            logo: '1822_ca/10',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AD20',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '11',
            name: 'Canada Southern Railway',
            logo: '1822_ca/11',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AC23',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '12',
            name: 'Toronto, Hamilton & Buffalo Railway',
            logo: '1822_ca/12',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AC21',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '13',
            name: 'Ontario & Québec Railway',
            logo: '1822_ca/13',
            tokens: [20],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            color: '#ffffff',
            text_color: 'black',
            coordinates: 'AC21',
          },
          {
            sym: '14',
            name: 'London & Port Stanley Railway',
            logo: '1822_ca/14',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AA25',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '15',
            name: 'Lake Nipissing & James’ Bay Railway',
            logo: '1822_ca/15',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'AA15',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '16',
            name: 'Windsor, Chatham & London Railway',
            logo: '1822_ca/16',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'Z28',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '17',
            name: 'Canada Central Railway',
            logo: '1822_ca/17',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'Y15',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '18',
            name: 'Ontario & Abitibi Railway',
            logo: '1822_ca/18',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'X12',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '19',
            name: 'Algoma Central Railway',
            logo: '1822_ca/19',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'V18',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '20',
            name: 'Port Arthur, Duluth & Western Railway',
            logo: '1822_ca/20',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'P18',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '21',
            name: 'Winnipeg & Atlantic Railway',
            logo: '1822_ca/21',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'N16',
            city: 2,
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '22',
            name: 'Winnipeg & Hudson’s Bay Railway',
            logo: '1822_ca/22',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'N6',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '23',
            name: 'Prince Albert & North Saskatchewan Railway',
            logo: '1822_ca/23',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'K11',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '24',
            name: 'Saskatoon & Northern Railway',
            logo: '1822_ca/24',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'J12',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '25',
            name: 'Northern Empire Railway',
            logo: '1822_ca/25',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'G17',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '26',
            name: 'Calgary & Fort McMurray Railway',
            logo: '1822_ca/26',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'G15',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '27',
            name: 'Athabaska Northern Railway',
            logo: '1822_ca/27',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'G11',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '28',
            name: 'Kamloops & Yellow Head Pass Railway',
            logo: '1822_ca/28',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'D14',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '29',
            name: 'Kootenay, Cariboo & Pacific Railway',
            logo: '1822_ca/29',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'D10',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: '30',
            name: 'Pacific Northern & Omineca Railway',
            logo: '1822_ca/30',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'A7',
            color: '#ffffff',
            text_color: 'black',
          },
          {
            sym: 'CNoR',
            name: 'Canadian Northern Railway',
            logo: '1822_ca/CNoR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'N16',
            city: 0,
            color: '#9fce63',
            text_color: 'black',
            destination_coordinates: 'C15',
            destination_icon: '1822_ca/CNoR_DEST',
            destination_icon_in_city_slot: [0, 3],
          },
          {
            sym: 'CPR',
            name: 'Canadian Pacific Railway',
            logo: '1822_ca/CPR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 10,
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            always_market_price: true,
            coordinates: 'AF12',
            city: 1,
            color: '#ed242a',
            destination_coordinates: 'C15',
            destination_icon: '1822_ca/CPR_DEST',
            destination_icon_in_city_slot: [0, 2],
          },
          {
            sym: 'GNWR',
            name: 'Great North West Railway',
            logo: '1822_ca/GNWR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'R16',
            color: '#8dd8f8',
            text_color: 'black',
            destination_coordinates: 'N16',
            destination_exits: [3],
            destination_icon: '1822_ca/GNWR_DEST',
            destination_icon_in_city_slot: [1, 0],
          },
          {
            sym: 'GT',
            name: 'Grand Trunk Railway',
            logo: '1822_ca/GT',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'AC21',
            city: 1,
            color: '#000000',
            destination_coordinates: 'AF12',
            destination_exits: [0],
            destination_icon: '1822_ca/GT_DEST',
            destination_icon_in_city_slot: [0, 1],
          },
          {
            sym: 'GTP',
            name: 'Grand Trunk Pacific Railway',
            logo: '1822_ca/GTP',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'N16',
            city: 0,
            color: '#f47d20',
            destination_coordinates: 'A7',
            destination_icon: '1822_ca/GTP_DEST',
          },
          {
            sym: 'GWR',
            name: 'Great Western Railway',
            logo: '1822_ca/GWR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'AB24',
            color: '#395aa8',
            destination_coordinates: 'Z28',
            destination_icon: '1822_ca/GWR_DEST',
          },
          {
            sym: 'ICR',
            name: 'Intercolonial Railway',
            logo: '1822_ca/ICR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'AP4',
            color: '#eee91e',
            text_color: 'black',
            destination_coordinates: 'AH8',
            destination_loc: '3.5',
            destination_exits: [0, 1, 2, 3, 4, 5],
            destination_icon: '1822_ca/ICR_DEST',
          },
          {
            sym: 'NTR',
            name: 'National Transcontinental Railway',
            logo: '1822_ca/NTR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'AO3',
            color: '#9a6733',
            destination_coordinates: 'N16',
            destination_exits: [5],
            destination_icon: '1822_ca/NTR_DEST',
            destination_icon_in_city_slot: [3, 0],
          },
          {
            sym: 'PGE',
            name: 'Pacific Great Eastern Railway',
            logo: '1822_ca/PGE',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'C15',
            color: '#199d4a',
            destination_coordinates: 'D10',
            destination_icon: '1822_ca/PGE_DEST',
          },
          {
            sym: 'QMOO',
            name: 'Québec, Montréal, Ottawa and Occidental Railway',
            logo: '1822_ca/QMOO',
            tokens: [0, 100],
            type: 'major',
            float_percent: 20,
            always_market_price: true,
            coordinates: 'AH8',
            city: 1,
            color: '#7f3881',
            destination_coordinates: 'AA15',
            destination_icon: '1822_ca/QMOO_DEST',
          },
        ].freeze
      end
    end
  end
end
