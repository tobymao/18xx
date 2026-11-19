# frozen_string_literal: true

module Engine
  module Game
    module G1832
      module Phases
        EARLY_PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: %w[first_miami_run_is_zero],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_place_miami_token first_miami_run_is_zero],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_place_miami_token first_miami_run_is_zero mergers_allowed],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[mergers_allowed can_place_miami_token],
          },
        ].freeze

        STANDARD_LATE_PHASES = [
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[can_place_miami_token],
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '12',
            on: '12',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        DIESEL_LATE_PHASES = [
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[can_place_miami_token],
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze
      end
    end
  end
end
