# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18Texas
      module Entities
        COMPANIES = [
          {
            name: 'Buffalo Bayou, Brazos and Colorado Railway Company',
            value: 50,
            revenue: 10,
            desc: 'No special ability',
            sym: 'A',
          },
          {
            name: 'Galveston and Red River Railway Company',
            value: 80,
            revenue: 20,
            desc: 'No special ability',
            sym: 'B',
          },          {
            name: 'Jay Gould',
            value: 200,
            revenue: 5,
            abilities: [{ type: 'shares', shares: 'random_president' }],
            sym: 'C',
          },          {
            name: 'International–Great Northern',
            value: 210,
            revenue: 30,
            abilities: [{ type: 'shares', shares: 'match_share' }],
            min_players: 4,
            sym: 'D',
          },          {
            name: 'New Orleans Pacific Railroad',
            value: 240,
            revenue: 40,

            abilities: [{ type: 'shares', shares: 'match_share' }],
            min_players: 5,
            sym: 'E',
          }
        ].freeze

        CORPORATIONS = [
         {
           float_percent: 50,
           sym: 'T&P',
           name: 'Texas and Pacific Railway',
           logo: '18_texas/TP',
           tokens: [0, 0, 0, 0, 0],
           city: 1,
           coordinates: 'D9',
           color: 'darkmagenta',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'MKT',
           name: 'Missouri–Kansas–Texas Railway',
           logo: '18_texas/MKT',
           tokens: [0, 0, 0, 0],
           coordinates: 'B11',
           color: 'green',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SP',
           name: 'Southern Pacific Railroad',
           logo: '18_texas/SP',
           tokens: [0, 0, 0, 0, 0],
           coordinates: 'I14',
           color: 'orange',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'MP',
           name: 'Missouri Pacific Railroad',
           logo: '18_texas/MP',
           tokens: [0, 0, 0, 0],
           coordinates: 'G10',
           color: 'red',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SSW',
           name: 'St. Louis Southwestern Railway',
           logo: '18_texas/SSW',
           tokens: [0, 0, 0],
           coordinates: 'D15',
           color: 'mediumpurple',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SAA',
           name: 'San Antonio and Aransas Pass',
           logo: '18_texas/SAA',
           tokens: [0, 0, 0],
           coordinates: 'J5',
           color: 'black',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
       ].freeze
      end
    end
  end
end
