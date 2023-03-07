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
          },
          {
            name: 'Star Harbor Trading Co.',
            sym: 'SHTC',
            value: 60,
            revenue: 15,
          },
          {
            name: 'Central Circle Transport Co.',
            sym: 'CCTC',
            value: 60,
            revenue: 15,
          },
          {
            name: 'White Cliffs Ferry',
            sym: 'WCF',
            value: 60,
            revenue: 15,
          },
          {
            name: 'Golden Bell Marketplace',
            sym: 'C',
            value: 120,
            revenue: 0,
            # abilities: [
            #   {
            #     type: :float_minor,
            #     minor: 'F',
            #     owner_type: :player,
            #   }
            # ]
          },
          {
            name: 'Great Western Steamship Company',
            sym: 'H',
            value: 120,
            revenue: 0,
            # abilities: [
            #   {
            #     type: :float_minor,
            #     minor: 'F',
            #     owner_type: :player,
            #   }
            # ]
          },
          {
            name: 'Vermilion Seal Couriers',
            sym: 'K',
            value: 120,
            revenue: 0,
            # abilities: [
            #   {
            #     type: :float_minor,
            #     minor: 'K',
            #     owner_type: :player,
            #   }
            # ]
          },
          {
            name: 'Compagnie Internationale des Wagons-Lits',
            sym: 'M',
            value: 120,
            revenue: 0,
            # abilities: [
            #   {
            #     type: :float_minor,
            #     minor: 'M',
            #     owner_type: :player,
            #   }
            # ]
          },
        ].freeze

        MINORS = [
          {
            name: 'Golden Bell Marketplace',
            sym: 'C',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
          {
            name: 'Great Western Steamship Company',
            sym: 'H',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
          {
            name: 'Vermilion Seal Couriers',
            sym: 'K',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
          {
            name: 'Compagnie Internationale des Wagons-Lits',
            sym: 'M',
            tokens: [0, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
        ]

        CORPORATIONS = [
          {
            name: 'SNCF Belges',
            logo: '18_oe/Belge',
            sym: 'BEL',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: ['N35'],
          },
          {
            name: 'Great Southern and Western Railway',
            logo: '18_oe/GSWR',
            sym: 'GSWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: ['I20'],
          },
          {
            name: 'Great Western Railway',
            logo: '18_oe/GWR',
            sym: 'GWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: ['L25'],
          },
          {
            name: 'London and North Western Railway',
            logo: '18_oe/LNWR',
            sym: 'LNWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: ['J27'],
          },
          {
            name: 'CF du Midi',
            logo: '18_oe/MIDI',
            sym: 'MIDI',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: ['U24'],
          },
          {
            name: 'CF de l\'Ouest',
            logo: '18_oe/OU',
            sym: 'OU',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: ['Q26'],
          },
          {
            name: 'CF Paris a Lyon et a la Mediterranee',
            logo: '18_oe/PLM',
            sym: 'PLM',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 50,
            max_ownership_percent: 100,
            coordinates: ['U34'],
          },
        ].freeze
      end
    end
  end
end
