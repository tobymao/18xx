# frozen_string_literal: true

require_relative '../company_price_up_to_face'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module GSteamOverHolland
      class Game < Game::Base
        include_meta(GSteamOverHolland::Meta)
        include Entities
        include Map
        include CompanyPriceUpToFace

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :semi_restrictive
        SELL_BUY_ORDER = :sell_buy
        CURRENCY_FORMAT_STR = 'fl. %s'
        MUST_SELL_IN_BLOCKS = true
        SELL_MOVEMENT = :left_share
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        BANKRUPTCY_ALLOWED = false

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 18, 3 => 16, 4 => 14, 5 => 12 }.freeze

        STARTING_CASH = { 2 => 600, 3 => 400, 4 => 300, 5 => 240 }.freeze

        OR_SETS = [2, 2, 2, 2, 2].freeze
        LAST_OR = 10

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :operate
        SOLD_OUT_INCREASE = false

        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cannot_reuse_same_hex: true },
        ].freeze

        MARKET = [
          [
            { price: 50 },
            { price: 55 },
            { price: 60 },
            { price: 65, types: [:par] },
            { price: 70, types: [:par] },
            { price: 75, types: [:par] },
            { price: 80, types: [:par] },
            { price: 90, types: [:par] },
            { price: 100, types: %i[par max_price_1] },
            { price: 110, types: [:ignore_sale_unless_president] },
            { price: 125, types: [:max_one_drop_unless_president] },
            { price: 140, types: %i[max_two_drops_unless_president max_price_1] },
            { price: 160, types: [:ignore_sale_unless_president] },
            { price: 180, types: [:max_one_drop_unless_president] },
            { price: 210, types: %i[max_two_drops_unless_president max_price_1] },
            { price: 240, types: [:ignore_sale_unless_president] },
            { price: 270, types: [:max_one_drop_unless_president] },
            { price: 300, types: %i[max_two_drops_unless_president max_price_1] },
            { price: 330, types: [:ignore_sale_unless_president] },
            { price: 360, types: [:endgame] },
          ],
        ].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :yellow).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          max_price_1: 'Price will not drop below black line in Stock Round unless president sells'
        ).freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow] },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                  }].freeze

        TRAINS = [{
          name: '2',
          distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                     { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
          price: 100,
          rusts_on: '4',
          num: 5,
        },
                  {
                    name: '3',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 200,
                    rusts_on: '5',
                    num: 4,
                    events: [{ 'type' => 'float_30' }],
                  },
                  {
                    name: '4',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 300,
                    rusts_on: '6',
                    num: 3,
                    events: [{ 'type' => 'float_40' }],
                  },
                  {
                    name: '5',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 400,
                    num: 3,
                    events: [{ 'type' => 'close_companies' },
                             { 'type' => 'float_50' }],

                  },
                  {
                    name: '6',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 500,
                    num: 6,
                    variants: [
                      {
                        name: '3E',
                        distance:
                          [
                            { 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                            { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                          ],
                        price: 600,
                      },
                    ],
                    events: [{ 'type' => 'float_60' }],
                  }].freeze

        # Game ends after 5 sets of ORs - checked in end_now? below
        GAME_END_CHECK = { fixed_round: :current_or, stock_market: :current }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          stock_market: 'Company reached the top of the market.',
        ).freeze

        GAME_END_REASONS_TIMING_TEXT = Base::EVENTS_TEXT.merge(
          current_or: 'Ends after the final OR set.',
          current: 'Ends after this OR.'
        ).freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'float_30' => ['30% to Float', 'Players must buy 30% of a corporation to float'],
          'float_40' => ['40% to Float', 'Players must buy 40% of a corporation to float'],
          'float_50' => ['50% to Float', 'Players must buy 50% of a corporation to float'],
          'float_60' => ['60% to Float', 'Players must buy 60% of a corporation to float'],
        ).freeze

        def setup_preround
          # randomize the private companies, choose an amount equal to player count, sort numerically
          @companies = @companies.sort_by { rand }.take(@players.size).sort_by(&:name)
        end

        def setup
          setup_company_price_up_to_face
          @or = 0
        end

        def next_sr_player_order
          @round.auction? ? :most_cash_keep_order : :next_clockwise
        end

        def timeline
          @timeline ||= [
            'Game ends after OR 5.2!',
          ].freeze
          @timeline
        end

        def show_progress_bar?
          true
        end

        def progress_information
          [
            { type: :PRE },
            { type: :SR },
            { type: :OR, name: '1.1' },
            { type: :OR, name: '1.2' },
            { type: :SR },
            { type: :OR, name: '2.1' },
            { type: :OR, name: '2.2' },
            { type: :SR },
            { type: :OR, name: '3.1' },
            { type: :OR, name: '3.2' },
            { type: :SR },
            { type: :OR, name: '4.1' },
            { type: :OR, name: '4.2' },
            { type: :SR },
            { type: :OR, name: '5.1' },
            { type: :OR, name: '5.2' },
            { type: :End },
          ]
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            GSteamOverHolland::Step::SelectionAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            GSteamOverHolland::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          GSteamOverHolland::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Assign,
            Engine::Step::SpecialToken,
            Engine::Step::SpecialTrack,
            Engine::Step::HomeToken,
            Engine::Step::BuyCompany,
            GSteamOverHolland::Step::IssueShares,
            GSteamOverHolland::Step::Track,
            GSteamOverHolland::Step::Token,
            Engine::Step::Route,
            GSteamOverHolland::Step::Dividend,
            Engine::Step::DiscardTrain,
            GSteamOverHolland::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        # needed for the fixed number of rounds in this game
        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = 2
              clear_programmed_actions
              reorder_players
              new_operating_round
            when Engine::Round::Operating
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
              reorder_players
              new_stock_round
            end
        end

        def new_operating_round(round_num = 1)
          @or += 1

          super
        end

        # Game ends after the end of OR 5.2
        def game_end_check_fixed_round?
          @or == LAST_OR
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['No dividend', '1 ←'],
            ['Dividend < stock price', 'none'],
            ['Dividend ≥ stock price', '1 →'],
            ['Dividend ≥ 2X stock price', '2 →'],
            ['Corporation issues shares', '← 1 less than the number of shares issued'],
          ]
        end

        def percent_to_float
          return 20 if @phase.name == '2'
          return 30 if @phase.name == '3'
          return 40 if @phase.name == '4'
          return 50 if @phase.name == '5'
          return 60 if @phase.name == '6'

          # This shouldn't happen
          raise NotImplementedError
        end

        def float_str(entity)
          "Buy #{percent_to_float}% to float" if entity.corporation? && entity.floatable
        end

        def event_float_30!
          @log << "-- Event: #{EVENTS_TEXT['float_30'][1]} --"
          @float_percent = 30
          non_floated_corporations { |c| c.float_percent = @float_percent }
        end

        def event_float_40!
          @log << "-- Event: #{EVENTS_TEXT['float_40'][1]} --"
          @float_percent = 40
          non_floated_corporations { |c| c.float_percent = @float_percent }
        end

        def event_float_50!
          @log << "-- Event: #{EVENTS_TEXT['float_50'][1]} --"
          @float_percent = 50
          non_floated_corporations { |c| c.float_percent = @float_percent }
        end

        def event_float_60!
          @log << "-- Event: #{EVENTS_TEXT['float_60'][1]} --"
          @float_percent = 60
          non_floated_corporations { |c| c.float_percent = @float_percent }
        end

        def non_floated_corporations
          @corporations.each { |c| yield c unless c.floated? }
        end

        def check_distance(route, visits, train = nil)
          raise GameError, 'Route cannot begin/end in a town' if visits.first.town? || visits.last.town?

          super
        end

        def revenue_for(route, stops)
          revenue = super

          Array(abilities(route.corporation, :hex_bonus)).each do |ability|
            revenue += ability.amount * stops.count { |s| ability.hexes.include?(s.hex.id) }
          end

          revenue
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          price_drop = bundle.num_shares
          corporation = bundle.corporation
          old_price = corporation.share_price

          # when issuing shares, price drops one space fewer than the number of shares issued
          price_drop -= 1 if corporation == bundle.owner
          @round.issued_shares[bundle.corporation] = true if corporation == bundle.owner

          # This section below allows for the ledges that prevent price drops unless the president is selling
          unless corporation.president?(bundle.owner)
            case corporation.share_price.type
            when :ignore_sale_unless_president
              price_drop = 0
            when :max_one_drop_unless_president
              price_drop = 1
            when :max_two_drops_unless_president
              price_drop = 2 unless price_drop == 1
            end
          end

          @share_pool.sell_shares(bundle)
          price_drop.times { @stock_market.move_left(corporation) }
          log_share_price(corporation, old_price) if sell_movement(corporation) != :none
        end

        def issuable_shares(entity)
          return [] if @round.issued_shares[entity]

          num_shares = [entity.num_player_shares, 5 - entity.num_market_shares].min
          bundles = bundles_for_corporation(entity, entity)
          share_price = stock_market.find_share_price(entity, :current).price

          bundles
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.num_shares > num_shares }
        end

        def redeemable_shares(entity)
          return [] if @round.issued_shares[entity]

          share_price = stock_market.find_share_price(entity, :current).price

          bundles_for_corporation(share_pool, entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def emergency_issuable_bundles(entity)
          return [] if @round.issued_shares[entity] || entity.cash >= @depot.min_depot_price

          num_shares = [entity.num_player_shares, 5 - entity.num_market_shares].min

          bundles_for_corporation(entity, entity).reject { |bundle| bundle.num_shares > num_shares }
        end

        def upgrades_to_correct_city_town?(from, to)
          return true if from.towns.size == 1 && to.towns.size == 2

          super
        end

        def upgrade_cost(tile, _hex, entity, spender)
          terrain_cost = tile.upgrades.sum(&:cost)
          discounts = 0

          # Tile discounts must be activated
          if entity.company? && (ability = entity.all_abilities.find { |a| a.type == :tile_discount })
            discounts = tile.upgrades.sum do |upgrade|
              next unless upgrade.terrains.include?(ability.terrain)

              discount = [upgrade.cost, ability.discount].min
              log_cost_discount(spender, ability, discount) if discount.positive?
              discount
            end
          end

          terrain_cost - discounts
        end
      end
    end
  end
end
