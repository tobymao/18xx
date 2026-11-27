# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Phases
        PHASES = [
          {
            name: 'E1',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: 'E2',
            on: '4H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: 'E3',
            on: '5H',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: 'E4',
            on: '6H',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['can_buy_companies'],
          },
          {
            name: 'E5',
            on: '7H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['can_buy_companies'],
          },
          {
            name: 'E6',
            on: '8H',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: ['can_buy_companies'],
          },
        ].freeze
      end
    end
  end
end
