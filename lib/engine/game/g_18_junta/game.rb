# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'stock_market'
require_relative 'step/dividend'
require_relative 'step/private_auction'
require_relative '../base'

module Engine
  module Game
    module G18Junta
      class Game < Game::Base
        include_meta(G18Junta::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '$%s'

        # Rules summary 1.1: setup by player count.
        BANK_CASH = { 2 => 5_000, 3 => 7_000, 4 => 7_000 }.freeze

        CERT_LIMIT = { 2 => 22, 3 => 16, 4 => 14 }.freeze

        STARTING_CASH = { 2 => 580, 3 => 520, 4 => 450 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        SELL_BUY_ORDER = :sell_buy_sell

        POOL_SHARE_LIMIT = 50

        SOLD_OUT_INCREASE = true

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or, stock_market: :current_or }.freeze

        # Rules summary 3.2, 3.3 and 3.6: par prices from $65 to $100, no yellow/orange/brown zones, and
        # the $330 and $350 spaces end the game.
        MARKET = [
          %w[75 85 95 105 115 130 145 160 180 205 230 260 290 320 350e],
          %w[70 80 90 100 110 125 140 155 175 200 225 250 275 300 330e],
          %w[65 70 80 90 100p 110 125 140 155 175 200 225 250 280],
          %w[55 65 70 80p 90p 100 110 125 140 155 175 200],
          %w[50 55 65 70p 80 90 100 110 125 140],
          %w[45 50 60 65p 70 80 90 100],
          %w[35 45 55 60 65 70],
          %w[25 35 45 55],
          %w[10 25 35],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['can_buy_companies'],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
          { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
          { name: '4', distance: 4, price: 300, rusts_on: %w[8 D], num: 4 },
          { name: '5', distance: 5, price: 450, num: 3 },
          { name: '6', distance: 6, price: 630, num: 2 },
          # Rules summary 8 and 8.1: the final train is either the 8 or the D (decided by the coup in a
          # later PR); both trade in a 4, 5 or 6 for $750 and $800 respectively.
          {
            name: '8',
            distance: 8,
            price: 900,
            num: 6,
            available_on: '6',
            discount: { '4' => 150, '5' => 150, '6' => 150 },
          },
          {
            name: 'D',
            distance: 999,
            price: 1_100,
            num: 6,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
        ].freeze

        EBUY_PRES_SWAP = false
        EBUY_FROM_OTHERS = :value
        ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = false
        # Rules summary 10: the home station is placed when the company floats.
        HOME_TOKEN_TIMING = :float

        # Rules summary 1.2: number of private companies kept in play by player count.
        PRIVATES_IN_PLAY = { 2 => 5, 3 => 6, 4 => 7 }.freeze

        def setup
          remove_random_corporation!
          select_random_privates!
        end

        # Rules summary 1.2: one public company, drawn at random, is out of the game. Its home
        # reservation is cleared so the city is open to everyone.
        def remove_random_corporation!
          corporation = @corporations.min_by { rand }
          hex = hex_by_id(corporation.coordinates)
          hex.tile.cities[corporation.city || 0].remove_reservation!(corporation)
          @corporations.delete(corporation)
          @log << "Corporation removed from play: #{corporation.name}"
        end

        # Rules summary 1.2: only a random set of the private companies is used in each game.
        def select_random_privates!
          kept = @companies.sort_by { rand }.take(self.class::PRIVATES_IN_PLAY[@players.size])
          (@companies - kept).each { |company| @companies.delete(company) }
          @log << "Private companies in play: #{@companies.map(&:sym).join(', ')}"
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Junta::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
