# frozen_string_literal: true

require 'engine/bank'
require 'engine/map'
require 'engine/player'
require 'engine/share_pool'
require 'engine/stock_market'
require 'engine/round/auction'
require 'engine/round/operating'
require 'engine/round/stock'
require 'engine/train/base'
require 'engine/train/handler'

module Engine
  module Game
    class Base
      attr_reader :actions, :bank, :corporations, :map,
                  :players, :round, :share_pool, :stock_market, :tiles

      STARTING_CASH = {
        2 => 1200,
        3 => 800,
        4 => 600,
        5 => 480,
        6 => 400,
      }.freeze

      def initialize(names, actions: [])
        @names = names.freeze
        @players = @names.map { |name| Player.new(name) }
        @bank = init_bank
        @trains = init_trains
        @companies = init_companies
        @share_pool = SharePool.new(@corporations, @bank)
        @stock_market = init_stock_market
        @corporations = init_corporations
        @hexes = init_hexes
        @tiles = init_tiles
        @map = Map.new(@hexes)
        @actions = []
        @round = init_round
        init_starting_cash

        # replay all actions with a copy
        actions.each { |action| process_action(action.copy(self)) }
      end

      def current_entity
        @round.current_entity
      end

      def process_action(action)
        @round.process_action(action)
        @actions << action
        next_round! if @round.finished?
      end

      def rollback
        self.class.new(@names, actions: @actions[0...-1])
      end

      def player_by_name(name)
        @_players ||= @players.map { |p| [p.name, p] }.to_h
        @_players[name]
      end

      def corporation_by_name(name)
        @_corporations ||= @corporations.map { |c| [c.name, c] }.to_h
        @_corporations[name]
      end

      def company_by_name(name)
        @_companies ||= @companies.map { |c| [c.name, c] }.to_h
        @_companies[name]
      end

      def hex_by_name(name)
        @_hexes ||= @hexes.map { |h| [h.name, h] }.to_h
        @_hexes[name]
      end

      def tile_by_name(name)
        @_tiles ||= @tiles.map { |t| [t.name, t] }.to_h
        @_tiles[name]
      end

      def share_by_name(name)
        @_shares ||= @corporations.flat_map do |c|
          c.shares.map { |s| [s.name, s] }
        end
        @_shares[name]
      end

      private

      def init_bank
        Bank.new(12_000)
      end

      def init_round
        # Round::Auction.new(@players, companies: @companies, bank: @bank)
        Round::Operating.new(@players, tiles: @tiles)
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

      def init_hexes; end

      def init_tiles; end

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
