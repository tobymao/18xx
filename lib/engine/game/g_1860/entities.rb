# frozen_string_literal: true

module Engine
  module Game
    module G1860
      module Entities
        COMPANIES = [
          {
            name: 'Brading Harbour Company',
            value: 30,
            revenue: 5,
            desc: 'Can be exchanged for a share in the BHI&R corporation',
            sym: 'BHC',
            abilities: [
            {
              type: 'exchange',
              corporations: ['BHI&R'],
              owner_type: 'player',
              from: 'ipo',
            },
          ],
            color: nil,
          },
          {
            name: 'Yarmouth Harbour Company',
            value: 50,
            revenue: 10,
            desc: 'Can be exchanged for a share in the FYN corporation.',
            sym: 'YHC',
            abilities: [
              {
                type: 'exchange',
                corporations: ['FYN'],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
            color: nil,
          },
          {
            name: 'Cowes Marina and Harbour',
            value: 90,
            revenue: 20,
            desc: 'Can be exchanged for a share in the C&N corporation.',
            sym: 'CMH',
            abilities: [
              {
                type: 'exchange',
                corporations: ['C&N'],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
            color: nil,
          },
          {
            name: 'Ryde Pier & Shipping Company',
            value: 130,
            revenue: 30,
            desc: 'Can be exchanged for a share in the IOW corporation.',
            sym: 'RPSC',
            abilities: [
              {
                type: 'exchange',
                corporations: ['IOW'],
                owner_type: 'player',
                from: 'ipo',
              },
            ],
            color: nil,
          },
          {
            name: 'Fishbourne Ferry Company',
            value: 200,
            revenue: 25,
            desc: 'Not available until the first 6+3 train has been purchased. Closes all other private companies.',
            sym: 'FFC',
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'C&N',
            name: 'Cowes & Newport',
            logo: '1860/CN',
            simple_logo: '1860/CN.alt',
            float_percent: 50,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'F2',
            color: :deepskyblue,
            text_color: 'black',
          },
          {
            sym: 'IOW',
            name: 'Isle of Wight',
            logo: '1860/IOW',
            simple_logo: '1860/IOW.alt',
            float_percent: 50,
            max_ownership_percent: 100,
            tokens: [0, 40, 100, 100],
            coordinates: 'I3',
            color: '#ff0000',
          },
          {
            sym: 'IWNJ',
            name: 'Isle of Wight, Newport Junction',
            logo: '1860/IWNJ',
            simple_logo: '1860/IWNJ.alt',
            float_percent: 50,
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'G7',
            color: '#000000',
          },
          {
            sym: 'FYN',
            name: 'Freshwater, Yarmouth & Newport',
            logo: '1860/FYN',
            simple_logo: '1860/FYN.alt',
            float_percent: 50,
            max_ownership_percent: 100,
            tokens: [0, 40, 100],
            coordinates: 'B4',
            color: :green,
          },
          {
            sym: 'NGStL',
            name: 'Newport, Godshill & St. Lawrence',
            logo: '1860/NGStL',
            simple_logo: '1860/NGStL.alt',
            float_percent: 50,
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'G9',
            color: :yellow,
            text_color: 'black',
          },
          {
            sym: 'BHI&R',
            name: 'Brading Harbour Improvement & Railway',
            logo: '1860/BHIR',
            simple_logo: '1860/BHIR.alt',
            float_percent: 50,
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'L6',
            color: :darkmagenta,
          },
          {
            sym: 'S&C',
            name: 'Shanklin & Chale',
            logo: '1860/SC',
            simple_logo: '1860/SC.alt',
            float_percent: 50,
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'F12',
            color: :darkblue,
          },
          {
            sym: 'VYSC',
            name: 'Ventor, Yarmouth & South Coast',
            logo: '1860/VYSC',
            simple_logo: '1860/VYSC.alt',
            float_percent: 50,
            max_ownership_percent: 100,
            tokens: [0, 40],
            coordinates: 'E9',
            color: :yellowgreen,
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
