# frozen_string_literal: true

module Engine
  module Game
    module G1848
      module Entities
        COMPANIES = [
          {
            sym: 'P1',
            name: "Melbourne & Hobson's Bay Railway Company",
            value: 30,
            min_price: 1,
            max_price: 40,
            revenue: 5,
            desc: 'No special abilities. Can be bought for £1-£40',
          },
          {
            sym: 'P2',
            name: 'Oodnadatta Railway',
            value: 70,
            min_price: 1,
            max_price: 80,
            revenue: 10,
            desc: 'Owning Public Company or its Director may build one (1) free tile on a desert hex (marked by'\
                  ' a cactus icon). This power does not go away after a 5/5+ train is purchased. Can be bought for £1-£80 ',
            abilities: [
                    {
                      type: 'tile_lay',
                      discount: 40,
                      hexes: %w[B3 B7 B9 C2 C4 C8 E6 E8],
                      tiles: %w[7 8 9],
                      count: 1,
                      reachable: true,
                      consume_tile_lay: true,
                      owner_type: 'corporation',
                      when: 'owning_corp_or_turn',
                    },
                    {
                      type: 'tile_lay',
                      discount: 40,
                      hexes: %w[B3 B7 B9 C2 C4 C8 E6 E8],
                      tiles: %w[7 8 9],
                      count: 1,
                      reachable: true,
                      consume_tile_lay: true,
                      owner_type: 'player',
                      when: 'owning_player_or_turn',
                    },
                  ],
          },
          {
            sym: 'P3',
            name: 'Tasmanian Railways',
            value: 110,
            min_price: 1,
            max_price: 140,
            revenue: 15,
            desc: 'The Tasmania tile can be placed by a Public Company on one of the two blue hexes (I8, I10). This is in'\
                  " addition to the company's normal build that turn. Can be bought for £1-£140",
            abilities: [
                    {
                      type: 'tile_lay',
                      hexes: %w[I8 I10],
                      tiles: %w[241],
                      owner_type: 'corporation',
                      when: 'owning_corp_or_turn',
                      special: true,
                      count: 1,
                      free: true,
                    },
                  ],

          },
          {
            sym: 'P4',
            name: 'The Ghan',
            value: 170,
            discount: 0,
            min_price: 1,
            max_price: 220,
            revenue: 20,
            desc: 'Owning Public Company or its Director may receive a one-time discount of £100 on the purchase'\
                  ' of a 2E (Ghan) train. This power does not go away after a 5/5+ train is purchased. Can be bought for £1-£220',
            abilities: [
                    {
                      type: 'train_discount',
                      discount: 100,
                      trains: ['2E'],
                      count: 1,
                      owner_type: 'corporation',
                      when: 'buying_train',
                    },
                    {
                      type: 'train_discount',
                      discount: 100,
                      trains: ['2E'],
                      count: 1,
                      owner_type: 'player',
                      when: 'buying_train',
                    },
                  ],

          },
          {
            sym: 'P5',
            name: 'Trans-Australian Railway',
            value: 170,
            revenue: 25,
            desc: 'The owner receives a 10% share in the QR. Cannot be bought by a corporation',
            abilities: [{ type: 'shares', shares: 'QR_1' },
                        { type: 'no_buy' }],
          },
          {
            sym: 'P6',
            name: 'North Australian Railway',
            value: 230,
            revenue: 30,
            desc: "The owner receives a Director's Share share in the CAR, which must start at a par value of £100."\
                  ' Cannot be bought by a corporation. Closes when CAR purchases its first train.',
            abilities: [{ type: 'shares', shares: 'CAR_0' },
                        { type: 'no_buy' },
                        { type: 'close', when: 'bought_train', corporation: 'CAR' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'BOE',
            name: 'Bank of England',
            logo: '1848/BOE',
            simple_logo: '1848/BOE.alt',
            tokens: [],
            text_color: 'black',
            type: 'bank',
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'antiqueWhite',
          },
          {
            sym: 'CAR',
            name: 'Central Australian Railway',
            logo: '1848/CAR',
            simple_logo: '1848/CAR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'E4',
            color: 'black',
          },
          {
            sym: 'VR',
            name: 'Victorian Railways',
            logo: '1848/VR',
            simple_logo: '1848/VR.alt',
            tokens: [0, 40, 100],
            coordinates: 'H11',
            text_color: 'black',
            color: '#ffe600',
          },
          {
            sym: 'NSW',
            name: 'New South Wales Railways',
            logo: '1848/NSW',
            simple_logo: '1848/NSW.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F17',
            text_color: 'black',
            color: '#ff9027',
          },
          {
            sym: 'SAR',
            name: 'South Australian Railway',
            logo: '1848/SAR',
            simple_logo: '1848/SAR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G6',
            color: '#9e2a97',
          },
          {
            sym: 'COM',
            name: 'Commonwealth Railways',
            logo: '1848/COM',
            simple_logo: '1848/COM.alt',
            tokens: [0, 0, 100, 100, 100],
            text_color: 'black',
            color: '#cfc5a2',
          },
          {
            sym: 'FT',
            name: 'Federal Territory Railway',
            logo: '1848/FT',
            simple_logo: '1848/FT.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G14',
            text_color: 'black',
            color: '#55c3ec',
          },
          {
            sym: 'WA',
            name: 'West Australian Railway',
            logo: '1848/WA',
            simple_logo: '1848/WA.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'D1',
            color: '#ee332a',
          },
          {
            sym: 'QR',
            name: "Queensland Gov't Railway",
            logo: '1848/QR',
            simple_logo: '1848/QR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'B19',
            color: '#399c42',
          },
        ].freeze
      end
    end
  end
end
