# frozen_string_literal: true

require 'engine/bank'
require 'engine/player'
require 'engine/round/handler'
require 'engine/train/base'
require 'engine/train/handler'

module Engine
  module Game
    class Base
      attr_reader :bank, :corporations, :players

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
        @rounds = init_rounds

        init_starting_cash
      end

      def round
        @rounds.current
      end

      def process_action(action)
        round.process_action(action)
      end

      private

      def init_bank
        Bank.new(12_000)
      end

      def init_companies
        [
          Company::Base.new('Mohawk', value: 20, income: 5),
          Company::TileLaying.new('PRR', value: 30, income: 5),
        ]
      end

      def init_rounds
        Round::Handler.new(@players, @companies, @bank)
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

      def init_starting_cash
        cash = self.class::STARTING_CASH[@players.size]

        @players.each do |player|
          @bank.remove_cash(cash)
          player.add_cash(cash)
        end
      end
    end
  end
end
