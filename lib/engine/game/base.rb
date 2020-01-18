# frozen_string_literal: true

require 'engine/bank'
require 'engine/player'
require 'engine/share_pool'
require 'engine/stock_market'
require 'engine/round/auction'
require 'engine/round/stock'
require 'engine/train/base'
require 'engine/train/handler'

module Engine
  module Game
    class Base
      attr_reader :bank, :corporations, :map, :players, :round, :share_pool, :stock_market

      STARTING_CASH = {
        2 => 1200,
        3 => 800,
        4 => 600,
        5 => 480,
        6 => 400,
      }.freeze

      def initialize(players)
        @players = players
        @bank = init_bank
        @trains = init_trains
        @corporations = init_corporations
        @companies = init_companies
        @round = init_round
        @share_pool = SharePool.new(@corporations, @bank)
        @stock_market = init_stock_market
        @map = init_map
        init_starting_cash
      end

      def process_action(action)
        @round.process_action(action)
        next_round! if @round.finished?
      end

      private

      def init_bank
        Bank.new(12_000)
      end

      def init_round
        Round::Auction.new(@players, companies: @companies, bank: @bank)
      end

      def init_stock_market
        StockMarket.new(StockMarket::MARKET)
      end

      def init_companies
        [
          Company::Base.new('Mohawk', value: 20, income: 5),
          Company::TileLaying.new('PRR', value: 30, income: 5),
        ]
      end

      def init_trains
        Train::Handler.new(
          Array(6).map { Train::Base.new('2', distance: 2, price: 80, phase: :yellow) } +
          Array(5).map { Train::Base.new('3', distance: 3, price: 180, phase: :green) } +
          Array(4).map { Train::Base.new('4', distance: 4, price: 300, phase: :green, rusts: '2') } +
          Array(3).map { Train::Base.new('5', distance: 5, price: 450, phase: :brown) } +
          Array(2).map { Train::Base.new('6', distance: 6, price: 630, phase: :brown, rusts: '3') } +
          Array(20).map { Train::Base.new('D', distance: 999, price: 1100, phase: :brown, rusts: '4') }
        )
      end

      def init_corporations
        []
      end

      def init_map
      end

      def init_starting_cash
        cash = self.class::STARTING_CASH[@players.size]

        @players.each do |player|
          @bank.remove_cash(cash)
          player.add_cash(cash)
        end
      end

      def next_round!(phase)
        @round =
          case @round
          when Round::Auction
            Round::Stock.new(@players, share_pool: @share_pool, stock_market: @stock_market)
          when Round::Stock
            Round::Operating.new(@players)
          when Round::Operating
            num = @round.num
            num < phase.operating_rounds ? Round::Operating.new(@players, num: num + 1) : Stock.new(@players)
          else
            raise "Unexected round type #{@round}"
          end
      end
    end
  end
end
