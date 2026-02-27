# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
require_relative '../double_sided_tiles'
require_relative 'trains'

module Engine
  module Game
    module G18Cuba
      class Game < Game::Base
        include_meta(G18Cuba::Meta)
        include Entities
        include Map
        include Trains

        include DoubleSidedTiles

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        CURRENCY_FORMAT_STR = '$%s'
        HOME_TOKEN_TIMING = :par

        BANK_CASH = 10_000

        CERT_LIMIT = { 2 => 35, 3 => 30, 4 => 20, 5 => 17, 6 => 15 }.freeze

        STARTING_CASH = { 2 => 950, 3 => 900, 4 => 680, 5 => 650, 6 => 650 }.freeze

        MARKET = [
          %w[50 55 60 65 70p 75p 80p 85p 90p 95p 100p 105 110 115 120 126 192 198 144
             151 158 172 180 188 196 204 013 222 231 240 250 260 275 290 300],
        ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
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
                    name: '8',
                    on: '8',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                    operating_rounds: 3,
                  }].freeze

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            G18Cuba::Step::HomeToken,
            G18Cuba::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Cuba::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: :flip)
        end

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end

        def num_trains(train)
          num_players = [@players.size, 2].max
          TRAIN_FOR_PLAYER_COUNT[num_players][train[:name].to_sym]
        end

        def company_header(company)
          case company.type
          when :concession
            'CONCESSION'
          when :commission
            'COMMISSIONER'
          else
            raise "Unknown company type: #{company.type}"
          end
        end

        def commissioners
          @commissioners ||= @companies.select { |c| c.type == :commission }
        end

        def concessions
          @concessions ||= @companies.select { |c| c.type == :concession }
        end

        def setup
          super
          @tile_groups = init_tile_groups
          initialize_tile_opposites!
          @unused_tiles = []
          @sugar_cubes = {}
        end

        def init_tile_groups
          self.class::TILE_GROUPS
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [G18Cuba::Step::SelectionAuction])
        end

        def new_draft_round
          Engine::Round::Draft.new(self, [G18Cuba::Step::SimpleDraft], reverse_order: false)
        end

        def stock_round
          Round::Stock.new(self, [
            G18Cuba::Step::HomeToken,
            G18Cuba::Step::BuySellParShares,
          ])
        end

        def close_unopened_minors
          @corporations.each { |c| c.close! if c.type == :minor && !c.floated? }
          @log << 'Unopened minors close'
        end

        def can_par?(corporation, entity)
          # FC cannot be parred
          # Minors can only be parred by players with a concession to exchange
          return false if corporation.type == :state
          return super unless corporation.type == :minor

          entity.companies.any? { |c| abilities(c, :exchange) }
        end

        def next_round!
          # After Init -> Auction Commissions -> Draft Concessions -> Stock Round -> Operating Rounds
          @round =
            case @round
            when Round::Draft
              new_stock_round
            when Round::Stock
              close_unopened_minors if @turn == 1
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players(:least_cash, log_player_order: true)
              new_draft_round
            end
        end

        def home_token_locations(corporation)
          if corporation.type == :minor || corporation.id == 'FEC'
            hexes.select do |hex|
              hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
            end
          else
            super
          end
        end

        def sugar_production(corporation, total_revenue)
          return if total_revenue.zero? || corporation.type != :minor

          sugar_cubes = case total_revenue
                        when 0..29 then 0
                        when 30..79 then 1
                        when 80..150 then 2
                        else 3
                        end

          @sugar_cubes[corporation] = sugar_cubes
          @log << "#{corporation.name} produces #{sugar_cubes} sugar cube(s) "\
                  "from #{format_currency(total_revenue)} revenue."
        end

        def or_round_finished
          # For the moment reset sugar cubes, handling for FC to be implemented later
          return if @sugar_cubes.values.none?(&:positive?)

          @sugar_cubes.clear
          @log << 'All remaining sugar cubes are removed at the end of the Operating Round.'
        end
      end
    end
  end
end
