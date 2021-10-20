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
            sym: '1',
            name: 'Södra Stambanan',
            logo: '18_scan/1',
            simple_logo: '18_scan/1.alt',
            tokens: [0, 0],
            coordinates: 'G4',
            value: 260,
            order: 1,
            type: 'minor',
          },
          {
            sym: '2',
            name: 'Nordvärsta Stambanan',
            logo: '18_scan/2',
            simple_logo: '18_scan/2.alt',
            tokens: [0, 0],
            coordinates: 'F11',
            value: 260,
            order: 2,
            type: 'minor',
          },
          {
            sym: '3',
            name: 'Västra Stambanan',
            logo: '18_scan/3',
            simple_logo: '18_scan/3.alt',
            tokens: [0, 0],
            coordinates: [nil, 'F11'],
            value: 200,
            order: 3,
            type: 'minor',
          },
          {
            float_percent: 20,
            sym: 'DSB',
            name: 'Danske Statsbaner',
            logo: '18_scan/DSB',
            simple_logo: '18_scan/DSB.alt',
            tokens: [0, 40, 100],
            coordinates: 'F3',
            color: "#C62A1D",
            reservation_color: nil,
            type: 'major',
          },
          {
            float_percent: 20,
            sym: 'S&NJ',
            name: 'Sveriges & Norges Järnvägar',
            logo: '18_scan/SNJ',
            simple_logo: '18_scan/SNJ.alt',
            tokens: [0, 40, 100],
            coordinates: 'B19',
            color: "#010301",
            reservation_color: nil,
            type: 'major',
          },
          {
            float_percent: 20,
            sym: 'NSB',
            name: 'Norges Statsbaner',
            logo: '18_scan/NSB',
            simple_logo: '18_scan/NSB.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'D7',
            color: "#041848",
            reservation_color: nil,
            type: 'major',
          },
          {
            float_percent: 20,
            sym: 'VR',
            name: 'Valtionraurariet',
            logo: '18_scan/VR',
            simple_logo: '18_scan/VR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G14',
            color: '#2157B2',
            reservation_color: nil,
            type: 'major',
          },
          {
            float_percent: 20,
            sym: 'SJ',
            name: 'Statens Järnvägar',
            logo: '18_scan/SJ',
            simple_logo: '18_scan/SJ.alt',
            tokens: [0, 100, 100, 100, 100, 100],
            coordinates: 'F3',
            color: "#3561AE",
            reservation_color: nil,
            type: 'national'
          },
        ].freeze
     end
    end
  end
end
