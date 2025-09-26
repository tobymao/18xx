# frozen_string_literal: true

module Engine
  module Game
    module G1804
      module Entities
        COMPANIES = [
          {
            name: 'Ankara Penthouse',
            sym: 'AP',
            value: 30,
            revenue: 0,
            color: nil,
          },
          {
            name: 'Book Deal',
            sym: 'BD',
            value: 60,
            revenue: 5,
            color: nil,
          },
          {
            name: 'Cessna Lease',
            sym: 'CL',
            value: 60,
            revenue: 10,
            color: nil,
          },
          {
            name: 'Vox Media Stake',
            sym: 'VMS',
            value: 60,
            revenue: 20,
            color: nil,
          },
          {
            name: 'Black, Manafort, Stone, and Kelly',
            sym: 'BMSK',
            value: 60,
            revenue: 40,
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'AC',
            name: 'Amanda Clarke',
            logo: '1804/AC.alt',
            simple_logo: '1804/AC.alt',
            tokens: [0, 100, 100],
            max_ownership_percent: 70,
            coordinates: 'G12',
            color: '#ADD8E6',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'BS',
            name: 'Barry Stein',
            logo: '1804/BS.alt',
            simple_logo: '1804/BS.alt',
            tokens: [0, 100, 100],
            max_ownership_percent: 70,
            coordinates: 'E2',
            color: :'#32763f',
          },
          {
            float_percent: 60,
            sym: 'CK',
            name: 'Charlotte Kim',
            logo: '1804/CK.alt',
            simple_logo: '1804/CK.alt',
            tokens: [0, 100, 100],
            max_ownership_percent: 70,
            coordinates: 'B13',
            color: '#474548',
          },
          {
            float_percent: 60,
            sym: 'DT',
            name: 'David Tusk',
            logo: '1804/DT.alt',
            simple_logo: '1804/DT.alt',
            tokens: [0, 100, 100],
            max_ownership_percent: 70,
            coordinates: 'J7',
            color: '#d1232a',
          },
          {
            float_percent: 60,
            sym: 'EM',
            name: 'Emily MacGregor',
            logo: '1804/EM.alt',
            simple_logo: '1804/EM.alt',
            tokens: [0, 100, 100],
            max_ownership_percent: 70,
            coordinates: 'D7',
            color: :'#025aaa',
          },
          {
            float_percent: 60,
            sym: 'FA',
            name: 'Firoz Anand',
            logo: '1804/FA.alt',
            simple_logo: '1804/FA.alt',
            tokens: [0, 100, 100],
            max_ownership_percent: 70,
            coordinates: 'I16',
            color: :'#FFF500',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'GP',
            name: 'Greg Pope',
            logo: '1804/GP.alt',
            simple_logo: '1804/GP.alt',
            tokens: [0, 100, 100],
            max_ownership_percent: 70,
            coordinates: 'J13',
            color: :'#d88e39',
          },
          {
            float_percent: 60,
            sym: 'HW',
            name: 'Henry Washington',
            logo: '1804/HW.alt',
            simple_logo: '1804/HW.alt',
            tokens: [0, 100, 100],
            max_ownership_percent: 70,
            coordinates: 'F7',
            color: :'#95c054',
          },
        ].freeze
      end
    end
  end
end
