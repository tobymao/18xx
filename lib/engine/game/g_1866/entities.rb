# frozen_string_literal: true

module Engine
  module Game
    module G1866
      module Entities
        COMPANIES = [
          {
            name: 'Stockton & Darlington',
            sym: 'P1',
            value: 0,
            revenue: 0,
            desc: 'Gives priority in ISR. Closes at end of IAR when ISR priority determined.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Great Britain',
            sym: 'P2',
            value: 0,
            revenue: 10,
            desc: 'Concession for Great Britain National Company. Closes when concession exercised to purchase '\
                  'company.',
            abilities: [],
            color: nil,
          },
          {
            name: 'France',
            sym: 'P3',
            value: 0,
            revenue: 10,
            desc: 'Concession for France National Company. Closes when concession exercised to purchase company.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Austro-Hungarian Empire',
            sym: 'P4',
            value: 0,
            revenue: 10,
            desc: 'Concession for Austro-Hungarian Empire Company. Closes when concession exercised to purchase '\
                  'company.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Luxembourg',
            sym: 'P5',
            value: 0,
            revenue: 10,
            desc: 'Revenue paid to owning player. Can be acquired by a public company. When held by a public company '\
                  'gives that company operating rights in Luxembourg.',
            abilities: [],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [].freeze
      end
    end
  end
end
