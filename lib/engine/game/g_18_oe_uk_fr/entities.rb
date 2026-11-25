# frozen_string_literal: true

require_relative '../g_18_oe/entities'

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
            desc: G18OE::Entities::COMPANIES.find { |company| company[:sym] == 'SHTC' }[:desc],
            abilities: G18OE::Entities::COMPANIES.find { |company| company[:sym] == 'SHTC' }[:abilities],
            auction_row: 2,
          },
          {
            name: 'Central Circle Transport Co.',
            sym: 'CCTC',
            value: 60,
            revenue: 15,
            desc: G18OE::Entities::COMPANIES.find { |company| company[:sym] == 'CCTC' }[:desc],
            abilities: G18OE::Entities::COMPANIES.find { |company| company[:sym] == 'CCTC' }[:abilities],
            auction_row: 3,
          },
          {
            name: 'White Cliffs Ferry',
            sym: 'WCF',
            value: 60,
            revenue: 15,
            abilities: G18OE::Entities::COMPANIES.find { |company| company[:sym] == 'WCF' }[:abilities],
            auction_row: 4,
          },
          {
            name: 'Golden Bell Marketplace',
            sym: 'C',
            value: 120,
            revenue: 0,
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
            auction_row: 5,
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
            auction_row: 6,
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
            auction_row: 6,
            abilities: [
              {
                type: 'exchange',
                corporations: %w[M],
                owner_type: 'player',
                from: %w[ipo],
              },
            ],
          },
          G18OE::Entities::COMPANIES.find { |company| company[:sym] == 'MAIL' },
        ].freeze

        CORPORATIONS = %w[C H K M BEL GSWR GWR LNWR MIDI OU PLM].map do |sym|
          corporation = G18OE::Entities::CORPORATIONS.find { |entity| entity[:sym] == sym }
          next corporation unless sym == 'M'

          corporation.merge(abilities: corporation[:abilities].map do |ability|
            ability.merge(description: ability[:description].sub('10 Pullman cars', '3 Pullman cars'))
          end)
        end.freeze
      end
    end
  end
end
