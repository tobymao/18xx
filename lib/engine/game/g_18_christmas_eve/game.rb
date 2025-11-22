# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_18_chesapeake/game'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18ChristmasEve
      class Game < G18Chesapeake::Game
        include_meta(G18ChristmasEve::Meta)
        include Entities
        include Map

        BANK_CASH = 12_000

        SELL_BUY_ORDER = :sell_buy_sell

        GAME_END_CHECK = {
          bankrupt: :immediate,
          stock_market: :current_round,
          bank: :full_or,
          final_phase: :one_more_full_or_set,
        }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          final_phase: 'First D Purchased'
        ).freeze

        GAME_END_DESCRIPTION_REASON_MAP_TEXT = Base::GAME_END_DESCRIPTION_REASON_MAP_TEXT.merge(
          final_phase: 'First D Purchased'
        ).freeze

        def cornelius
          # cornelius, as inheriting behaviour from the chessie cornelius private
          @cornelius ||= @companies.find { |company| company.name == '"Santa"?' }
        end

        def hat
          @hat ||= @companies.find { |company| company.name == "Conductor's Hat" }
        end

        def nog
          @nog ||= @companies.find { |company| company.name == 'Egg Nog Express' }
        end

        # Reimplement 18Ches trains for D end game trigger
        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 7,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 5,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 20,
            available_on: '6',
            discount: { '4' => 200, '5' => 200, '6' => 200 },
            events: [{ 'type' => 'd_trigger' }],
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'd_trigger' => ['D Trigger',
                          'After the purchase of the first D, game ends end of the following OR set'],
        ).freeze

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18ChristmasEve::Step::BuySellParGiftShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            G18ChristmasEve::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def status_array(corporation)
          return [] unless @round.respond_to?(:presidencies_gifted)

          if @round.presidencies_gifted.include?(corporation)
            ['Can not gift presidents certificate again this round.']
          else
            []
          end
        end

        def or_set_finished
          depot.export! if %w[2 3 4].include?(@depot.upcoming.first.name)
        end

        def rooms_in_route(route)
          route.visited_stops.map { |stop| stop.tile&.frame&.color }.uniq.count { |s| !s.nil? }
        end

        def most_rooms?(route)
          most = route.routes.max_by { |r| rooms_in_route(r) }
          route == most
        end

        def nog_express?(route)
          bar = route.visited_stops.find { |s| s.tile&.location_name == 'Bar' }
          dc = route.visited_stops.find { |s| s.tile&.label&.to_s == 'DC' }
          bar && dc
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += 10 * rooms_in_route(route) if route.train.owner.companies.include?(hat) && most_rooms?(route)
          revenue += 40 if route.train.owner.companies.include?(nog) && nog_express?(route)
          revenue
        end

        def revenue_str(route)
          rev_str = super
          rev_str += ' + Hat' if route.train.owner.companies.include?(hat) && most_rooms?(route)
          rev_str += ' + Nog' if route.train.owner.companies.include?(nog) && nog_express?(route)
          rev_str
        end

        @d_trigger = false

        def event_d_trigger!
          @log << 'First D purchased. Game will end at end of next set of ORs' unless @d_trigger
          @d_trigger = true
        end

        def game_end_check_final_phase?
          @d_trigger
        end
      end
    end
  end
end
