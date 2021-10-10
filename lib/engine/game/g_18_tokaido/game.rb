# frozen_string_literal: true

require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'step/buy_company'
require_relative 'step/draft_distribution'

module Engine
  module Game
    module G18Tokaido
      class Game < Game::Base
        include_meta(G18Tokaido::Meta)
        include Entities
        include Map

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        TRACK_RESTRICTION = :permissive
        CURRENCY_FORMAT_STR = '¥%d'
        CERT_LIMIT = { 2 => 24, 3 => 16, 4 => 12 }.freeze
        STARTING_CASH = { 2 => 720, 3 => 540, 4 => 480 }.freeze
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[75 80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 360 400],
          %w[70 75 80 85 95p 105 115 130 145 160 180 200 225 250 275 300 325 360],
          %w[65 70 75 80p 85 95 105 115 130 145 160 180],
          %w[60 65 70p 75 80 85 95 105],
          %w[55 60 65 70 75 80],
          %w[50 55 60 65],
          %w[45 50 55],
          %w[40 45],
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
          },
          {
            name: '6',
            on: '6',
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
            num: 5,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
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
            events: [{ 'type' => 'signal_end_game' }],
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'signal_end_game' => [
            'Triggers End Game',
            'Game ends after next set of ORs when D train purchased or exported, ' \
            'purchasing a D train triggers a stock round immediately after current OR',
          ]
        )

        ASSIGNMENT_TOKENS = {
          'FM' => '/icons/18_tokaido/fm_token.svg',
        }.freeze

        SELL_BUY_ORDER = :sell_buy

        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :full_or }.freeze

        def setup
          @reverse = true
          @d_train_exported = false
        end

        def init_round
          Engine::Round::Draft.new(
            self,
            [G18Tokaido::Step::DraftDistribution],
            snake_order: true
          )
        end

        def init_round_finished
          @companies.reject(&:owned_by_player?).sort_by(&:name).each do |company|
            company.close!
            @log << "#{company.name} is removed"
          end
          @draft_finished = true
        end

        def reorder_players_by_cash
          current_order = @players.dup
          if @reverse
            @reverse = false
            @players.reverse!
          else
            @players.sort_by! { |p| [p.cash, current_order.index(p)] }
          end
          @log << "Priority order: #{@players.reject(&:bankrupt).map(&:name).join(', ')}"
        end

        def priority_deal_player
          # Don't move around priority deal marker; only changes when players are reordered at beginning of stock round
          players.first
        end

        def new_stock_round
          @log << "-- #{round_description('Stock')} --"
          reorder_players_by_cash
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18Tokaido::Step::BuyCompany,
            Engine::Step::Assign,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [G18Tokaido::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Draft
              init_round_finished
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              @need_last_stock_round = false
              new_operating_round
            when Engine::Round::Operating
              if @need_last_stock_round
                @turn += 1
                new_stock_round
              elsif @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            end
        end

        def event_signal_end_game!
          @need_last_stock_round = true
          game_end_check
          @log << 'First D train bought/exported, end game triggered'
        end

        def game_ending_description
          _, after = game_end_check
          return unless after

          ending_or = @need_last_stock_round && round.class.short_name != 'SR' ? turn + 1 : turn
          "Game ends at conclusion of OR #{ending_or}.#{operating_rounds}"
        end

        def end_now?(after)
          return false if @need_last_stock_round

          super
        end

        def or_set_finished
          return if @d_train_exported

          @d_train_exported = true if depot.upcoming.first.name == 'D'
          depot.export!
        end

        def best_sleeper_route(routes)
          routes.routes.max_by { |r| sleeper_bonus(r) }
        end

        def sleeper_bonus(route)
          return 0 unless route

          route.visited_stops.count { |s| s.is_a?(Engine::Part::City) } * 10
        end

        def revenue_for(route, stops)
          revenue = super
          if route.train.owner.companies.include?(fish_market) && stops.find { |s| s.hex.assigned?(fish_market&.id) }
            revenue += 20
          end
          if route.train.owner.companies.include?(sleeper_train) && route == best_sleeper_route(route)
            revenue += sleeper_bonus(best_sleeper_route(route))
          end
          revenue
        end

        def revenue_str(route)
          stops = route.stops
          str = super
          if route.train.owner.companies.include?(fish_market) && stops.find { |s| s.hex.assigned?(fish_market&.id) }
            str += ' + Fish Market'
          end
          str += ' + Sleeper Train' if route.train.owner.companies.include?(sleeper_train) && route == best_sleeper_route(route)
          str
        end

        def timeline
          @timeline = [
            'At the end of each set of ORs the next available train will be exported (removed, triggering ' \
            'phase change as if purchased)',
          ]
        end

        def fish_market
          @fish_market ||= company_by_id('FM')
        end

        def sleeper_train
          @sleeper_train ||= company_by_id('ST')
        end
      end
    end
  end
end
