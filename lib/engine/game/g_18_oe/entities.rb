# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module Entities
        COMPANIES = [
          # === PRIVATES (auction rows 1-6 by face value tier) ===
          # TODO: verify auction rows against physical opening packet layout

          {
            name: 'Robert Stephenson and Company',
            sym: 'RSC',
            value: 20,
            revenue: 5,
            auction_row: 1,
          },
          {
            name: 'Ponts et Chaussees',
            sym: 'PeC',
            value: 20,
            revenue: 5,
            auction_row: 1,
          },
          {
            name: 'Wien Sudbahnhof',
            sym: 'WS',
            value: 40,
            revenue: 10,
            auction_row: 2,
            desc: 'During any RR\'s place token step, owner may place one of the RR\'s station tokens '\
                  'for free. Token must be reachable. Sea zone costs still apply.',
          },
          {
            name: 'Barclay, Bevan, Barclay and Tritton',
            sym: 'BBBT',
            value: 40,
            revenue: 10,
            auction_row: 2,
            desc: 'Choose one: (1) Re-set par value of one owned regional or major to a valid par value; '\
                  '(2) Reserve one share of a RR\'s stock for the owning player; '\
                  '(3) Prevent one RR\'s share value marker from moving DOWN for rest of SR.',
          },
          {
            name: 'Star Harbor Trading Company',
            sym: 'SHTC',
            value: 60,
            revenue: 15,
            auction_row: 3,
            desc: 'Place token in a port city during a RR\'s lay token step. Owning RR may use it '\
                  'as a public/private port for sea crossings. Does not consume a token position.',
          },
          {
            name: 'Central Circle Transport Corporation',
            sym: 'CCTC',
            value: 60,
            revenue: 15,
            auction_row: 3,
            desc: 'Place token in a non-port city during a RR\'s lay token step. Counts as a town '\
                  'for owning RR. Revenue: Ph2=£10, Ph3-4=£20, Ph5-6=£40, Ph7-8=£60.',
          },
          {
            name: 'White Cliffs Ferry',
            sym: 'WCF',
            value: 60,
            revenue: 15,
            auction_row: 3,
            desc: 'At Train Phase 5 start, place one station token from a controlled RR on the '\
                  'White Cliffs Ferry token position next to Lille. RR pays cost; no connection required.',
          },
          {
            name: 'Hochberg Mining and Lumber Co.',
            sym: 'HMLC',
            value: 80,
            revenue: 20,
            auction_row: 4,
            desc: 'Place token in a rough (green terrain, cost >=£45) hex during a controlled RR\'s '\
                  'lay track step. Only owner\'s RRs may use track with this token. Another RR may '\
                  'remove the token by paying original terrain cost + 1 tile point (nationals skip cost).',
          },
          {
            name: 'Brandt and Brandau, Engineers',
            sym: 'BBE',
            value: 100,
            revenue: 25,
            auction_row: 5,
            desc: '4 tokens; up to 2 per OR for owner\'s controlled RRs. Place token in rough (green) '\
                  'terrain hex; yellow tile placed there at no terrain cost (still uses tile points). '\
                  'Only owner\'s RRs may use track. Closes when last token is placed.',
          },
          {
            name: 'Swift Metropolitan Line',
            sym: 'SML',
            value: 120,
            revenue: 0,
            auction_row: 6,
            desc: 'At Train Phase 4+: designate one RR to receive one unclaimed rusted 2+2 train. '\
                  'Does not count against train limit; cannot run on track already used by RR\'s other '\
                  'trains in same OR; cannot be sold. Transfers to major when owning minor merges.',
          },

          # === CONCESSIONS (auction rows 7-8) ===
          # TODO: verify face values and auction rows against physical opening packet layout

          { name: 'Concession 1',  sym: 'CON1',  value: 100, revenue: 0, auction_row: 7 },
          { name: 'Concession 2',  sym: 'CON2',  value: 100, revenue: 0, auction_row: 7 },
          { name: 'Concession 3',  sym: 'CON3',  value: 100, revenue: 0, auction_row: 7 },
          { name: 'Concession 4',  sym: 'CON4',  value: 100, revenue: 0, auction_row: 7 },
          { name: 'Concession 5',  sym: 'CON5',  value: 100, revenue: 0, auction_row: 7 },
          { name: 'Concession 6',  sym: 'CON6',  value: 100, revenue: 0, auction_row: 8 },
          { name: 'Concession 7',  sym: 'CON7',  value: 100, revenue: 0, auction_row: 8 },
          { name: 'Concession 8',  sym: 'CON8',  value: 100, revenue: 0, auction_row: 8 },
          { name: 'Concession 9',  sym: 'CON9',  value: 100, revenue: 0, auction_row: 8 },
          { name: 'Concession 10', sym: 'CON10', value: 100, revenue: 0, auction_row: 8 },

          # === MINOR CHARTERS (auction rows 9-12) ===
          # TODO: verify auction rows against physical opening packet layout

          {
            name: 'Silver Banner Line',
            sym: 'A',
            value: 120,
            revenue: 0,
            auction_row: 9,
            abilities: [{ type: 'exchange', corporations: %w[A], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Orange Scroll Surveyors',
            sym: 'B',
            value: 120,
            revenue: 0,
            auction_row: 9,
            abilities: [{ type: 'exchange', corporations: %w[B], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Golden Bell Marketplace',
            sym: 'C',
            value: 120,
            revenue: 0,
            auction_row: 9,
            abilities: [{ type: 'exchange', corporations: %w[C], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Green Junction Mercantile',
            sym: 'D',
            value: 120,
            revenue: 0,
            auction_row: 10,
            abilities: [{ type: 'exchange', corporations: %w[D], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Blue Coast Bridge Construction Company',
            sym: 'E',
            value: 120,
            revenue: 0,
            auction_row: 10,
            abilities: [{ type: 'exchange', corporations: %w[E], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'White Peak Mountain Railway',
            sym: 'F',
            value: 120,
            revenue: 0,
            auction_row: 10,
            abilities: [{ type: 'exchange', corporations: %w[F], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Indigo Foundry and Iron Works',
            sym: 'G',
            value: 120,
            revenue: 0,
            auction_row: 11,
            abilities: [{ type: 'exchange', corporations: %w[G], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Great Western Steamship Company',
            sym: 'H',
            value: 120,
            revenue: 0,
            auction_row: 11,
            abilities: [{ type: 'exchange', corporations: %w[H], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Grey Locomotive Works',
            sym: 'J',
            value: 120,
            revenue: 0,
            auction_row: 11,
            abilities: [{ type: 'exchange', corporations: %w[J], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Vermilion Seal Couriers',
            sym: 'K',
            value: 120,
            revenue: 0,
            auction_row: 12,
            abilities: [{ type: 'exchange', corporations: %w[K], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Krasnaya Strela',
            sym: 'L',
            value: 120,
            revenue: 0,
            auction_row: 12,
            abilities: [{ type: 'exchange', corporations: %w[L], owner_type: 'player', from: %w[ipo] }],
          },
          {
            name: 'Compagnie Internationale des Wagons-Lits',
            sym: 'M',
            value: 120,
            revenue: 0,
            auction_row: 12,
            abilities: [{ type: 'exchange', corporations: %w[M], owner_type: 'player', from: %w[ipo] }],
          },
        ].freeze

        CORPORATIONS = [
          # === 12 MINOR CORPORATIONS ===
          {
            name: 'Silver Banner Line',
            logo: '18_oe/A',
            sym: 'A',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
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
          },
          {
            name: 'White Peak Mountain Railway',
            logo: '18_oe/F',
            sym: 'F',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
          {
            name: 'Indigo Foundry and Iron Works',
            logo: '18_oe/G',
            sym: 'G',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
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
          },

          # === REGIONALS & MAJORS ===
          # Deferred — need home hex coordinates from map scans (openpoints.md 2.1)
        ].freeze
      end
    end
  end
end
