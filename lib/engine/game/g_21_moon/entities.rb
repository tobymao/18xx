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
            desc: 'When buying the private, the investor must immediately place the black “SD” token on any '\
            'mineral resource hex on the board in which the black “SD” token blocks an SD spot. If the hex is '\
            'a double dot minerals hex, the owner of the black “SD” token selects first which spot to occupy '\
            'when the first tile is placed. An investor owning The Old Landing Site can sell it to corporation '\
            'for 1 credit. If sold to a corporation, the black SD token will function as a fourth supply '\
            'depot for that corporation by replacing the black SD token with another black token with the '\
            'correct corporate sticker on it. The buyer of the OLS automatically gets last place in SR 1 turn '\
            'order.',
            abilities: [],
            color: nil,
          },
          {
            name: 'UN Contract',
            sym: 'UNC',
            value: 30,
            revenue: 5,
            desc: 'No special powers',
            abilities: [],
            color: nil,
          },
          {
            name: 'Space Bridge Company',
            sym: 'SBC',
            value: 40,
            revenue: 10,
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
            desc: 'The owning corporation may place the +20 marker on a mineral or base camp hex. The +20 '\
            'token lasts until the end of the game.',
            abilities: [],
            color: nil,
          },
          {
            name: 'Space Port',
            sym: 'SP',
            value: 80,
            revenue: 10,
            desc: 'The owning corporation may teleport place SP tile, then may place cheapest supply depot on it. '\
            'This closes the private company',
            abilities: [],
            color: nil,
          },
          {
            name: 'Tunnel Company',
            sym: 'TC',
            value: 100,
            revenue: 15,
            desc: 'The owning player or corporation may take one share from the pool for free (may be '\
            'used once per game, cannot be used in first stock round). In addition, mountain terrain is '\
            'discounted to 10 cost when owned by a corporation',
            abilities: [],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'MV',
            name: 'Moon Venture Corporation',
            logo: '21Moon/MV',
            color: 'brown',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
          },
          {
            sym: 'ME',
            name: 'Minerals Express Corporation',
            logo: '21Moon/ME',
            color: 'gray',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
          },
          {
            sym: 'MA',
            name: 'Mining Alliance Corporation',
            logo: '21Moon/MA',
            color: 'skyblue',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
          },
          {
            sym: 'DSE',
            name: 'Deep Space Explorers Corporation',
            logo: '21Moon/DSE',
            color: 'green',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
          },
          {
            sym: 'SM',
            name: 'Space Mining Corporation',
            logo: '21Moon/SM',
            color: 'tan',
            text_color: 'black',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
          },
          {
            sym: 'I',
            name: 'Intergalactic Corporation',
            logo: '21Moon/I',
            color: 'purple',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
          },
          {
            sym: 'LP',
            name: 'Lunar Power Corporation',
            logo: '21Moon/LP',
            color: 'violet',
            tokens: [0, 25, 50, 75],
            float_percent: 50,
            max_ownership_percent: 50,
          },
        ].freeze
      end
    end
  end
end
