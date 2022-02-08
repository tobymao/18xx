# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G21Moon
      module Entities
        COMPANIES = [
          {
            name: 'Old Landing Site',
            sym: 'OLS',
            value: 30,
            revenue: 0,
            min_price: 1,
            max_price: 1,
            desc: 'When buying the private, a player must immediately place the black “SD” token on any '\
                  'mineral resource hex on the board in which the black “SD” token blocks an SD spot. '\
                  'A player owning OLS can sell it to corporation for 1 credit. When sold to a corporation, '\
                  'the black SD token will be replaced by a token from the owning corporation. '\
                  'The buyer of the OLS automatically gets last place in SR 1 turn order.',
            abilities: [],
            color: nil,
          },
          {
            name: 'UN Contract',
            sym: 'UNC',
            value: 30,
            revenue: 5,
            min_price: 1,
            max_price: 45,
            desc: 'When this private is bought by a company, the president of the company may choose to add or remove '\
                  'a 3/4/5/6 train to/from the depot. If a train is added, it must be of the '\
                  'current phase or later.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Space Bridge Company',
            sym: 'SBC',
            value: 40,
            revenue: 10,
            min_price: 1,
            max_price: 60,
            desc: 'The corporation owning the SBC can build and upgrade road tiles crossing the rift. '\
                  'The owning company receives a bonus of 60 credits after the connection across the rift is '\
                  'made for the first time.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Research Lab',
            sym: 'RL',
            value: 60,
            revenue: 10,
            min_price: 1,
            max_price: 90,
            desc: 'The owning corporation may place the +20 marker on a mineral or Home Base hex. The +20 '\
                  'token lasts until the end of the game.',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[A7 A9 B4 B12 C7 D2 D10 D12 E5 E15 F2 F8 G7 G13 H2 H10 I5 I7 I11 J2 J10 K5 K9 K13 L10],
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Terminal',
            sym: 'T',
            value: 80,
            revenue: 10,
            min_price: 1,
            max_price: 120,
            desc: 'The owning corporation may teleport place the T tile, then may place its cheapest supply '\
                  'depot on it. This closes the private company',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'corporation',
                tiles: ['X30'],
                hexes: ['F8'],
              },
            ],
            color: nil,
          },
          {
            name: 'Tunnel Company',
            sym: 'TC',
            value: 100,
            revenue: 15,
            min_price: 1,
            max_price: 150,
            desc: 'The owning player or corporation may take one share from the pool for free (may be '\
                  'used once per game, cannot be used in first stock round). In addition, mountain terrain is '\
                  'discounted to 10 cost when owned by a corporation',
            abilities: [
              {
                type: 'exchange',
                corporations: 'any',
                from: 'market',
                count: 1,
              },
              {
                type: 'tile_discount',
                discount: 10,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'OLS',
            name: 'Old Landing Site',
            logo: '21Moon/OLS',
            color: 'black',
            tokens: [0],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'MV',
            name: 'Moon Venture Corporation',
            logo: '21Moon/MV',
            coordinates: 'D12',
            color: 'brown',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'ME',
            name: 'Minerals Express Corporation',
            logo: '21Moon/ME',
            coordinates: 'C7',
            color: 'gray',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'MA',
            name: 'Mining Alliance Corporation',
            logo: '21Moon/MA',
            coordinates: 'D2',
            color: 'skyblue',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'DSE',
            name: 'Deep Space Explorers Corporation',
            logo: '21Moon/DSE',
            coordinates: 'G7',
            color: 'green',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'SM',
            name: 'Space Mining Corporation',
            logo: '21Moon/SM',
            coordinates: 'I5',
            color: 'tan',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'IC',
            name: 'Intergalactic Corporation',
            logo: '21Moon/IC',
            coordinates: 'I11',
            color: 'purple',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'LP',
            name: 'Lunar Power Corporation',
            logo: '21Moon/LP',
            coordinates: 'K9',
            color: 'violet',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
        ].freeze
      end
    end
  end
end
