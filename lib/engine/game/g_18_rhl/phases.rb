# frozen_string_literal: true

module Engine
  module Game
    module G18Rhl
      module Phases
        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[incremental],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            status: %w[incremental],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            status: %w[incremental],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[fullcap],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[fullcap],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[fullcap],
            operating_rounds: 3,
          },
        ].freeze

        def game_phases
          self.class::PHASES
        end
      end
    end
  end
end
