# frozen_string_literal: true

require_relative '../base'
require_relative '../company_price_up_to_face'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'stock_market'
require_relative 'tiles'
require_relative 'step/buy_company'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/draft_distribution'

module Engine
  module Game
    module G18Tokaido
      class Game < Game::Base
        include_meta(G18Tokaido::Meta)
        include Entities
        include Map
        include StockMarket
        include Tiles

        include CompanyPriceUpToFace

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        attr_reader :drafted_companies

        CURRENCY_FORMAT_STR = '¥%s'
        # Technically not used; recalculated depending on optional rules
        CERT_LIMIT = { 2 => 24, 3 => 16, 4 => 12 }.freeze
        STARTING_CASH = { 2 => 820, 3 => 550, 4 => 480 }.freeze
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false

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
            rusts_on: 'D',
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
            name: 'D',
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
            'Game ends after next set of ORs when D train purchased or exported, ' \
            'purchasing a D train triggers a stock round immediately after current OR',
          ]
        )

        ASSIGNMENT_TOKENS = {
          'FM' => '/icons/18_tokaido/fm_token.svg',
        }.freeze

        def corporation_opts
          limited_express ? { float_percent: 50 } : {}
        end

        def game_tiles
          if newbie_rules
            tiles = G18Tokaido::Tiles::TILES.dup
            %w[204 207 208 619 622].each { |t| tiles[t] += 1 }
            tiles
          else
            G18Tokaido::Tiles::TILES
          end
        end

        def game_market
          if newbie_rules
            market = G18Tokaido::StockMarket::MARKET.dup
            market.map do |row|
              row.map { |p| p.include?('y') ? p.chop : p }
            end
          elsif limited_express
            [
              %w[76 82 90 100p 112 126 142 160 180 200 225 250 275 300e],
              %w[70 76 82 90p 100 112 126 142 160 180 200 220 240 260],
              %w[65 70 76 82p 90 100 111 125 140 155 170 185],
              %w[60y 66 71 76p 82 90 100 110 120 130],
              %w[55y 62 67 71p 76 82 90 100],
              %w[50y 58y 65 67p 71 75 80],
              %w[45o 54y 63 67 69 70],
              %w[40o 50y 60y 67 68],
              %w[30b 40o 50y 60y],
              %w[20b 30b 40o 50y],
              %w[10b 20b 30b 40o],
            ].freeze
          else
            G18Tokaido::StockMarket::MARKET
          end
        end

        def game_end_check_values
          if limited_express
            { bankrupt: :immediate, stock_market: :current_round, final_phase: :full_or }
          else
            { bankrupt: :immediate, final_phase: :full_or }
          end
        end

        def setup
          if waterfall_auction
            @companies.each do |c|
              new_value = c.value - ((c.value - 20) / 4)
              c.value = new_value
              c.min_price = (new_value / 2).to_i
              c.max_price = new_value * 2
            end
          elsif snake_draft
            setup_company_price_up_to_face
            @reverse = true
          else
            setup_company_price_up_to_face
            @companies.each { |c| c.owner = @bank }
          end
          @e_train_exported = false
        end

        def after_bid; end

        def cert_limit(_player = nil)
          (8 * corporations.size / players.size).to_i
        end

        def game_trains
          if limited_express
            trains = G18Tokaido::Game::TRAINS.dup
            trains.map do |train|
              if train[:name] == 'D'
                train[:price] = 1100
                train[:discount] = { '4' => 300, '5' => 300, '6' => 300 }
              end
              train
            end
          else
            G18Tokaido::Game::TRAINS
          end
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
            limited_express ? 2 : 3
          when 'D'
            20
          end
        end

        def init_corporations(stock_market)
          corporations = super(stock_market)

          if !@optional_rules&.include?(:no_corporation_discard) && players.size <= 3
            removed = corporations.delete_at((rand % 6) + 1)
            @log << "Removed #{removed.full_name}"
          end

          corporations
        end

        def init_round
          if waterfall_auction
            Engine::Round::Auction.new(self, [
              Engine::Step::CompanyPendingPar,
              Engine::Step::WaterfallAuction,
            ])
          elsif snake_draft
            Engine::Round::Draft.new(
              self,
              [G18Tokaido::Step::DraftDistribution],
              snake_order: true
            )
          else
            Engine::Round::Stock.new(self, [
              G18Tokaido::Step::BuySellParShares,
            ])
          end
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
            G18Tokaido::Step::BuySellParShares,
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
            when Engine::Round::Auction
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
          @log << 'First D train bought/exported, end game triggered'
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

          @e_train_exported = true if depot.upcoming.first.name == 'D'
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
          timeline = [
            'At the end of each set of ORs the next available train will be exported (removed, triggering ' \
            'phase change as if purchased)',
          ]
          timeline.unshift('First stock round is in reverse order of draft order') if snake_draft
          @timeline = timeline
        end

        def fish_market
          @fish_market ||= company_by_id('FM')
        end

        def sleeper_train
          @sleeper_train ||= company_by_id('ST')
        end

        def draft_finished?; end

        def waterfall_auction
          @optional_rules&.include?(:waterfall_auction)
        end

        def snake_draft
          @optional_rules&.include?(:snake_draft)
        end

        def limited_express
          @optional_rules&.include?(:limited_express)
        end

        def newbie_rules
          @optional_rules&.include?(:newbie_rules)
        end

        def payout_companies(ignore: [])
          companies = @companies.select do |c|
            c.owner && c.owner != bank && c.revenue.positive? && !ignore.include?(c.id)
          end

          companies.sort_by! do |company|
            [
              company.owned_by_player? ? [0, @players.index(company.owner)] : [1, company.owner],
              company.revenue,
              company.name,
            ]
          end

          companies.each do |company|
            owner = company.owner
            revenue = company.revenue
            @bank.spend(revenue, owner)
            @log << "#{owner.name} collects #{format_currency(revenue)} from #{company.name}"
          end
        end
      end
    end
  end
end
