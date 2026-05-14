# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module Entities
        COMPANIES = [
          # -----------------------------------------------------------------------
          # Row 1 — £20 privates (no special abilities)
          # -----------------------------------------------------------------------
          {
            name: 'Robert Stephenson and Company',
            sym: 'RSC',
            value: 20,
            revenue: 5,
            desc: 'No special abilities. No markers or tokens.',
            auction_row: 1,
          },
          {
            name: 'Ponts et Chaussees',
            sym: 'PeC',
            value: 20,
            revenue: 5,
            desc: 'No special abilities. No markers or tokens.',
            auction_row: 1,
          },
          # -----------------------------------------------------------------------
          # Row 2 — £40 privates
          # -----------------------------------------------------------------------
          {
            name: 'Wien Südbahnhof',
            sym: 'WS',
            value: 40,
            revenue: 10,
            desc: 'During any RR\'s Place Token step, the owner may place one station token from any '\
                  'controlled RR on the map for free (sea-zone crossing costs still apply). '\
                  'If also owning the White Cliffs Ferry, this private may pay for that token\'s placement cost.',
            auction_row: 2,
          },
          {
            name: 'Barclay, Bevan, Barclay and Tritton',
            sym: 'BBBT',
            value: 40,
            revenue: 10,
            desc: 'One marker. Exercise one of three abilities: '\
                  '(1) During any SR or a controlled RR\'s OR, re-set the par value of one owned regional or major '\
                  'to any valid par value for that type. '\
                  '(2) Place one share of any RR into custodianship — reserved for the owner; '\
                  'place this private\'s marker on the share. '\
                  '(3) At any time during a SR, prevent one RR\'s share marker from moving DOWN for the rest of that SR; '\
                  'place this private\'s marker on that share marker. '\
                  'Exercising ability (2) or (3) closes this private at end of the SR.',
            auction_row: 2,
          },
          # -----------------------------------------------------------------------
          # Row 3 — £60 privates
          # -----------------------------------------------------------------------
          {
            name: 'Star Harbor Trading Company',
            sym: 'SHTC',
            value: 60,
            revenue: 15,
            desc: 'One marker and one token. During a controlled RR\'s Place Token step, place the token in any '\
                  'port city at no cost (does not consume a token position). '\
                  'The owning RR may use this city as a private or public port for sea crossings. '\
                  'Other RRs\' tokens in this city do not block the owning RR and collect no revenue there. '\
                  'The token city need not be reachable but may not serve as the sole token on a route, '\
                  'nor be used to place further tokens. '\
                  'May be exercised at any time during a SR, including while another player is purchasing stock.',
            auction_row: 3,
          },
          {
            name: 'Central Circle Transport Corporation',
            sym: 'CCTC',
            value: 60,
            revenue: 15,
            desc: 'One marker and one token. During a controlled RR\'s Place Token step, place the token in any '\
                  'non-port city at no cost (does not consume a token position). '\
                  'The owning RR counts this hex as a town when running routes through it; '\
                  'revenue: £10 (Phase 2), £20 (Phase 3–4), £40 (Phase 5–6), £60 (Phase 7–8). '\
                  'Other RRs\' tokens in this city do not block the owning RR and collect no revenue there. '\
                  'May be exercised at any time during a SR, including while another player is purchasing stock.',
            auction_row: 3,
          },
          {
            name: 'White Cliffs Ferry',
            sym: 'WCF',
            value: 60,
            revenue: 15,
            desc: 'No markers or tokens. At the start of Train Phase 5, the owner may immediately place one '\
                  'station token from any controlled RR on the White Cliffs Ferry token position next to Lille. '\
                  'The RR pays treasury cash for the token but need not be connected to Lille. '\
                  'If the owner waits, the token may instead be placed during that RR\'s Place Token step (consuming it). '\
                  'The Ferry position functions as an open token slot in Lille until used. See §11.2.2.',
            auction_row: 3,
          },
          # -----------------------------------------------------------------------
          # Row 4 — £80 + £100 + £120 privates (HMLC, BBE, SML)
          # -----------------------------------------------------------------------
          {
            name: 'Hochberg Mining and Lumber Company',
            sym: 'HMLC',
            value: 80,
            revenue: 20,
            desc: 'One token. During a controlled RR\'s Track Lay step, place the token on any rough-terrain hex '\
                  'with a construction cost of at least £45 (hex may already contain track or one town, '\
                  'which the token replaces). Turn the private face-down to indicate placement. '\
                  'Only the owner\'s RRs may use track on hexes bearing this token. '\
                  'To remove the token, another RR must pay the original terrain cost and expend one tile point '\
                  '(two for a metropolis); nationals skip the terrain cost but still expend tile points.',
            auction_row: 4,
          },
          {
            name: 'Brandt and Brandau, Engineers',
            sym: 'BBE',
            value: 100,
            revenue: 25,
            desc: 'Four tokens. Up to two tokens may be used per OR by the owner, across one or two controlled RRs, '\
                  'during their Track Lay step. Place a token on a rough-terrain hex and lay a yellow tile there '\
                  'at no terrain cost (tile points are still spent; the tile may be immediately upgraded). '\
                  'Only the owner\'s RRs may use track on hexes bearing these tokens. '\
                  'Turn the private face-down when the last token is placed; it is removed from the game '\
                  'when no tokens remain on the map.',
            auction_row: 4,
          },
          {
            name: 'Swift Metropolitan Line',
            sym: 'SML',
            value: 120,
            revenue: 0,
            desc: 'One marker. From Train Phase 4 onward, the owner designates one controlled RR to receive '\
                  'a preserved 2+2 train taken from the rusted pool. The marker is placed on that train. '\
                  'This train does not count against the train limit, cannot run on track already used by '\
                  'the RR\'s other trains in the same OR, and can never be sold. '\
                  'If held by a minor, the train transfers to the major when the minor merges.',
            auction_row: 4,
          },
          # -----------------------------------------------------------------------
          # Rows 5–7 — Minor-exchange companies (float all 12 minors)
          # Row 5: A B C  |  Row 6: D E F G  |  Row 7: H J K L M
          # -----------------------------------------------------------------------
          {
            name: 'Golden Bell Marketplace',
            sym: 'C',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor C charter. '\
                  'Exchange this private during a Stock Round to float Minor C.',
            auction_row: 5,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[C],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Great Western Steamship Company',
            sym: 'H',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor H charter. '\
                  'Exchange this private during a Stock Round to float Minor H.',
            auction_row: 7,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[H],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Vermilion Seal Couriers',
            sym: 'K',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor K charter. '\
                  'Exchange this private during a Stock Round to float Minor K.',
            auction_row: 7,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[K],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Compagnie Internationale des Wagons-Lits',
            sym: 'M',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor M charter. '\
                  'Exchange this private during a Stock Round to float Minor M.',
            auction_row: 7,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[M],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Silver Banner Line',
            sym: 'A',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor A charter. '\
                  'Exchange this private during a Stock Round to float Minor A.',
            auction_row: 5,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[A],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Orange Scroll Surveyors',
            sym: 'B',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor B charter. '\
                  'Exchange this private during a Stock Round to float Minor B.',
            auction_row: 5,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[B],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Green Junction Mercantile',
            sym: 'D',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor D charter. '\
                  'Exchange this private during a Stock Round to float Minor D.',
            auction_row: 6,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[D],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Blue Coast Bridge Construction Company',
            sym: 'E',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor E charter. '\
                  'Exchange this private during a Stock Round to float Minor E.',
            auction_row: 6,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[E],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'White Peak Mountain Railway',
            sym: 'F',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor F charter. '\
                  'Exchange this private during a Stock Round to float Minor F.',
            auction_row: 6,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[F],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Indigo Foundry and Iron Works',
            sym: 'G',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor G charter. '\
                  'Exchange this private during a Stock Round to float Minor G.',
            auction_row: 6,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[G],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Grey Locomotive Works',
            sym: 'J',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor J charter. '\
                  'Exchange this private during a Stock Round to float Minor J.',
            auction_row: 7,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[J],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          {
            name: 'Krasnaya Strela',
            sym: 'L',
            value: 120,
            revenue: 0,
            desc: 'Purchased in the auction to acquire the Minor L charter. '\
                  'Exchange this private during a Stock Round to float Minor L.',
            auction_row: 7,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[L],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          # -----------------------------------------------------------------------
          # Minors — all 12 (A–M, excluding I)
          # -----------------------------------------------------------------------
          {
            name: 'Silver Banner Line',
            logo: '18_oe/A',
            sym: 'A',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#666666',
            abilities: [
              {
                type: 'description',
                description: 'When merged into a major, the bank pays cash into the major\'s treasury '\
                             'equal to the major\'s current share value at the time of merger. '\
                             'The cash is never part of the minor\'s own treasury.',
              },
            ],
          },
          {
            name: 'Orange Scroll Surveyors',
            logo: '18_oe/B',
            sym: 'B',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#F08080',
            text_color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'All track upgrades cost only 1 tile point, including tiles with towns — '\
                             'but not cities, grand cities, or metropolises.',
              },
            ],
          },
          {
            name: 'Golden Bell Marketplace',
            logo: '18_oe/C',
            sym: 'C',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#66CDAA',
            text_color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'At the start of each OR, the president may choose this minor\'s operating '\
                             'position: first, last, or normal order. The choice is announced before '\
                             'any other RR operates that OR.',
              },
            ],
          },
          {
            name: 'Green Junction Mercantile',
            logo: '18_oe/D',
            sym: 'D',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#3CB371',
            text_color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'The president may place this minor\'s token in any non-metropolis, '\
                             'non-red-zone city on the map (even unreachable). Trains run to or through '\
                             'that city earn a +£20 bonus (Phase 2–4). At Phase 5 start, the +£20 token '\
                             'is removed; the president may place a new token in the same or a different '\
                             'eligible city for a +£40 bonus (Phase 5+). Placed during the lay track step.',
              },
            ],
          },
          {
            name: 'Blue Coast Bridge Construction Company',
            logo: '18_oe/E',
            sym: 'E',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#6495ED',
            text_color: 'black',
            abilities: [
              {
                type: 'description',
                description: '33% discount on all blue terrain (water/coast) track construction costs '\
                             '(multiply total cost by 0.67, round down to nearest £1). '\
                             'Each OR may also spend 1 extra tile point to place a yellow tile '\
                             'in a hex with a blue terrain cost.',
              },
              {
                type: 'tile_discount',
                terrain: 'water',
                discount: 0, # augments zone discount to 50% when zone match; 0 prevents base engine applying its own discount
                owner_type: 'corporation',
              },
              {
                type: 'tile_lay',
                tiles: [],
                when: 'track',
                count_per_or: 1,
                owner_type: 'corporation',
                consume_tile_lay: false,
              },
            ],
          },
          {
            name: 'White Peak Mountain Railway',
            logo: '18_oe/F',
            sym: 'F',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            color: '#888888',
            text_color: 'black',
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'description',
                description: '33% discount on all mountain/rough (green terrain) track construction costs '\
                             '(multiply total cost by 0.67, round down to nearest £1). '\
                             'Each OR may also spend 1 extra tile point to place a yellow tile '\
                             'in a hex with a green terrain cost.',
              },
              {
                type: 'tile_discount',
                terrain: 'mountain',
                discount: 0, # augments zone discount to 50% when zone match; 0 prevents base engine applying its own discount
                owner_type: 'corporation',
              },
              {
                type: 'tile_lay',
                tiles: [],
                when: 'track',
                count_per_or: 1,
                owner_type: 'corporation',
                consume_tile_lay: false,
              },
            ],
          },
          {
            name: 'Indigo Foundry and Iron Works',
            logo: '18_oe/G',
            sym: 'G',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            color: '#9370DB',
            text_color: 'black',
            max_ownership_percent: 100,
            abilities: [
              {
                type: 'description',
                description: 'Receives 2 extra tile points to use during its lay track step every OR.',
              },
            ],
          },
          {
            name: 'Great Western Steamship Company',
            logo: '18_oe/H',
            sym: 'H',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#5F9EA0',
            text_color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Reduces the number of sea zones that count towards trains\' city limits '\
                             'by 1 during Train Phases 1–6, and by 2 during Train Phases 7–8.',
              },
            ],
          },
          {
            name: 'Grey Locomotive Works',
            logo: '18_oe/J',
            sym: 'J',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#aaaaaa',
            text_color: 'black',
            abilities: [
              {
                type: 'description',
                description: '10% discount on the purchase price of all trains (including Pullman cars). '\
                             'Minor M still receives the full £15 royalty on Pullman purchases '\
                             'even when this discount applies.',
              },
            ],
          },
          {
            name: 'Vermilion Seal Couriers',
            logo: '18_oe/K',
            sym: 'K',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#CD5C5C',
            abilities: [
              {
                type: 'description',
                description: 'Mail contract: at the start of each OR the bank pays directly to treasury '\
                             '(not counted as train revenue): £20 (Phase 2), £40 (Phase 3–4), '\
                             '£50 (Phase 5–6), £60 (Phase 7–8). '\
                             'Available immediately for track or token placement that OR.',
              },
            ],
          },
          {
            name: 'Krasnaya Strela',
            logo: '18_oe/L',
            sym: 'L',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#FA8072',
            text_color: 'black',
            abilities: [
              {
                type: 'description',
                description: '+1+1 marker: assigned to one train at the start of the run trains step each OR. '\
                             'Increases that train\'s city limit and town count each by 1 '\
                             '(e.g. a 2+2 runs as a 3+3). For D trains, the extra city does not double. '\
                             'Does not affect Pullman car revenue calculation.',
              },
            ],
          },
          {
            name: 'Compagnie Internationale des Wagons-Lits',
            logo: '18_oe/M',
            sym: 'M',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
            color: '#87CEFA',
            text_color: 'black',
            abilities: [
              {
                type: 'description',
                description: 'Owns 10 Pullman cars. Receives one free Pullman at the start of Train Phase 4. '\
                             'Other RRs may purchase a Pullman for £150; bank pays £15 royalty to Minor M '\
                             'or its owning major (no royalty if purchased from the Open Market). '\
                             'Minor J\'s 10% discount applies to the price but not to the royalty.',
              },
            ],
          },
          # -----------------------------------------------------------------------
          # Regionals — United Kingdom (UK)
          # -----------------------------------------------------------------------
          {
            name: 'London and North Western Railway',
            logo: '18_oe/LNWR',
            sym: 'LNWR',
            tokens: [40, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'J27',
            color: '#333333',
            always_market_price: true,
          },
          {
            name: 'Great Western Railway',
            logo: '18_oe/GWR',
            sym: 'GWR',
            tokens: [40, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'L25',
            color: '#8B0000',
            always_market_price: true,
          },
          {
            name: 'Great Southern and Western Railway',
            logo: '18_oe/GSWR',
            sym: 'GSWR',
            tokens: [40, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'I20',
            color: '#000080',
            always_market_price: true,
          },
          # -----------------------------------------------------------------------
          # Regionals — France / Belgium (FR)
          # -----------------------------------------------------------------------
          {
            name: 'CF Paris a Lyon et a la Mediterranee',
            logo: '18_oe/PLM',
            sym: 'PLM',
            tokens: [20, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'U34',
            color: '#4B0082',
            always_market_price: true,
          },
          {
            name: 'CF du Midi',
            logo: '18_oe/MIDI',
            sym: 'MIDI',
            tokens: [20, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'U24',
            color: '#0000CD',
            always_market_price: true,
          },
          {
            name: "CF de l'Ouest",
            logo: '18_oe/OU',
            sym: 'OU',
            tokens: [20, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'Q26',
            color: '#FF4500',
            always_market_price: true,
          },
          {
            name: 'SNCF Belges',
            logo: '18_oe/BEL',
            sym: 'BEL',
            tokens: [20, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'N35',
            color: '#555555',
            always_market_price: true,
          },
          # -----------------------------------------------------------------------
          # Regionals — Prussia / Holland / Switzerland (PHS)
          # -----------------------------------------------------------------------
          {
            name: 'Berlin Hamburger Bahn',
            logo: '18_oe/BHB',
            sym: 'BHB',
            tokens: [40, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'K46',
            color: '#666666',
            always_market_price: true,
          },
          {
            name: 'Preußische Ostbahn',
            logo: '18_oe/POB',
            sym: 'POB',
            tokens: [40, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'L53',
            color: '#8B4513',
            always_market_price: true,
          },
          {
            name: 'Königlich Sächsische Staatseisenbahnen',
            logo: '18_oe/KSS',
            sym: 'KSS',
            tokens: [40, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'N49',
            color: '#228B22',
            always_market_price: true,
          },
          {
            name: 'Königlich Bayerische Staatseisenbahnen',
            logo: '18_oe/KBS',
            sym: 'KBS',
            tokens: [40, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'R47',
            color: '#4682B4',
            always_market_price: true,
          },
          # -----------------------------------------------------------------------
          # Regionals — Austria-Hungary (AH)
          # -----------------------------------------------------------------------
          {
            name: 'Österreichische Südbahn',
            logo: '18_oe/SB',
            sym: 'SB',
            tokens: [20, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'R55',
            color: '#DC143C',
            always_market_price: true,
          },
          {
            name: 'Magyar Allamvasutak',
            logo: '18_oe/MAV',
            sym: 'MAV',
            tokens: [20, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'S60',
            color: '#222222',
            always_market_price: true,
          },
          # -----------------------------------------------------------------------
          # Regionals — Italy (IT)
          # -----------------------------------------------------------------------
          {
            name: "Societa per le Ferrovie dell'Alta Italia",
            logo: '18_oe/SFAI',
            sym: 'SFAI',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'V41',
            color: '#654321',
            always_market_price: true,
          },
          {
            name: 'Societa per le strade ferrate romane',
            logo: '18_oe/SFR',
            sym: 'SFR',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'Z47',
            color: '#2E8B57',
            always_market_price: true,
          },
          # -----------------------------------------------------------------------
          # Regionals — Spain / Portugal (SP)
          # -----------------------------------------------------------------------
          {
            name: 'Caminos de Hierro del Norte de Espana',
            logo: '18_oe/CHN',
            sym: 'CHN',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'Z27',
            color: '#A0522D',
            always_market_price: true,
          },
          {
            name: 'Cia de los Ferrocarriles de Madrid a Zaragoza y Alicante',
            logo: '18_oe/MZA',
            sym: 'MZA',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'AD17',
            color: '#FFD700',
            text_color: 'black',
            always_market_price: true,
          },
          {
            name: 'Companhia Real dos Caminhos de Ferro Portugueses',
            logo: '18_oe/RCP',
            sym: 'RCP',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'Z1',
            color: '#006400',
            always_market_price: true,
          },
          # -----------------------------------------------------------------------
          # Regionals — Russia (RU)
          # -----------------------------------------------------------------------
          {
            name: 'Petersburgo-Moskovskaya Zheleznaya Doroga',
            logo: '18_oe/MSP',
            sym: 'MSP',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'C74',
            color: '#B22222',
            always_market_price: true,
          },
          {
            name: 'Moskovsko-Kiyevo-Voronezhskaya Zheleznaya Doroga',
            logo: '18_oe/MKV',
            sym: 'MKV',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'O80',
            color: '#D2691E',
            always_market_price: true,
          },
          {
            name: 'Libavo-Romenskaya Zheleznaya Doroga',
            logo: '18_oe/LRZD',
            sym: 'LRZD',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'J73',
            color: '#800080',
            always_market_price: true,
          },
          {
            name: 'Droga Zelazna Warszawsko-Wiedenska',
            logo: '18_oe/WW',
            sym: 'WW',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'M62',
            color: '#1E90FF',
            always_market_price: true,
          },
          # -----------------------------------------------------------------------
          # Regionals — Scandinavia / Denmark / Norway (SC)
          # -----------------------------------------------------------------------
          {
            name: 'Det Sjaellandske Jernbaneselskab',
            logo: '18_oe/DSJ',
            sym: 'DSJ',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'I50',
            color: '#444444',
            always_market_price: true,
          },
          {
            name: 'Bergslagernas Järnvägar',
            logo: '18_oe/BJV',
            sym: 'BJV',
            tokens: [10, 20],
            type: 'regional',
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'F49',
            color: '#FFFACD',
            text_color: 'black',
            always_market_price: true,
          },
        ].freeze
      end
    end
  end
end
