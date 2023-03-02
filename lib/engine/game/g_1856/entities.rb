# frozen_string_literal: true

module Engine
  module Game
    module G1856
      module Entities
        COMPANIES = [
          {
            name: 'Flos Tramway',
            sym: 'FT',
            value: 20,
            revenue: 5,
            desc: 'No special abilities.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['L3'] }],
            color: nil,
          },
          {
            name: 'Waterloo & Saugeen Railway Co.',
            sym: 'WSRC',
            value: 40,
            revenue: 10,
            desc: 'The public company that owns this private company may place a free station marker and/or '\
                  'green #59 tile on the Kitchener hex (I12). This action closes the private company.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['I12'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          when: 'track',
                          consume_tile_lay: true,
                          count: 1,
                          hexes: ['I12'],
                          tiles: ['59'],
                        },
                        {
                          type: 'token',
                          description: 'Token in Waterloo & Saugeen for free',
                          hexes: ['I12'],
                          count: 1,
                          price: 0,
                          teleport_price: 0,
                          from_owner: true,
                        }],
            color: nil,
          },
          {
            name: 'The Canada Company',
            sym: 'TCC',
            value: 50,
            revenue: 10,
            desc: 'During its operating turn, the public company owning this private company may place a '\
                  'track tile in the hex occupied by this private company (H11). This track lay is in addition to '\
                  'the public company\'s normal track lay. This action does not close the private company.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['H11'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          free: true,
                          hexes: ['H11'],
                          tiles: %w[3 4 58],
                          when: 'track',
                          count: 1,
                        }],
            color: nil,
          },
          {
            name: 'Great Lakes Shipping Company',
            sym: 'GLSC',
            value: 70,
            revenue: 15,
            desc: 'At any time during its operating turn, the owning public company may place the port marker in '\
                  'any one hex with the port symbol. The port marker raises the value of all revenue locations in that hex '\
                  'by $20 for that corporation. This marker may not be moved and will be removed when the first '\
                  '6 train is purchased. Placement of this marker closes the Great Lakes Shipping Company.',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[C14
                          D19
                          E18
                          F17
                          F9
                          H17
                          H7
                          H5
                          J17
                          J5
                          K2
                          M18
                          O18],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Niagara Falls Suspension Bridge Company',
            sym: 'NFSBC',
            value: 100,
            revenue: 20,
            desc: 'The public company that owns this private company may add a $10 bonus when running '\
                  'to Buffalo (P17/P19). Other public companies may purchase the right for $50.',
            color: nil,
          },
          {
            name: 'St. Clair Frontier Tunnel Company',
            sym: 'SCFTC',
            value: 100,
            revenue: 20,
            desc: 'The public company that owns this private company may add a $10 Port Huron bonus when running '\
                  'to Sarnia (B13). Other public companies may purchase the right for $50.',
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'BBG',
            logo: '1856/BBG',
            simple_logo: '1856/BBG.alt',
            name: 'Buffalo, Brantford & Goderich Railway',
            tokens: [0, 40, 100],
            coordinates: 'J15',
            color: '#ffd9eb',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'CA',
            logo: '1856/CA',
            simple_logo: '1856/CA.alt',
            name: 'Canada Air Line Railway',
            tokens: [0, 40, 100],
            coordinates: 'D17',
            color: '#f72d2d',
            reservation_color: nil,
          },
          {
            sym: 'CPR',
            logo: '1856/CPR',
            simple_logo: '1856/CPR.alt',
            name: 'Canadian Pacific Railroad',
            tokens: [0, 40, 100, 100],
            coordinates: 'M4',
            color: '#c474bc',
            reservation_color: nil,
          },
          {
            sym: 'CV',
            logo: '1856/CV',
            simple_logo: '1856/CV.alt',
            name: 'Credit Valley Railway',
            tokens: [0, 40, 100],
            coordinates: 'N11',
            city: 0,
            color: '#2d0047',
            reservation_color: nil,
          },
          {
            sym: 'GT',
            logo: '1856/GT',
            simple_logo: '1856/GT.alt',
            name: 'Grand Trunk Railway',
            tokens: [0, 40, 100, 100],
            coordinates: 'P9',
            color: '#78c292',
            reservation_color: nil,
          },
          {
            sym: 'GW',
            logo: '1856/GW',
            simple_logo: '1856/GW.alt',
            name: 'Great Western Railway',
            tokens: [0, 40, 100, 100],
            coordinates: 'F15',
            color: '#6e6966',
            reservation_color: nil,
          },
          {
            sym: 'LPS',
            logo: '1856/LPS',
            simple_logo: '1856/LPS.alt',
            name: 'London & Port Sarnia Railway',
            tokens: [0, 40],
            coordinates: 'C14',
            color: '#c3deeb',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'TGB',
            logo: '1856/TGB',
            simple_logo: '1856/TGB.alt',
            name: 'Toronto, Grey & Bruce Railway',
            tokens: [0, 40],
            coordinates: 'K8',
            color: '#c94d00',
            reservation_color: nil,
          },
          {
            sym: 'THB',
            logo: '1856/THB',
            simple_logo: '1856/THB.alt',
            name: 'Toronto, Hamilton and Buffalo Railway',
            tokens: [0, 40],
            coordinates: 'L15',
            color: '#ebff45',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            sym: 'WR',
            logo: '1856/WR',
            simple_logo: '1856/WR.alt',
            name: 'Welland Railway',
            tokens: [0, 40, 100],
            coordinates: 'O16',
            color: '#54230e',
            reservation_color: nil,
          },
          {
            sym: 'WGB',
            logo: '1856/WGB',
            simple_logo: '1856/WGB.alt',
            name: 'Wellington, Grey & Bruce Railway',
            tokens: [0, 40],
            coordinates: 'J11',
            color: '#494d99',
            reservation_color: nil,
          },
          {
            sym: 'CGR',
            logo: '1856/CGR',
            simple_logo: '1856/CGR.alt',
            name: 'Canadian Government Railway',
            tokens: [],
            color: '#000',
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter train buy/sell at face value',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 99,
                description: '3 train limit',
              },
              {
                type: 'borrow_train',
                train_types: %w[8 D],
                description: 'May borrow a train when trainless*',
              },
            ],
            reservation_color: nil,
          },
        ].freeze
      end
    end
  end
end
