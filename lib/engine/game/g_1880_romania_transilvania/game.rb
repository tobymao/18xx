# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1880_romania/game'
require_relative 'map'
require_relative '../g_1880_romania/entities'

module Engine
  module Game
    module G1880RomaniaTransilvania
      class Game < G1880Romania::Game
        include_meta(G1880RomaniaTransilvania::Meta)
        include Map

        CERT_LIMIT = { 2 => 11 }.freeze

        STARTING_CASH = { 2 => 350 }.freeze

        GAME_END_REASONS_TEXT = {
          final_train: '6E train sold or exported',
        }.freeze

        GAME_END_REASONS_TIMING_TEXT = {
          one_more_full_or_set: '3 ORs ending with the Corporation that triggered game end',
        }.freeze

        GAME_END_DESCRIPTION_REASON_MAP_TEXT = {
          final_train: '6E train was sold or exported',
        }.freeze

        def game_companies
          companies = COMPANIES.map(&:dup)
          kept_companies = %w[P1 P3 P5 P8]
          companies.select { |c| kept_companies.include?(c[:sym]) }
        end

        def game_minors
          minors = MINORS.map(&:dup)

          kept_minors = %w[1 4 5]
          coordinates = {
            '1' => 'D2',
            '4' => 'B8',
            '5' => 'J4',
          }.freeze
          minors
          .select { |m| kept_minors.include?(m[:sym]) }
          .each { |m| m[:coordinates] = coordinates[m[:sym]] }
        end

        def game_corporations
          corporations = CORPORATIONS.map(&:dup)
          kept_corporations = %w[BR CR SZ TR]
          coordinates = {
            'BR' => 'D6',
            'CR' => 'E3',
            'SZ' => 'G1',
            'TR' => 'L6',
          }.freeze
          corporations
          .select { |c| kept_corporations.include?(c[:sym]) }
          .each { |m| m[:coordinates] = coordinates[m[:sym]] }
        end

        def game_trains
          unless @game_trains
            @game_trains = super.map(&:dup)
            trains_2, trains_2p, trains_3, trains_3p, trains_4, trains_4p, trains_6, trains_6e, trains_8, trains_8e = @game_trains

            trains_2[:num] = 6

            trains_2p[:num] = 3

            trains_3[:num] = 3

            trains_3p[:num] = 2
            # Remove close_p7 event since P7 is not used in this variant]
            trains_3p[:events] = [{ 'type' => 'communist_takeover' }]

            trains_4[:num] = 2

            trains_4p[:num] = 2

            trains_6[:num] = 2

            trains_6e[:num] = 1
            trains_6e[:events] = [{ 'type' => 'signal_end_game', 'when' => 1 }]

            trains_8[:num] = 'unlimited'

            trains_8e[:num] = 0
          end
          @game_trains
        end

        def par_chart
          @par_chart ||=
            share_prices.sort_by { |sp| -sp.price }.to_h { |sp| [sp, [nil, nil]] }
        end

        def stock_round
          G1880::Round::Stock.new(self, [
            Engine::Step::Exchange,
            G1880::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1880::Round::Operating.new(self, [
            Engine::Step::HomeToken,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            G1880::Step::Track,
            G1880::Step::Token,
            G1880::Step::Route,
            G1880::Step::Dividend,
            G1880RomaniaTransilvania::Step::BuyTrain,
            G1880::Step::CheckFIConnection,
          ], round_num: round_num)
        end
      end
    end
  end
end
