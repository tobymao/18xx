# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1825
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_DESIGNER = 'Francis Tresham'
        GAME_INFO_URL = 'https://google.com'
        GAME_LOCATION = 'United Kingdom'
        GAME_RULES_URL = 'http://google.com'

        PLAYER_RANGE = [2, 8].freeze
        OPTIONAL_RULES = [
          {
            sym: :unit_1,
            short_name: 'Unit 1',
            desc: '2-5 players',
          },
          {
            sym: :unit_2,
            short_name: 'Unit 2',
            desc: '2-3 players',
          },
          {
            sym: :unit_3,
            short_name: 'Unit 3',
            desc: '2 players',
          },
          {
            sym: :unit_12,
            short_name: 'Units 1+2',
            desc: '3-7 players',
          },
          {
            sym: :unit_23,
            short_name: 'Units 2+3',
            desc: '3-5 players',
          },
          {
            sym: :unit_123,
            short_name: 'Units 1+2+3',
            desc: '4-8 players',
          },
          {
            sym: :r1,
            short_name: 'R1',
            desc: 'Regional Kit 1 - Wales',
          },
          {
            sym: :r2,
            short_name: 'R2',
            desc: 'Regional Kit 2 - South West England',
          },
          {
            sym: :r3,
            short_name: 'R3',
            desc: 'Regional Kit 3 - North Norfolk',
          },
          {
            sym: :k1,
            short_name: 'K1',
            desc: 'Extension Kit 1 - Suplementary Tiles',
          },
          {
            sym: :k2,
            short_name: 'K2',
            desc: 'Extension Kit 2 - Advanced Trains',
          },
          {
            sym: :k3,
            short_name: 'K3',
            desc: 'Extension Kit 3 - Phase Four',
          },
          {
            sym: :k5,
            short_name: 'K5',
            desc: 'Extension Kit 5 - Minors for Unit 2',
          },
          {
            sym: :k6,
            short_name: 'K6',
            desc: 'Extension Kit 6 - Advanced Tiles',
          },
          {
            sym: :k7,
            short_name: 'K7',
            desc: 'Extension Kit 7 - London, Tilbury and Southend Railway',
          },
          {
            sym: :big_bank,
            short_name: 'BigBank',
            desc: 'When combining units, add banks from each unit',
          },
          {
            sym: :strict_bank,
            short_name: 'StrictBank',
            desc: 'Do not increase bank size based on number of minors and kits',
          },
        ].freeze
      end
    end
  end
end
