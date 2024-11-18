# frozen_string_literal: true

module Engine
  module Game
    module GSteamOverHolland
      module Entities
        COMPANIES = [
          {
            name: '1. Spoorweg Maatschappij Almelo - Salzbergen',
            sym: 'SMAS',
            value: 20,
            revenue: 5,
            desc: 'Place or upgrade one extra tile, free of charge. Closes after use.',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                when: 'track',
                count: 1,
                free: true,
                special: false,
                tiles: [],
                hexes: [],
                closed_when_used_up: true,
              },
            ],
          },
          {
            name: '2. Koninklijk Korps van Ingenieurs',
            sym: 'KKI',
            value: 40,
            revenue: 10,
            desc: 'Pays the costs for crossing a river one time. Closes after use.',
            abilities: [
              {
                type: 'tile_discount',
                when: 'track',
                owner_type: 'corporation',
                discount: 50,
                terrain: 'water',
                count: 1,
              },
              {
                type: 'tile_lay',
                when: 'track',
                owner_type: 'corporation',
                tiles: [],
                hexes: [],
                reachable: true,
                special: false,
                consume_tile_lay: true,
                count: 1,
                closed_when_used_up: true,
              },
            ],
          },
          {
            name: '3. Veerdienst Enkhuizen - Stavoren',
            sym: 'VES',
            value: 75,
            revenue: 15,
            desc: 'Fl. 20 bonus revenue for the owning company if it uses the ferry across the Zuiderzee at Enkhuizen (D9).',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: ['D9'],
                amount: 20,
              },
            ],
          },
          {
            name: '4. Veerdienst Vlissingen - Londen',
            sym: 'VVL',
            value: 75,
            revenue: 15,
            desc: 'Fl. 20 bonus for the owning company each time it starts or ends a route in Vlissingen (J1).',
            abilities: [
              {
                type: 'hex_bonus',
                owner_type: 'corporation',
                hexes: ['J1'],
                amount: 20,
              },
            ],
          },
          {
            name: '5. Rijks Waterstaat',
            sym: 'RW',
            value: 80,
            revenue: 20,
            desc: 'Allows the owning company to lay one station token for free. Closes after use.',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                count: 1,
                from_owner: true,
                special_only: true,
                connected: true,
                price: 0,
                when: 'token',
                hexes: %w[B13 B17 E14 H5 H9 H13 I6 I12 J7 K12],
                closed_when_used_up: true,
              },
            ],
          },
          {
            name: '6. Werkspoor',
            sym: 'W',
            value: 100,
            revenue: 20,
            desc: 'Gives a 10% discount on all trains the owning company buys from the bank.',
            abilities: [
              {
                type: 'train_discount',
                discount: 0.1,
                trains: %w[3 4 5],
              },
            ],
          },
          {
            name: '7. Koninklijke Ondersteuning ',
            sym: 'KO',
            value: 100,
            revenue: 10,
            desc: 'Comes with a share of the NRS',
            abilities: [{ type: 'shares', shares: 'NRS_1' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'NBD',
            name: 'Noord Brabantsch Duitsche Spoorweg Maatschappij',
            logo: 'steam_over_holland/NBD',
            tokens: [0, 40, 100, 100],
            coordinates: 'K12',
            always_market_price: true,
            color: 'blue',
          },
          {
            float_percent: 20,
            sym: 'HYSM',
            name: 'Hollandsche IJzeren Spoorweg Maatschappij',
            logo: 'steam_over_holland/HYSM',
            tokens: [0, 40, 100, 100],
            coordinates: 'F9',
            city: 1,
            always_market_price: true,
            color: 'green',
          },
          {
            float_percent: 20,
            sym: 'NRS',
            name: 'Nederlandsche Rhijnspoorweg',
            logo: 'steam_over_holland/NRS',
            tokens: [0, 40, 100, 100],
            coordinates: 'F9',
            city: 0,
            always_market_price: true,
            color: 'yellow',
            text_color: 'black',
          },
          {
            float_percent: 20,
            sym: 'OSM',
            name: 'Overijsselsche Spoorweg Maatschappij',
            logo: 'steam_over_holland/OSM',
            tokens: [0, 40, 100, 100],
            coordinates: 'E14',
            always_market_price: true,
            color: 'black',
          },
          {
            float_percent: 20,
            sym: 'AR',
            name: "Société Anonyme des Chemins de Fer d'Anvers à Rotterdam",
            logo: 'steam_over_holland/AR',
            tokens: [0, 40, 100, 100],
            coordinates: 'J7',
            always_market_price: true,
            color: 'red',
          },
          {
            float_percent: 20,
            sym: 'NCS',
            name: 'Nederlandsche Centraal Spoorweg Maatschappij',
            logo: 'steam_over_holland/NCS',
            tokens: [0, 40, 100, 100],
            coordinates: 'H9',
            always_market_price: true,
            color: 'purple',
          },
          {
            float_percent: 20,
            sym: 'NSM',
            name: 'Nijmeegsche Spoorweg Maatschappij',
            logo: 'steam_over_holland/NSM',
            tokens: [0, 40, 100, 100],
            coordinates: 'I12',
            always_market_price: true,
            color: 'white',
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
