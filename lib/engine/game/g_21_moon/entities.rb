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
                  'When sold to a corporation, the black SD token will be replaced by a token from the owning corporation. '\
                  'Can be sold to a corporation for ₡1.',
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
                  'a 2/3/4/5/6 train to/from the depot. If a train is added, it must be of the '\
                  'current phase or later. This will close the company. Can be sold to a corporation for ₡1-₡45.',
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
                  'made and the SBC will close. Can be sold to a corporation for ₡1-₡60.',
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
                  'token lasts until the end of the game. This will close the company. Can be sold to a corporation for ₡1-₡90.',
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
            revenue: 15,
            min_price: 1,
            max_price: 120,
            desc: 'The owning corporation may teleport place the T tile, then may place its cheapest supply '\
                  'depot on it. This closes the private company. Can be sold to a corporation for ₡1-₡120.',
            abilities: [
              {
                type: 'teleport',
                owner_type: 'corporation',
                tiles: ['X29'],
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
                  'discounted to 10 cost when owned by a corporation. Exchanging closes this company. '\
                  'Can be sold to a corporation for ₡1-₡150.',
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
            sym: 'SSF',
            name: 'Shamsum Solar Farms',
            logo: '21Moon/SSF',
            coordinates: 'D12',
            color: '#f7955b',
            text_color: 'white',
            tokens: [0, 25, 50],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'SWP',
            name: 'Suijin Water Plants',
            logo: '21Moon/SWP',
            coordinates: 'C7',
            color: '#00aeef',
            text_color: 'white',
            tokens: [0, 25, 50],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'HMQ',
            name: 'Hematite Low-G Mining and Quarry',
            logo: '21Moon/HMQ',
            coordinates: 'D2',
            color: '#ed1c24',
            text_color: 'white',
            tokens: [0, 25, 50, 75, 100],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'VH',
            name: 'Varuna Hydroculture',
            logo: '21Moon/VH',
            coordinates: 'G7',
            color: '#ffcc4e',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'ITC',
            name: 'International Tritium Consortum',
            logo: '21Moon/ITC',
            coordinates: 'I5',
            color: '#a368ab',
            text_color: 'white',
            tokens: [0, 25, 50, 75, 100],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'LG',
            name: 'Lunar Geodynamics',
            logo: '21Moon/LG',
            coordinates: 'I11',
            color: '#57bd7d',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
            always_market_price: true,
            treasury_as_holding: true,
          },
          {
            sym: 'KR',
            name: 'Kiviuq Rovertech',
            logo: '21Moon/KR',
            coordinates: 'K9',
            color: '#b59588',
            text_color: 'white',
            tokens: [0, 25, 50, 75, 100],
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
