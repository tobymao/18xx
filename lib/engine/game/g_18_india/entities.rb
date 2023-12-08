# frozen_string_literal: true

module Engine
  module Game
    module G18India
      module Entities
        COMPANIES = [
          {
            name: 'Swedish EIC',
            sym: 'P1',
            value: 25,
            revenue: 5,
            desc: 'No special abilities.',
            color: nil,
          },
          {
            name: 'Portuguese EIC',
            sym: 'P2',
            value: 35,
            revenue: 5,
            desc: 'One extra yellow tile placement. Close when used.',
            color: nil,
            # TODO: Add Ability
          },
          {
            name: 'Dutch EIC',
            sym: 'P3',
            value: 60,
            revenue: 10,
            desc: 'One extra track upgade. Close when used.',
            color: nil,
            # TODO: Add Ability
          },
          {
            name: 'French EIC',
            sym: 'P4',
            value: 75,
            revenue: 15,
            desc: '$40 Terrain cost discount. Close when used.',
            color: nil,
            # TODO: Add Ability
          },
          {
            name: 'Danish EIC',
            sym: 'P5',
            value: 115,
            revenue: 20,
            desc: 'One free station, even if full. Close when used.',
            color: nil,
            # TODO: Add Ability
          },
          {
            name: 'British EIC',
            sym: 'P6',
            value: 150,
            revenue: 25,
            desc: 'Receives jewlery concession. Close when used.',
            color: nil,
            # TODO: Add Ability
          },
        ].freeze

        CORPORATIONS = [
          {
            name: 'Great Indian Peninsula Railway',
            sym: 'GIPR',
            logo: '18_india/GIPR',
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            tokens: [0, 40, 100, 100],
            # Add Exchange Tokens
            # No president cert / Pres cert is 10%
            # par_price: 112
            float_percent: 30,
            max_ownership_percent: 100,
            # Can start in any open city
            # coordinates: '',
            color: 'white',
          },
          {
            name: 'Northwestern Railway',
            sym: 'NWR',
            logo: '18_india/NWR',
            tokens: [0, 40, 100, 100],
            # par_price: 100
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'G8', # Delhi
            color: '#000000', # green
          },
          {
            name: 'East India Railway',
            sym: 'EIR',
            logo: '18_india/EIR',
            tokens: [0, 40, 100],
            # par_price: 100
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'P17', # Kolkata
            color: '#000000', # orange
          },
          {
            name: 'North Central Railway',
            sym: 'NCR',
            logo: '18_india/NCR',
            tokens: [0, 40, 100, 100],
            # par_price: 90
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'K14', # Allahabad
            color: '#000000', # light brown / tan
          },
          {
            name: 'Madras Railway',
            sym: 'MR',
            logo: '18_india/MR',
            tokens: [0, 40, 100],
            # par_price: 90
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'K30', # Chennai
            color: '#000000', # yellow
          },
          {
            name: 'South Indian Railway',
            sym: 'SIR',
            logo: '18_india/SIR',
            tokens: [0, 40, 100, 100],
            # par_price: 82
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'G36', # Kochi
            color: '#000000', # dark red/brown
          },
          {
            name: 'Bengal Nagur Railway',
            sym: 'BNR',
            logo: '18_india/BNR',
            tokens: [0, 40, 100, 100, 100],
            # par_price: 82
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'I20', # Nagpur
            color: 'brown',
          },
          {
            name: 'Ceylon Government Railway',
            sym: 'CGR',
            logo: '18_india/CGR',
            tokens: [0, 40, 100],
            # par_price: 76
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'K40', # Colombo
            color: '#000000', # Light Purple
          },
          {
            name: 'Punjab Northern State Railway',
            sym: 'PNS',
            logo: '18_india/PNS',
            tokens: [0, 40, 100],
            # par_price: 76
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'D3', # Lahore
            color: '#000000', # light green
          },
          {
            name: 'West of India Portuguese Railway',
            sym: 'WIP',
            logo: '18_india/WIP',
            tokens: [0, 40, 100],
            # par_price: 76
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'E24', # Pune
            color: '#000000', # pink
          },
          {
            name: 'Eastern Bengal Railway',
            sym: 'EBR',
            logo: '18_india/EBR',
            tokens: [0, 40, 100],
            # par_price: 76
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'P17', # Kolkata
            color: '#000000', # gray
          },
          {
            name: 'Bombay Railway',
            sym: 'BR',
            logo: '18_india/BR',
            tokens: [0, 40, 100],
            # par_price: 71
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'D23', # Mumbai
            color: 'purple',
          },
          {
            name: 'Nizam State Railway',
            sym: 'NSR',
            logo: '18_india/NSR',
            tokens: [0, 40, 100],
            # par_price: 71
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'H25', # Hyderabad
            color: '#000000', # medium blue
          },
          {
            name: 'Tirhoot Railway',
            sym: 'TR',
            logo: '18_india/TR',
            tokens: [0, 40],
            # par_price: 71
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'M10', # Nepal
            color: '#000000', # black
          },
          {
            name: 'Sind Punjab & Delhi Railroad',
            sym: 'SPD',
            logo: '18_india/SPD',
            tokens: [0, 40],
            # par_price: 67
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'G8', # Delhi
            color: '#000000', # tan
          },
          {
            name: 'Darjeeling-Himalayan Railway',
            sym: 'DHR',
            logo: '18_india/DHR',
            tokens: [0, 40],
            # par_price: 67
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'Q10', # China
            color: '#000000', # dark green
          },
          {
            name: 'Western Railway',
            sym: 'WR',
            logo: '18_india/WR',
            tokens: [0, 40],
            # par_price: 64
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'D17', # Ahmedabad
            color: '#000000', # dark blue
          },
          {
            name: 'Kolar Gold Fields Railways',
            sym: 'KGF',
            logo: '18_india/KGF',
            tokens: [0, 40],
            # par_price: 64
            float_percent: 30,
            max_ownership_percent: 100,
            coordinates: 'H31', # Bengaluru
            color: '#000000', # red
          },
        ].freeze
      end
    end
  end
end
