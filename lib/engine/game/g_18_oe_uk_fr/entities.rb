# frozen_string_literal: true

module Engine
  module Game
    module G18OEUKFR
      module Entities
        COMPANIES = [
          {
            name: 'Ponts et Chaussees',
            sym: 'PeC',
            value: 20,
            revenue: 5,
            auction_row: 1,
          },
          {
            name: 'Star Harbor Trading Co.',
            sym: 'SHTC',
            value: 60,
            revenue: 15,
            auction_row: 2,
          },
          {
            name: 'Central Circle Transport Co.',
            sym: 'CCTC',
            value: 60,
            revenue: 15,
            auction_row: 3,
          },
          {
            name: 'White Cliffs Ferry',
            sym: 'WCF',
            value: 60,
            revenue: 15,
            auction_row: 4,
          },
          {
            name: 'Golden Bell Marketplace',
            sym: 'C',
            value: 120,
            revenue: 0,
            auction_row: 5,
            # abilities: [
            #   {
            #     type: 'exchange',
            #     corporations: ['C'],
            #     owner_type: 'player',
            #     from: 'par',
            #   },
            # ]
          },
          {
            name: 'Great Western Steamship Company',
            sym: 'H',
            value: 120,
            revenue: 0,
            auction_row: 5,
            # abilities: [
            #   {
            #     type: 'exchange',
            #     corporations: ['H'],
            #     owner_type: 'player',
            #     from: 'par',
            #   },
            # ]
          },
          {
            name: 'Vermilion Seal Couriers',
            sym: 'K',
            value: 120,
            revenue: 0,
            auction_row: 6,
            # abilities: [
            #   {
            #     type: 'exchange',
            #     corporations: ['K'],
            #     owner_type: 'player',
            #     from: 'par',
            #   },
            # ]
          },
          {
            name: 'Compagnie Internationale des Wagons-Lits',
            sym: 'M',
            value: 120,
            revenue: 0,
            auction_row: 6,
            # abilities: [
            #   {
            #     type: 'exchange',
            #     corporations: ['M'],
            #     owner_type: 'player',
            #     from: 'par',
            #   },
            # ]
          },
        ].freeze

        MINORS = [
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
            name: 'Compagnie Internationale des Wagons-Lits',
            logo: '18_oe/M',
            sym: 'M',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
        ].freeze

        CORPORATIONS = [
          {
            name: 'SNCF Belges',
            logo: '18_oe/BEL',
            sym: 'BEL',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'N35',
            color: :green,
          },
          {
            name: 'Great Southern and Western Railway',
            logo: '18_oe/GSWR',
            sym: 'GSWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'I20',
            color: :blue,
          },
          {
            name: 'Great Western Railway',
            logo: '18_oe/GWR',
            sym: 'GWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'L25',
            color: :red,
          },
          {
            name: 'London and North Western Railway',
            logo: '18_oe/LNWR',
            sym: 'LNWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'J27',
            color: :black,
          },
          {
            name: 'CF du Midi',
            logo: '18_oe/MIDI',
            sym: 'MIDI',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'U24',
            color: :blue,
          },
          {
            name: 'CF de l\'Ouest',
            logo: '18_oe/OU',
            sym: 'OU',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'Q26',
            color: :orange,
          },
          {
            name: 'CF Paris a Lyon et a la Mediterranee',
            logo: '18_oe/PLM',
            sym: 'PLM',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: 'U34',
            color: :purple,
          },
        ].freeze
      end
    end
  end
end
