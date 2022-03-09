# frozen_string_literal: true

module Engine
  module Game
    module G18MT
      module Phases
        PHASES = [{
          name: '2',
          train_limit: 4,
          tiles: [:yellow],
          status: ['extra_tile_lays'],
          operating_rounds: 2,
        },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    status: %w[extra_tile_lays can_buy_companies],
                    operating_rounds: 2,
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    status: %w[extra_tile_lays can_buy_companies],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    status: [],
                    operating_rounds: 2,
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    status: ['corporate_shares_open'],
                    operating_rounds: 2,
                  },
                  {
                    name: '7',
                    on: 'E',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    status: ['corporate_shares_open'],
                    operating_rounds: 2,
                  }].freeze
      end
    end
  end
end
