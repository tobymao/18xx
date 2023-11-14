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

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 18, 3 => 16, 4 => 14, 5 => 12 }.freeze

        STARTING_CASH = { 2 => 600, 3 => 400, 4 => 300, 5 => 240 }.freeze

        OR_SETS = [2, 2, 2, 2, 2].freeze

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :operate
        SOLD_OUT_INCREASE = false

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
            { price: 100, types: [:par] },
            { price: 110, types: [:ignore_sale_unless_president] },
            { price: 125, types: [:max_one_drop_unless_president] },
            { price: 140, types: [:max_two_drops_unless_president] },
            { price: 160, types: [:ignore_sale_unless_president] },
            { price: 180, types: [:max_one_drop_unless_president] },
            { price: 210, types: [:max_two_drops_unless_president] },
            { price: 240, types: [:ignore_sale_unless_president] },
            { price: 270, types: [:max_one_drop_unless_president] },
            { price: 300, types: [:max_two_drops_unless_president] },
            { price: 330, types: [:ignore_sale_unless_president] },
            { price: 360, types: [:endgame] },
          ],
        ].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par: :yellow, ignore_unless_president: :green).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          ignore_unless_president: 'Price will not drop below these values in Stock Round unless president sells'
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

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 1 },
                  { name: '3', distance: 3, price: 200, rusts_on: '5', num: 4, events: [{ 'type' => 'float_30' }], },
                  { name: '4', distance: 4, price: 300, rusts_on: '6', num: 3, events: [{ 'type' => 'float_40' }], },
                  {
                    name: '5',
                    distance: 3,
                    price: 400,
                    num: 3,
                    events: [{ 'type' => 'close_companies' },
                             { 'type' => 'float_50' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 500,
                    num: 6,
                    events: [{ 'type' => 'float_60' }],
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
                  }].freeze

        GAME_END_CHECK = { custom: :current_or, stock_market: :current }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Fixed number of ORs',
          stock_market: 'Company reached the top of the market.',
        ).freeze

        GAME_END_REASONS_TIMING_TEXT = Base::EVENTS_TEXT.merge(
          full_or: 'Ends after the final OR set.',
          current: 'Ends after this OR.'
        ).freeze

        def setup_preround
          # randomize the private companies, choose an amount equal to player count, sort numerically
          @companies = @companies.sort_by { rand }.take(@players.size).sort_by(&:name)
        end

        def setup
          setup_company_price_up_to_face
          @or = 0
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
            Engine::Step::SelectionAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            GSteamOverHolland::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Assign,
            Engine::Step::SpecialToken,
            Engine::Step::SpecialTrack,
            Engine::Step::HomeToken,
            Engine::Step::BuyCompany,
            GSteamOverHolland::Step::IssueShares,
            GSteamOverHolland::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            GSteamOverHolland::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
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

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'float_30' => ['30% to Float', "Corporation's President must buy 30% to float"],
          'float_40' => ['40% to Float', "Corporation's President must buy 40% to float"],
          'float_50' => ['50% to Float', "Corporation's President must buy 50% to float"],
          'float_60' => ['60% to Float', "Corporation's President must buy 60% to float"],
          'close_companies' => ['Close Companies', 'Companies close and are removed from the game'],
        ).freeze

        def percent_needed_to_float
          case @phase.name
          when '2'
            20
          when '3'
            30
          when '4'
            40
          when '5'
            50
          when '6'
            60
          else
            # This shouldn't happen
            raise NotImplementedError
          end
        end

        def event_float_30!
          @log << "-- Event: #{EVENTS_TEXT['float_30'][1]} --"
          update_float_percent(30)
        end

        def event_float_40!
          @log << "-- Event: #{EVENTS_TEXT['float_40'][1]} --"
          update_float_percent(40)
        end

        def event_float_50!
          @log << "-- Event: #{EVENTS_TEXT['float_50'][1]} --"
          update_float_percent(50)
        end

        def event_float_60!
          @log << "-- Event: #{EVENTS_TEXT['float_60'][1]} --"
          update_float_percent(60)
        end

        def update_float_percent(percent)
          @corporations.each do |c|
            c.float_percent = percent
          end
        end

        def issuable_shares(entity)
          return [] unless round.steps.find { |step| step.instance_of?(GSteamOverHolland::Step::IssueShares) }.active?

          num_shares = entity.num_player_shares - entity.num_market_shares
          bundles = bundles_for_corporation(entity, entity)
          share_price = stock_market.find_share_price(entity, :current).price

          bundles
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.num_shares > num_shares }
        end

        def redeemable_shares(entity)
          return [] unless round.steps.find { |step| step.instance_of?(GSteamOverHolland::Step::IssueShares) }.active?

          share_price = stock_market.find_share_price(entity, :current).price

          bundles_for_corporation(share_pool, entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| entity.cash < bundle.price }
        end

        # def can_ipo_any?(entity)
        #   extra_shares_needed = (percent_needed_to_float / 10 - 2).to_i
        #   !bought? && @game.corporations.any? do |c|
        #     @game.can_par?(c, entity) && begin
        #       bundle = c.shares.first&.to_bundle
        #       bundle ||= ShareBundle.new(c.shares, 0)
        #       bundle.num_shares += c.extra_shares_needed
        #       return false unless can_buy?(entity, bundle)
        #     end
        #   end
        # end
      end
    end
  end
end
