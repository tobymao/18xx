# frozen_string_literal: true

module Engine
  module Game
    module G18Scan
      module Entities
        COMPANIES = [
          {
            name: 'Stockholm-Åbo Ferry Company',
            sym: 'Ferry',
            value: 120,
            revenue: 20,
            desc: 'Two +20 bonus tokens',
            abilities: [],
            color: nil,
          },
          {
            name: 'Lapland Ore Line',
            sym: 'Mine',
            value: 150,
            revenue: 25,
            desc: '+50 bonus token for Kiruna',
            abilities: [],
            color: nil,
          },
          {
            name: 'Sjællandske Jernbaneselskab',
            sym: 'SJS',
            value: 180,
            revenue: 30,
            desc: 'Lays COP tile for free',
            abilities: [
              {
                type: 'tile_lay',
                hexes: ['F3'],
                tiles: ['403', '121', '584'],
                when: 'track',
                owner_type: 'player',
                count: 1,
                consume_tile_lay: true,
                special: true,
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'DSB',
            name: 'Danske Statsbaner',
            tokens: [0, 40, 100],
            coordinates: 'F3',
            color: :red,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'S&NJ',
            name: 'Sveriges & Norges Järnvägar',
            tokens: [0, 40, 100],
            coordinates: 'B19',
            color: :green,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'NSB',
            name: 'Norges Statsbaner',
            tokens: [0, 40, 100, 100],
            coordinates: 'D7',
            color: :red,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'VR',
            name: 'Valtionraurariet',
            tokens: [0, 40, 100, 100],
            coordinates: 'G14',
            color: :red,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SJ',
            name: 'Statens Järvvägar',
            tokens: [0, 100, 100, 100, 100, 100],
            coordinates: 'F3',
            color: :red,
            reservation_color: nil,
            type: 'national'
          },
        ].freeze

        MINORS = [
          {
            sym: '1',
            name: 'Södra Stambanan',
            tokens: [0],
            coordinates: 'C15',
            text_color: 'black',
            value: 260,
            order: 1,
          },
          {
            sym: '2',
            name: 'Nordvärsta Stambanan',
            tokens: [0],
            coordinates: 'C15',
            text_color: 'black',
            value: 260,
            order: 2,
          },
          {
            sym: '3',
            name: 'Västra Stambanan',
            tokens: [0],
            coordinates: 'C15',
            text_color: 'black',
            value: 200,
            order: 3,
          },
        ].freeze
     end
    end
  end
end
