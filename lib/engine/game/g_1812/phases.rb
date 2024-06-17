# frozen_string_literal: true

module Engine
  module Game
    module G1812
      module Phases
        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies minors_can_merge],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: %w[can_buy_companies minors_can_merge cannot_open_minors],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %w[can_par minors_can_merge cannot_open_minors tradeins_allowed],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %w[can_par minors_can_merge cannot_open_minors tradeins_allowed],
          },
        ].freeze
      end
    end
  end
end
