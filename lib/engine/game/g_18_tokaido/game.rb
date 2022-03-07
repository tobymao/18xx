# frozen_string_literal: true

require_relative '../base'
require_relative '../company_price_up_to_face'
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
        include CompanyPriceUpToFace

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        attr_reader :drafted_companies

        TRACK_RESTRICTION = :permissive
        CURRENCY_FORMAT_STR = '¥%d'
        CERT_LIMIT = { 2 => 24, 3 => 16, 4 => 12 }.freeze
        STARTING_CASH = { 2 => 820, 3 => 550, 4 => 480 }.freeze
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[75 80 85 95 105 115 130 145 160 180 200 225 250 275 300],
          %w[70 75 80 85 95p 105 115 130 145 160 180 200 225 250 275],
          %w[65 70 75 80p 85 95 105 115 130 145 160],
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
            name: 'E',
            on: 'E',
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
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'E',
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
          },
          {
            name: 'E',
            distance: 999,
            price: 900,
            available_on: '6',
            events: [{ 'type' => 'signal_end_game' }],
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'signal_end_game' => [
            'Triggers End Game',
            'Game ends after next set of ORs when E train purchased or exported, ' \
            'purchasing a E train triggers a stock round immediately after current OR',
          ]
        )

        ASSIGNMENT_TOKENS = {
          'FM' => '/icons/18_tokaido/fm_token.svg',
        }.freeze

        SELL_BUY_ORDER = :sell_buy

        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :full_or }.freeze

        def setup
          @reverse = true
          @e_train_exported = false
          setup_company_price_up_to_face
        end

        def cert_limit
          (8 * corporations.size / players.size).to_i
        end

        def num_trains(train)
          four_players = players.size == 4

          case train[:name]
          when '2'
            four_players ? 8 : 7
          when '3'
            5
          when '4'
            4
          when '5'
            3
          when '6'
            @optional_rules&.include?(:limited_express) ? 2 : 3
          when 'E'
            20
          end
        end

        def init_corporations(stock_market)
          corporations = super(stock_market)

          unless @optional_rules&.include?(:no_corporation_discard) || players.size > 3
            removed = corporations.delete_at((rand % 6) + 1)
            @log << "Removed #{removed.full_name}"
          end

          corporations
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

        def reorder_players
          if @reverse
            @reverse = false
            @players.reverse!
          else
            super
          end
        end

        def next_sr_player_order
          return :first_to_pass if @optional_rules&.include?(:pass_priority)

          super
        end

        def priority_deal_player
          return nil if @reverse

          super
        end

        def new_stock_round
          @log << "-- #{round_description('Stock')} --"
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
              reorder_players
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              @need_last_stock_round = false
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @need_last_stock_round || @round.round_num >= @operating_rounds
                @turn += 1
                or_set_finished
                new_stock_round
              else
                new_operating_round(@round.round_num + 1)
              end
            end
        end

        def event_signal_end_game!
          @need_last_stock_round = true
          game_end_check
          @operating_rounds = @round.round_num if round.class.short_name != 'SR'
          @log << 'First E train bought/exported, end game triggered'
        end

        def game_ending_description
          _, after = game_end_check
          return unless after

          ending_or = @need_last_stock_round && round.class.short_name != 'SR' ? turn + 1 : turn
          "Game ends at conclusion of OR #{ending_or}.3"
        end

        def end_now?(after)
          return false if @need_last_stock_round

          super
        end

        def or_set_finished
          return if @e_train_exported

          @e_train_exported = true if depot.upcoming.first.name == 'E'
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
            revenue += 10
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
            'First stock round is in reverse order of draft order',
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

        def draft_finished?; end
      end
    end
  end
end
