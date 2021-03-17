# frozen_string_literal: true

module Engine
  module Game
    module G18Neb
      module Config
        module CorporationConfig
          CORPORATIONS = [
            {
              float_percent: 20,
              sym: 'UP',
              name: 'Union Pacific',
              logo: '18_neb/UP',
              tokens: [0, 40, 100],
              coordinates: 'K7',
              color: '#376FFF',
              always_market_price: true,
              reservation_color: nil,
            },
            {
              float_percent: 20,
              sym: 'CBQ',
              name: 'Chicago Burlington & Quincy',
              logo: '18_neb/CBQ',
              tokens: [0, 40, 100, 100],
              coordinates: 'L6',
              color: '#666666',
              always_market_price: true,
              reservation_color: nil,
            },
            {
              float_percent: 20,
              sym: 'CNW',
              name: 'Chicago & Northwestern',
              logo: '18_neb/CNW',
              tokens: [0, 40, 100],
              coordinates: 'L4',
              color: '#2C9846',
              always_market_price: true,
              reservation_color: nil,
            },
            {
              float_percent: 20,
              sym: 'DRG',
              name: 'Denver & Rio Grande',
              logo: '18_neb/DRG',
              tokens: [0, 40],
              coordinates: 'C9',
              color: '#D4AF37',
              text_color: 'black',
              always_market_price: true,
              reservation_color: nil,
            },
            {
              float_percent: 20,
              sym: 'MP',
              name: 'Missouri Pacific',
              logo: '18_neb/MP',
              tokens: [0, 40, 100],
              coordinates: 'L12',
              color: '#874301',
              reservation_color: nil,
              always_market_price: true,
            },
            {
              float_percent: 20,
              sym: 'C&S',
              name: 'Colorado & Southern',
              logo: '18_neb/CS',
              tokens: [0, 40, 100, 100],
              coordinates: 'A7',
              color: '#AE4A84',
              always_market_price: true,
              reservation_color: nil,
            },
            {
              float_percent: 40,
              sym: 'OLB',
              name: 'Omaha, Lincoln & Beatrice',
              logo: '18_neb/OLB',
              shares: [40, 20, 20, 20],
              tokens: [0, 40],
              coordinates: 'K7',
              max_ownership_percent: 100,
              color: '#F40003',
              type: 'local',
              always_market_price: true,
              reservation_color: nil,
            },
            {
              float_percent: 40,
              sym: 'NR',
              name: 'NebKota',
              logo: '18_neb/NR',
              shares: [40, 20, 20, 20],
              tokens: [0, 40],
              coordinates: 'C3',
              max_ownership_percent: 100,
              color: '#000000',
              type: 'local',
              always_market_price: true,
              reservation_color: nil,
            },
          ].freeze
        end
      end
    end
  end
end
