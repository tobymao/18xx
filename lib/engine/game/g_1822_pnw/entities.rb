# frozen_string_literal: true

module Engine
  module Game
    module G1822PNW
      module Entities
        COMPANIES = [
          {
            name: 'P1-The Olympian Hiawatha (5-Train)',
            sym: 'P1',
            value: 0,
            revenue: 5,
            desc: 'MAJOR, Phase 5. 5-Train. Once a company acquires it, this is a normal 5-train that is subject to '\
                  'all of the normal rules.  It is not a "special train" and is not subject to the rules that are '\
                  'specific to special trains.  A company can acquire this private company at the start of its turn, '\
                  'even if it is already at it\'s train limit, as this counts as an acquisition action, not a train '\
                  'buying action.  However, once acquired the acquiring company must check whether it as at the '\
                  'train limit and must discard any trains held in excess of limit.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P2-J.S. Ruckle OSNC 4-4-0 (Permanent 2T)',
            sym: 'P2',
            value: 0,
            revenue: 0,
            desc: 'MAJOR, Phase 2. Permanent 2-Train. The 2P-train is a permanent 2-train. It is a “special train.” '\
                  'It cannot be sold to another company. It does not count against the train limit. '\
                  'It does not count as a train for the purpose of mandatory train ownership and '\
                  'purchase. A company cannot own more than one special train. Dividends can '\
                  'be separated from other trains and may be split, paid in full, or retained. If '\
                  'a company runs a 2P-train and pays a dividend (split or full), but retains its '\
                  'dividend from other train operations, this still counts as a normal dividend '\
                  'for share price movement purposes. Vice-versa, if a company pays a dividend '\
                  '(split or full) with its other trains, but retains the dividend from the 2P-train, '\
                  'this also still counts as a normal dividend for share price movement purposes. '\
                  'Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P3-Portland Streetcar (Permanent LT)',
            sym: 'P3',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 1. Permanent L-Train.  It is a “special train.” '\
                  'It cannot be sold to another company. It does not count against the train limit. '\
                  'It does not count as a train for the purpose of mandatory train ownership and '\
                  'purchase. A company cannot own more than one special train. Dividends can '\
                  'be separated from other trains and may be split, paid in full, or retained. If '\
                  'a company runs a LP-train and pays a dividend (split or full), but retains its '\
                  'dividend from other train operations, this still counts as a normal dividend '\
                  'for share price movement purposes. Vice-versa, if a company pays a dividend '\
                  '(split or full) with its other trains, but retains the dividend from the LP-train, '\
                  'this also still counts as a normal dividend for share price movement purposes. '\
                  'Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P4-South Lake Union Trolley (Permanent LT)',
            sym: 'P4',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 1. Permanent L-Train.  It is a “special train.” '\
                  'It cannot be sold to another company. It does not count against the train limit. '\
                  'It does not count as a train for the purpose of mandatory train ownership and '\
                  'purchase. A company cannot own more than one special train. Dividends can '\
                  'be separated from other trains and may be split, paid in full, or retained. If '\
                  'a company runs a LP-train and pays a dividend (split or full), but retains its '\
                  'dividend from other train operations, this still counts as a normal dividend '\
                  'for share price movement purposes. Vice-versa, if a company pays a dividend '\
                  '(split or full) with its other trains, but retains the dividend from the LP-train, '\
                  'this also still counts as a normal dividend for share price movement purposes. '\
                  'Does not close.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P5-Pullman (Pullman)',
            sym: 'P5',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Pullman. A “Pullman” car that can be attached to another train owned by the '\
                  'company. It is not a train. A train with a Pullman attached to it counts any '\
                  'number of towns in addition to its standard number of large stations. Does '\
                  'not count toward the train limit. Cannot be sold to another company. Does '\
                  'not close. No company may own more than one Pullman.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P6-Pullman (Pullman)',
            sym: 'P6',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Pullman. A “Pullman” car that can be attached to another train owned by the '\
                  'company. It is not a train. A train with a Pullman attached to it counts any '\
                  'number of towns in addition to its standard number of large stations. Does '\
                  'not count toward the train limit. Cannot be sold to another company. Does '\
                  'not close. No company may own more than one Pullman.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P7-Dit Crusher (Remove Town)',
            sym: 'P7',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Remove Town. Allows the owning company to place a plain yellow track '\
                  'tile directly on an undeveloped town hex location or upgrade a town tile '\
                  'of one color to a plain track tile of the next color. This closes the company '\
                  'and counts as the company’s normal track laying step. All other normal '\
                  'track laying restrictions apply. Cannot be used in hexes with two small '\
                  'towns. Once acquired, the private company pays its revenue to the owning '\
                  'company until the power is exercised and the company is closed.',
            abilities: [
            {
              type: 'tile_lay',
              owner_type: 'corporation',
              when: 'track',
              count: 1,
              reachable: true,
              closed_when_used_up: true,
              hexes: [],
              tiles: %w[7 8 9 80 81 82 83 544 545 546 60 169],
            },
            ],
            color: nil,
          },
          {
            name: 'P8-Dit Crusher (Remove Town)',
            sym: 'P8',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Remove Town. Allows the owning company to place a plain yellow track '\
                  'tile directly on an undeveloped town hex location or upgrade a town tile '\
                  'of one color to a plain track tile of the next color. This closes the company '\
                  'and counts as the company’s normal track laying step. All other normal '\
                  'track laying restrictions apply. Cannot be used in hexes with two small '\
                  'towns. Once acquired, the private company pays its revenue to the owning '\
                  'company until the power is exercised and the company is closed.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: %w[7 8 9 80 81 82 83 544 545 546 60 169],
              },
            ],
            color: nil,
          },
          {
            name: 'P9-USPS Mail Service (Mail Contract)',
            sym: 'P9',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Mail Contract. After running trains, the owning company receives income '\
                  'into its treasury equal to one half of the base value of the start and end '\
                  'stations from one of the trains operated. Modifications to values (for '\
                  'E-trains or destination tokens) do not apply. An L-train may '\
                  'deliver mail within a single city. The company is not required to maximize '\
                  'the dividend from its run if it wishes to maximize its revenue from the mail '\
                  'contract by stopping at a large city and not running beyond it to include '\
                  'towns. A company that owns more than one Mail Contract may not use '\
                  'more than one on any train.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P10-American Bridge Company (Three Builder Cubes)',
            sym: 'P10',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 1. Three Builder Cubes. When acquired by a company, the private company '\
                  'closes and is exchanged for three of the builder cubes from the cube pool. '\
                  'The company may spend one or more of the cubes to place them on the '\
                  'board during their lay track action. These placements are in addition to the '\
                  'tile placement. These cube placements may occur at any time during the '\
                  'action and can be split among turns.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 3,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: [],
              },
            ],
            color: nil,
          },
          {
            name: 'P11-Surveyors (Extra Tile Lay)',
            sym: 'P11',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Extra Tile Lay. The owning company may lay an additional yellow tile (or '\
                  'two for major companies beginning in Phase 3), or make one additional '\
                  'tile upgrade in its track laying step. The upgrade can be to a tile laid in its '\
                  'normal tile laying step. All other normal track laying restrictions apply. Once '\
                  'acquired, the private company pays its revenue to the owning company until '\
                  'the power is exercised and the company closes.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 2,
                reachable: true,
                closed_when_used_up: true,
                hexes: [],
                tiles: [],
              },
            ],
            color: nil,
          },
          {
            name: 'P12-Dock Upgrades (Small Port)',
            sym: 'P12',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 2. Small Port. Replace a spike going to water with this tile. Lay this tile on '\
                  'a spike that does not already have a port. The spike now counts as a 30 '\
                  '(yellow)/40 (green and later) and is treated like a gray off-board area for '\
                  'counting train runs for all companies. This is in addition to the company’s '\
                  'normal tile placement and the company does not need a route to the '\
                  'spike. Once acquired, the private company pays its revenue to the owning '\
                  'company until the power is exercised and the company is closed.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                closed_when_used_up: true,
                hexes: %w[B7 D9 E8 I10 M2 N9],
                tiles: %w[P1],
                cost: 0,
                consume_tile_lay: false,
              },
            ],
            color: nil,
          },
          {
            name: 'P13-Harbor Improvements (Large Port)',
            sym: 'P13',
            value: 0,
            revenue: 10,
            desc: 'MAJOR, Phase 3. Replace a spike going to water with this tile. Lay this tile on '\
                  'a spike that does not already have a port. The spike now counts as a 40 '\
                  '(green)/50 (brown)/60 (gray) and is treated like a gray off-board area for '\
                  'counting train runs for all companies. This is in addition to the company’s '\
                  'normal tile placement and the company does not need a route to the '\
                  'spike. Once acquired, the private company pays its revenue to the owning '\
                  'company until the power is exercised and the company is closed.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                closed_when_used_up: true,
                hexes: %w[B7 D9 E8 I10 M2 N9],
                tiles: %w[P2],
                cost: 0,
                consume_tile_lay: false,
              },
            ],
            color: nil,
          },
          {
            name: 'P14-Lumber Baron (2x Timber Value)',
            sym: 'P14',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. The Lumber Baron private increases '\
                  'the payout of each timber track traversed by a single '\
                  'train from $10 to $20. Maintains all of the timber trade '\
                  'connection requirements. Once acquired by a company '\
                  'this private no longer pays its revenue.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P15-Paper Mill (City Revenue)',
            sym: 'P15',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Close this private to place the '\
                  'special Paper Mill token on any city tile that is '\
                  'connected to an adjacent Timber hex. The Paper Mill '\
                  'token adds $10 to a single train starting in phase 3 and '\
                  '$30 starting in phase 5. Can be used with E-train and '\
                  'Mail Contract.',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[D11 D19 F9 F13 G14 G16 H19 H21 J5 L11 L19 N5 O14],
                count: 1,
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
                closed_when_used_up: true,
              },
            ],
            color: nil,
          },
          {
            name: 'P16-Pacific Portage Company (Special Tile Placement)',
            sym: 'P16',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 2. Use this private to place '\
                  'one or both special tiles (PNW1, PNW2) in any blue '\
                  'water hex on the map. This tile lay replaces a '\
                  'company\'s normal tile lay. The owning company may '\
                  'run a train across the special tiles for free. If any other '\
                  'train company uses the tiles, they subtract $10 from '\
                  'their run for each special tile crossed. The owning '\
                  'company receives $10 per special track used from the '\
                  'bank. Once used, this private no longer pays revenue '\
                  'to the company.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 2,
                reachable: false,
                closed_when_used_up: false,
                hexes: %w[E10 F11 G10 H9 I10 M6 M8 N9 O16 O18],
                tiles: %w[PNW1 PNW2],
              },
            ],
            color: nil,
          },
          {
            name: 'P17-Ski Haus (Route Enhancement)',
            sym: 'P17',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 5. Close this private to place '\
                  'the special Ski Haus token on any piece of track laid '\
                  'over a mountain pass hex. This token provides an '\
                  'additional $30 to a route that runs through this hex. A '\
                  'mountain pass hex is any hex that includes the '\
                  'mountain symbol AND a build cost. Revenue is NOT '\
                  'added to an E-train.',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[A16 G4 G18 H5 I6 J17 M14 N13],
                count: 1,
                owner_type: 'corporation',
                when: 'owning_corp_or_turn',
                closed_when_used_up: true,
              },
            ],
            color: nil,
          },
          {
            name: 'P18-Boom Town (Special Tile Upgrade)',
            sym: 'P18',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Close this private to upgrade '\
                  'any plain yellow track tile to the special $30 boom town tile '\
                  '(PNW3). This tile ignores any tile\'s normal tile '\
                  'placement restrictions.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                closed_when_used_up: true,
                hexes: [],
                tiles: %w[PNW3],
              },
            ],
            color: nil,
          },
          {
            name: 'P19-Rockport Coal Mine (Special Tile Placement)',
            sym: 'P19',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 3. Use this private to use a yellow track '\
                  'placement to place the Rockport Coal special tile (PNW4) in '\
                  'any mountain hex. The owning company must be able to trace to '\
                  'the hex the mine is placed on. Only the owning company can run a '\
                  'train through the city spot on the Rockport Coal special tile '\
                  '(PNW4). Any company can pay the upgrade cost or use '\
                  'building cubes to upgrade the Rockport Coal Special tile '\
                  '(PNW4) to include the pass around route tile (PNW5). No '\
                  'other private bonus can combine with this one. Once '\
                  'used, this private no longer pays revenue to the '\
                  'company.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                closed_when_used_up: false,
                hexes: %w[B15 C14 D15 E16 F17 H17 I18 K16 L15],
                tiles: %w[PNW4],
              },
            ],
            color: nil,
          },
          {
            name: 'P20-Backroom Negotiations (Minor Status Upgrade)',
            sym: 'P20',
            value: 0,
            revenue: 0,
            desc: 'MAJOR/MINOR, Phase 1. When this private is '\
                  'acquired by a non-associated minor company, choose an '\
                  'associated minor company that is currently not operational '\
                  'or in an auction box. That minor is removed from the game '\
                  'and the minor that owns this private becomes the '\
                  'associated minor for the major associated with the '\
                  'discarded minor. The owning minor must still abide by all '\
                  'merge requirements when forming the associated major '\
                  'company and its location becomes the major’s new home '\
                  'token location.',
            abilities: [],
            color: nil,
          },
          {
            name: 'P21-Credit Mobilier (Move Card/Exchange Token)',
            sym: 'P21',
            value: 0,
            revenue: 10,
            desc: 'MAJOR/MINOR, Phase 2. Allows the director of the '\
                  'owning company to select one private company or minor '\
                  'company from the relevant stack of certificates, excluding '\
                  'those items currently in the bidding boxes, and move it to '\
                  'the top or the bottom of the stack OR allows the director of '\
                  'a major company to move a station token from exchange to '\
                  'available. Closes when the power is exercised.',
            abilities: [],
            color: nil,
          },
          {
            name: 'MINOR: 1. Pacific Great Eastern Railway',
            sym: 'M1',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. '\
                  'Associated with the Canadian Pacific Railway (CPR). Starting location is A8 (Vancouver, BC).',
            abilities: [],
            color: '#EF1D24',
            text_color: 'white',
          },
          {
            name: 'MINOR: 2. Spokane & British Columbia Railway',
            sym: 'M2',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is B19 (Republic).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 3. Bellingham Bay & British Columbia Railroad',
            sym: 'M3',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is D11 (Bellingham).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 4. Brewster & Davenport Railroad',
            sym: 'M4',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is D19 (Brewster).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 5. Idaho & Washington Northern Railway',
            sym: 'M5',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. '\
                  'Associated with the Great Northern Railway (GNR). Starting location is D23 (Newport).',
            abilities: [],
            color: '#6BCFF7',
            text_color: 'white',
          },
          {
            name: 'MINOR: 6. Port Townsend and Southern Railroad',
            sym: 'M6',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is F9 (Port Townsend).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 7. Spokane Falls and Northern Railway',
            sym: 'M7',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. '\
                  'Associated with the Chicago, Milwaukee, & Puget Sound Railway (CMPS). Starting location is F23 (Spokane).',
            abilities: [],
            color: '#F69B1D',
            text_color: 'white',
          },
          {
            name: 'MINOR: 8. Puget Sound Shore Railroad',
            sym: 'M8',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. '\
                  'Associated with the Seattle & Walla Walla Railroad (SWW). Starting location is H11 (Seattle).',
            abilities: [],
            color: '#238541',
            text_color: 'white',
          },
          {
            name: 'MINOR: 9. Wenatchee Valley Railroad',
            sym: 'M9',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is H19 (Leavenworth).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 10. Tacoma, Olympia and Grays Harbor Railroad Company',
            sym: 'M10',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is I12 (Tacoma).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 11. Aberdeen & Oakville Railroad',
            sym: 'M11',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is J5 (Aberdeen).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 12. Connell Northern Railway Company',
            sym: 'M12',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is J23 (Sprague).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 13. North Yakima Valley Railroad',
            sym: 'M13',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is L19 (Yakima).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 14. Camas Prarie Railroad',
            sym: 'M14',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is L23 (Lewiston Junction).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 15. Ilwaco Railroad Company',
            sym: 'M15',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is M4 (Ilwaco).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 16. Astoria and Columbia River Railroad Company',
            sym: 'M16',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is N5 (Astoria).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 17. Oregon Central Railroad',
            sym: 'M17',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. '\
                  'Associated with the Spokane, Portland, & Seattle Railroad (SPS). Starting location is O8 (Portland).',
            abilities: [],
            color: '#8D061B',
            text_color: 'white',
          },
          {
            name: 'MINOR: 18. Portland and Willamette Valley Railway',
            sym: 'M18',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. '\
                  'Associated with the Oregon Railroad & Navigation Co. (ORNC). Starting location is O8 (Portland).',
            abilities: [],
            color: '#3078C1',
            text_color: 'white',
          },
          {
            name: 'MINOR: 19. Cascade Portage Railway',
            sym: 'M19',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. '\
                  'Starting location is O14 (Stevenson Cascade Locks).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'MINOR: 20. Walla Walla Valley Railway',
            sym: 'M20',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. '\
                  'Associated with the Northern Pacific Railroad (NP). Starting location is O20 (Wallula).',
            abilities: [],
            color: '#221E20',
            text_color: 'white',
          },
          {
            name: 'MINOR: 21. The Great Southern Railroad',
            sym: 'M21',
            value: 100,
            revenue: 0,
            desc: 'A 50% director’s certificate in this company. Starting location is P17 (The Dalles).',
            abilities: [],
            color: '#ffffff',
            text_color: 'black',
          },
          {
            name: 'REGIONAL: A. Vancouver Regional Railway',
            sym: 'MA',
            value: 100,
            revenue: 10,
            desc: 'Ownership certificate in the Vancouver Regional Railway. Starting location is O10 (Vancouver, WA).',
            abilities: [],
            color: '#808080',
            text_color: 'black',
          },
          {
            name: 'REGIONAL: B. Tacoma Regional Railway',
            sym: 'MB',
            value: 100,
            revenue: 10,
            desc: 'Ownership certificate in the Tacoma Regional Railway. Starting location is I12 (Tacoma).',
            abilities: [],
            color: '#808080',
            text_color: 'black',
          },
          {
            name: 'REGIONAL: C. Calgary Regional Railway',
            sym: 'MC',
            value: 100,
            revenue: 10,
            desc: 'Ownership certificate in the Calgary Regional Railway. Starting location is A22/B23 (Calgary).',
            abilities: [],
            color: '#808080',
            text_color: 'black',
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: '1',
            name: 'Pacific Great Eastern Railway',
            logo: '1822/1',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'A8',
            city: 0,
            color: '#EF1D24',
            text_color: 'white',
            reservation_color: nil,
            abilities: [
              {
                type: 'description',
                description: 'Associated minor for CPR',
              },
            ],
          },
          {
            sym: '2',
            name: 'Spokane & British Columbia Railway',
            logo: '1822/2',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'B19',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '3',
            name: 'Bellingham Bay & British Columbia Railroad',
            logo: '1822/3',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'D11',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '4',
            name: 'Brewster & Davenport Railroad',
            logo: '1822/4',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'D19',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '5',
            name: 'Idaho & Washington Northern Railway',
            logo: '1822/5',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'D23',
            city: 0,
            color: '#6BCFF7',
            text_color: '#white',
            reservation_color: nil,
            abilities: [
              {
                type: 'description',
                description: 'Associated minor for GNR',
              },
            ],
          },
          {
            sym: '6',
            name: 'Port Townsend and Southern Railroad',
            logo: '1822/6',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'F9',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '7',
            name: 'Spokane Falls and Northern Railway',
            logo: '1822/7',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'F23',
            city: 0,
            color: '#F69B1D',
            text_color: '#white',
            reservation_color: nil,
            abilities: [
              {
                type: 'description',
                description: 'Associated minor for CMPS',
              },
            ],
          },
          {
            sym: '8',
            name: 'Puget Sound Shore Railroad',
            logo: '1822/8',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'H11',
            city: 0,
            color: '#238541',
            text_color: '#black',
            reservation_color: nil,
            abilities: [
              {
                type: 'description',
                description: 'Associated minor for SWW',
              },
            ],
          },
          {
            sym: '9',
            name: 'Wenatchee Valley Railroad',
            logo: '1822/9',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'H19',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '10',
            name: 'Tacoma, Olympia and Grays Harbor Railroad Company',
            logo: '1822/10',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'I12',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '11',
            name: 'Aberdeen & Oakville Railroad',
            logo: '1822/11',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'J5',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '12',
            name: 'Connell Northern Railway Company',
            logo: '1822/12',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'J23',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '13',
            name: 'North Yakima Valley Railroad',
            logo: '1822/13',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'L19',
            city: 1,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '14',
            name: 'Camas Prarie Railroad',
            logo: '1822/14',
            tokens: [20],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'L23',
            city: 1,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '15',
            name: 'Ilwaco Railroad Company',
            logo: '1822/15',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'M4',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '16',
            name: 'Astoria and Columbia River Railroad Company',
            logo: '1822/16',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'N5',
            city: 2,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '17',
            name: 'Oregon Central Railroad',
            logo: '1822/17',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'O8',
            city: 0, ## Todo - Check
            color: '#8D061B',
            text_color: '#white',
            reservation_color: nil,
            abilities: [
              {
                type: 'description',
                description: 'Associated minor for SPS',
              },
            ],
          },
          {
            sym: '18',
            name: 'Portland and Willamette Valley Railway',
            logo: '1822/18',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'O8',
            city: 1, ## Todo - Check
            color: '#3078C1',
            text_color: '#white',
            reservation_color: nil,
            abilities: [
              {
                type: 'description',
                description: 'Associated minor for ORNC',
              },
            ],
          },
          {
            sym: '19',
            name: 'Cascade Portage Railway',
            logo: '1822/19',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'O14',
            city: 1,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: '20',
            name: 'Walla Walla Valley Railway',
            logo: '1822/20',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'O20',
            city: 0,
            color: '#221E20',
            text_color: 'white',
            reservation_color: nil,
            abilities: [
              {
                type: 'description',
                description: 'Associated minor for NP',
              },
            ],
          },
          {
            sym: '21',
            name: 'The Great Southern Railroad',
            logo: '1822/21',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'P17',
            city: 0,
            color: '#ffffff',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'A',
            name: 'Vancouver Regional Railway',
            logo: '1822_pnw/a',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'O10',
            city: 0,
            color: '#808080',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            sym: 'B',
            name: 'Tacoma Regional Railway',
            logo: '1822_pnw/b',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'I12',
            city: 0,
            color: '#808080',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            sym: 'C',
            name: 'Calgary Regional Railway',
            logo: '1822_pnw/c',
            tokens: [0],
            type: 'minor',
            always_market_price: true,
            float_percent: 100,
            hide_shares: true,
            shares: [100],
            max_ownership_percent: 100,
            coordinates: 'A22',
            city: 0,
            color: '#808080',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            sym: 'NP',
            name: 'Northern Pacific Railway',
            logo: '1822_pnw/NP',
            tokens: [0, 100],
            type: 'major',
            float_percent: 50,
            always_market_price: true,
            coordinates: 'O20',
            city: 4,
            color: '#221E20',
            reservation_color: nil,
            destination_coordinates: 'I12',
            destination_icon: '1822_pnw/NP_DEST',
          },
          {
            sym: 'CPR',
            name: 'Canadian Pacific Railway',
            logo: '1822_pnw/CPR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 50,
            always_market_price: true,
            coordinates: 'A8',
            city: 2,
            color: '#EF1D24',
            reservation_color: nil,
            destination_coordinates: 'A22',
            destination_icon: '1822_pnw/CPR_DEST',
          },
          {
            sym: 'GNR',
            name: 'Great Northern Railway',
            logo: '1822_pnw/GNR',
            tokens: [0, 100],
            type: 'major',
            float_percent: 50,
            always_market_price: true,
            coordinates: 'D23',
            color: '#6BCFF7',
            text_color: 'black',
            reservation_color: nil,
            destination_coordinates: 'D11',
            destination_icon: '1822_pnw/GNR_DEST',
          },
          {
            sym: 'ORNC',
            name: 'Oregon Railroad and Navigation Company',
            logo: '1822_pnw/ORNC',
            tokens: [0, 100],
            type: 'major',
            float_percent: 50,
            always_market_price: true,
            coordinates: 'O8',
            city: 3,
            color: '#3078C1',
            reservation_color: nil,
            destination_coordinates: 'O20',
            destination_icon: '1822_pnw/ORNC_DEST',
          },
          {
            sym: 'SPS',
            name: 'Spokane, Portland, and Seattle Railway',
            logo: '1822_pnw/SPS',
            tokens: [0, 100],
            type: 'major',
            float_percent: 50,
            always_market_price: true,
            coordinates: 'O8',
            color: '#8D061B',
            reservation_color: nil,
            destination_coordinates: 'F23',
            destination_icon: '1822_pnw/SPS_DEST',
          },
          {
            sym: 'CMPS',
            name: 'Chicago, Milwaukee and Puget Sound',
            logo: '1822_pnw/CMPS',
            tokens: [0, 100],
            type: 'major',
            float_percent: 50,
            always_market_price: true,
            coordinates: 'F23',
            color: '#F69B1D',
            reservation_color: nil,
            destination_coordinates: 'H11',
            destination_icon: '1822_pnw/CMPS_DEST',
          },
          {
            sym: 'SWW',
            name: 'Seattle and Walla Walla Railroad',
            logo: '1822_pnw/SWW',
            tokens: [0, 100],
            type: 'major',
            float_percent: 50,
            always_market_price: true,
            coordinates: 'H11',
            city: 5,
            color: '#238541',
            reservation_color: nil,
            destination_coordinates: 'O22',
            destination_icon: '1822_pnw/SWW_DEST',
          },
        ].freeze

        # Portland and Seattle
        def portland_hex
          @portland_hex ||= hex_by_id('O8')
        end

        def seattle_hex
          @seattle_hex ||= hex_by_id('H11')
        end

        def setup_tokencity_tiles
          @tokencity_tiles = {}
          @tokencity_tiles[portland_hex] = %w[X24 X25 X26 X27].map { |id| tile_by_id("#{id}-0") }
          @tokencity_tiles[seattle_hex] = %w[X20 X21 X22 X23].map { |id| tile_by_id("#{id}-0") }
        end

        def tokencity?(hex)
          @tokencity_tiles.key?(hex)
        end

        def tokencity_tile_index_of(hex, tile)
          @tokencity_tiles[hex].find_index(tile) || -1
        end

        def tokencity_upgrades_to?(from, to)
          from_index = tokencity_tile_index_of(from.hex, from)
          to_index = tokencity_tile_index_of(from.hex, to)
          to_index > from_index
        end

        def tokencity_potential_tiles(hex, tiles)
          return [] if tiles.empty?
          if @tokencity_tiles.keys.any? { |h| h != hex && h.tile.color == tiles[0].color }
            return tiles.size > 1 ? [tiles[1]] : []
          end

          [tiles[0]]
        end

        def tokencity_upgrade_cost(old_tile, hex)
          from_index = tokencity_tile_index_of(hex, old_tile)
          to_index = tokencity_tile_index_of(hex, hex.tile)
          20 * (to_index - from_index)
        end
      end
    end
  end
end
