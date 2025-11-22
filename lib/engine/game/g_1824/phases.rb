# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module Phases
        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: { coal: 2, minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { coal: 2, minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[may_exchange_coal_railways
                       may_exchange_mountain_railways],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { coal: 2, minor: 2, major: 3, national: 4 },
            tiles: %i[yellow green],
            status: %w[may_exchange_coal_railways],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { minor: 2, major: 3, national: 4 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            # Minor is not available in phase 6, but as merge to Staatsbahn
            # happens at end of OR, we can let minor keep its 2 trains
            train_limit: { minor: 2, major: 2, national: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            # Similar to phase 6, it is possible to reach phase 8 while minor
            # still remains (merged at the end of OR)
            train_limit: { minor: 2, major: 2, national: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            # See phase 8
            train_limit: { minor: 2, major: 2, national: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze
      end
    end
  end
end
