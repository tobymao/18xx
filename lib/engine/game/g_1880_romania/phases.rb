# frozen_string_literal: true

module Engine
  module Game
    module G1880Romania
      module Phases
        PHASES = [
          { name: 'A1', train_limit: 4, tiles: [:yellow] },
          {
            name: 'A2',
            on: '2+2',
            train_limit: 4,
            tiles: %i[yellow],
          },
          {
            name: 'B1',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
          },
          {
            name: 'B2',
            on: '3+3',
            train_limit: 3,
            tiles: %i[yellow green],
          },
          {
            name: 'C1',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green brown],
          },
          {
            name: 'C2',
            on: '4+4',
            train_limit: 3,
            tiles: %i[yellow green brown],
          },
          {
            name: 'D1',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
          },
          {
            name: 'D2',
            on: '6E',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
          },
          {
            name: 'D3',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
          },
        ].freeze
      end
    end
  end
end
