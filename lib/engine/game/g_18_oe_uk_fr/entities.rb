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
        ].freeze

        CORPORATIONS = [
          {
            name: 'Golden Bell Marketplace',
            sym: 'C',
            tokens: [20, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
          {
            name: 'Great Western Steamship Company',
            sym: 'H',
            tokens: [20, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
          {
            name: 'Vermilion Seal Couriers',
            sym: 'K',
            tokens: [20, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
          {
            name: 'Compagnie Internationale des Wagons-Lits',
            sym: 'M',
            tokens: [20, 20],
            type: 'minor',
            shares: [100],
            float_percent: 100,
            max_ownership_percent: 100,
          },
          {
            name: 'SNCF Belges',
            sym: 'BEL',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: ['N36'],
          },
          {
            name: 'Great Southern and Western Railway',
            sym: 'GSWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: ['I20'],
          },
          {
            name: 'Great Western Railway',
            sym: 'GWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: ['L25'],
          },
          {
            name: 'London and North Western Railway',
            sym: 'LNWR',
            tokens: [40, 20],
            shares: [50, 25, 25],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: ['J27'],
          },
          {
            name: 'CF du Midi',
            sym: 'MIDI',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: ['U24'],
          },
          {
            name: 'CF de l\'Ouest',
            sym: 'OU',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: ['Q26'],
          },
          {
            name: 'CF Paris a Lyon et a la Mediterranee',
            sym: 'PLM',
            tokens: [20, 20],
            shares: [50, 25, 25],
            float_percent: 100,
            max_ownership_percent: 100,
            coordinates: ['U34'],
          },
        ].freeze
      end
    end
  end
end
