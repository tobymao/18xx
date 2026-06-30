# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Phases
        PHASES = [
          {
            name: 'E1',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['era_e1'],
          },
          {
            name: 'E2',
            on: 'V3',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[era_e2 can_buy_companies],
          },
          {
            name: 'E3',
            on: 'V4',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: %w[era_e3 can_buy_companies],
          },
          {
            name: 'E4',
            on: 'VE',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: %w[era_e4 can_buy_companies],
          },
        ].freeze
      end
    end
  end
end
