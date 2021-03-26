# frozen_string_literal: true

require_relative '../g_1849/map'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Ireland
      class Game < Game::Base
        include_meta(G18Ireland::Meta)
        include G18Ireland::Entities
        include G1849::Map
        include G18Ireland::Map

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :float

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 4000

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 330, 4 => 250, 5 => 200, 6 => 160 }.freeze

        LIMIT_TOKENS_AFTER_MERGER = 3

        MARKET = [
          ['', '62', '68', '76', '84', '92', '100p', '110', '122', '134', '148', '170', '196', '225', '260e'],
          ['', '58', '64', '70', '78', '85p', '94', '102', '112', '124', '136', '150', '172', '198'],
          ['', '55', '60', '65', '70p', '78', '86', '95', '104', '114', '125', '138'],
          ['', '50', '55', '60p', '66', '72', '80', '88', '96', '106'],
          ['', '38y', '50p', '55', '60', '66', '72', '80'],
          ['', '30y', '38y', '50', '55', '60'],
          ['', '24y', '30y', '38y', '50'],
          %w[0c 20y 24y 30y 38y],
        ].freeze

        # @todo: these are wrong
        PHASES = [
          {
            name: '2',
            train_limit: 2,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4H',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '6',
            on: '6H',
            train_limit: { minor: 2, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '8',
            on: '8H',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '10',
            on: '10H',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        # @todo: how to do the opposite side
        # rusts turns them to the other side, go into the bankpool obsolete then removes completely
        TRAINS = [{ name: '2H', num: 6, distance: 2, price: 80, obsolete_on: '8H', rusts_on: '6H' }, # 1H price:40
                  { name: '4H', num: 5, distance: 4, price: 180, obsolete_on: 'H', rusts_on: '8H' }, # 2H price:90
                  {
                    name: '6H',
                    num: 4,
                    distance: 6,
                    price: 300,
                    rusts_on: '10H',
                  }, # 3H price:150
                  { name: '8H', num: 3, distance: 8, price: 440 },
                  {
                    name: '10H',
                    num: 2,
                    distance: 10,
                    price: 550,
                  },
                  {
                    name: 'D',
                    num: 1,
                    distance: 99,
                    price: 770,
                  }].freeze

        def home_token_locations(corporation)
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
          end
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::BuySellParShares,
          ])
        end

        def merger_round
          G18Ireland::Round::Merger.new(self, [
            Engine::Step::DiscardTrain,
            G18Ireland::Step::MergerVote,
            G18Ireland::Step::Merge,
          ], round_num: @round.round_num)
        end

        def new_or!
          if @round.round_num < @operating_rounds
            new_operating_round(@round.round_num + 1)
          else
            @turn += 1
            or_set_finished
            new_stock_round
          end
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              if phase.name.to_i > 4 # @todo: this should only be at end of round, and after phase 4
                new_or!
              else
                @log << "-- #{round_description('Merger', @round.round_num)} --"
                merger_round
              end
            when G18Ireland::Round::Merger
              new_or!
            when init_round.class
              reorder_players
              new_stock_round
            end
        end
      end
    end
  end
end
