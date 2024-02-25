# frozen_string_literal: true

module Engine
  module Game
    module G1854
      module Phases
        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4, lokalbahn: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4, lokalbahn: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3, lokalbahn: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze
      end
    end
  end
end
