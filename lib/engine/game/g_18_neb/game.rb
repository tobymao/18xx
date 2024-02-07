# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Neb
      class Game < Game::Base
        include_meta(G18Neb::Meta)
        include Entities
        include Map

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 26, 3 => 17, 4 => 13 }.freeze

        STARTING_CASH = { 2 => 650, 3 => 450, 4 => 350 }.freeze

        MIN_BID_INCREMENT = 5
        ONLY_HIGHEST_BID_COMMITTED = true

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :par

        # TODO: end of SR movement down and right if at top
        # TODO OR movement must pay stock price to move right

        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        MUST_SELL_IN_BLOCKS = true

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100p 110 122 135 150 165 180 200 220 245 270 300 330 360],
          %w[70 75 82 90p 100 110 122 135 150 165 180 200 220],
          %w[65 70 75 82p 90 100 110 122 135 150 165],
          %w[60 65 70 75p 82 90 100 110],
          %w[50 60 65 70p 75 82],
          %w[40 50 60 65 70],
          %w[30 40 50 60],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_morison_bridging'],
          },
          {
            name: '3',
            on: '3+3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4+4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5/7',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6/8',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '4D',
            on: '4D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[town], 'pay' => 2 },
                       { 'nodes' => %w[town city offboard], 'pay' => 2 }],
            price: 100,
            rusts_on: '4+4',
            num: 5,
          },
          {
            name: '3+3',
            distance: [{ 'nodes' => %w[town], 'pay' => 3 },
                       { 'nodes' => %w[town city offboard], 'pay' => 3 }],
            price: 200,
            rusts_on: '6/8',
            num: 4,
          },
          {
            name: '4+4',
            distance: [{ 'nodes' => %w[town], 'pay' => 4 },
                       { 'nodes' => %w[town city offboard], 'pay' => 4 }],
            price: 300,
            rusts_on: '4D',
            num: 3,
          },
          {
            name: '5/7',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 7 }],
            price: 450,
            num: 2,
            events: [{ 'type' => 'close_companies' },
                     { 'type' => 'full_capitalization' },
                     { 'type' => 'local_railways_available' }],
          },
          {
            name: '6/8',
            distance: [{ 'pay' => 6, 'visit' => 8 }],
            price: 600,
            num: 2,
          },
          {
            name: '4D',
            # Can pick 4 best city or offboards, skipping smaller cities.
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 99, 'multiplier' => 2 },
                       { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
            price: 900,
            num: 20,
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
        ].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_morison_bridging' => ['Can Buy Morison Bridging Company'],
        )

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'full_capitalization' => ['Full Capitalization',
                                    'Newly started 10-share corporations receive remaining capitalization once 5 shares sold'],
          'local_railways_available' => ['Local Railways Available', 'Local Railways can now be started'],
        )

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face

        # Two tiles can be laid, only one upgrade
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, cost: 20, upgrade: :not_if_upgraded }].freeze

        def morison_bridging_company
          @morison_bridging_company ||= @companies.find { |company| company.id == 'P2' }
        end

        def setup_preround
          setup_company_purchase_prices
        end

        def setup_company_purchase_prices
          @companies.each do |company|
            if company == morison_bridging_company
              set_company_purchase_price(company, 1.0, 1.0)
            else
              set_company_purchase_price(company, 0.5, 1.5)
            end
          end
        end

        def set_company_purchase_price(company, min_multiplier, max_multiplier)
          company.min_price = (company.value * min_multiplier).ceil
          company.max_price = (company.value * max_multiplier).floor
        end

        def setup
          @corporations_to_fully_capitalize = []
        end

        def event_full_capitalization!
          @log << "-- Event: #{EVENTS_TEXT['full_capitalization'][1]} --"
          @corporations_fully_capitalize = true
        end

        def event_local_railways_available!
          @log << "-- Event: #{EVENTS_TEXT['local_railways_available'][1]} --"
          @locals_available = true
        end

        def reorder_players(order = nil, log_player_order: false)
          @round.is_a?(Round::Auction) ? super(:most_cash, log_player_order: true) : super
        end

        def init_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18Neb::Step::BidAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::SpecialTrack,
            G18Neb::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G18Neb::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [G18Neb::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if town_to_city_upgrade?(from, to)

          super
        end

        def town_to_city_upgrade?(from, to)
          %w[3 4 58].include?(from.name) && %w[X01 X02 X03].include?(to.name)
        end

        def purchasable_companies(entity = nil)
          if @phase.status.include?('can_buy_morison_bridging') &&
              morison_bridging_company&.owner&.player? &&
              entity != morison_bridging_company.owner
            [morison_bridging_company]
          elsif @phase.status.include?('can_buy_companies')
            super
          else
            []
          end
        end

        def after_phase_change(name)
          set_company_purchase_price(morison_bridging_company, 0.5, 1.5) if name == '3' && morison_bridging_company
        end

        def after_par(corporation)
          super
          @corporations_to_fully_capitalize << corporation if corporations_fully_capitalize?
        end

        def corporations_fully_capitalize?
          @corporations_fully_capitalize
        end

        def locals_available?
          @locals_available
        end

        def can_par?(corporation, _parrer)
          return false if corporation.type == :local && !locals_available?

          super
        end

        def check_for_full_capitalization(corporation)
          return unless corporation.num_ipo_shares == 5
          return unless @corporations_to_fully_capitalize.delete(corporation)

          @bank.spend(coproration.num_ipo_shares * corporation.par_price.price, corporation)
          @share_pool.transfer_shares(ShareBundle.new(corporation.shares_of(corporation)), @share_pool)
          @log << "#{corporation.name} receives 5x its starting price in its treasury. " \
                  "#{corporation.name}'s remaining shares are placed in the market"
        end

        def issuable_shares(entity)
          max_issuable = (entity.total_shares * 0.5).floor - entity.num_market_shares
          return [] unless max_issuable.positive?

          bundles_for_corporation(entity, entity, shares: entity.shares_of(entity).first(max_issuable))
        end

        def redeemable_shares(entity)
          [@share_pool.shares_of(entity).find { |s| s.price <= entity.cash }&.to_bundle].compact
        end

        def operating_order
          corporations = @corporations.select(&:floated?)
          if @normal_operating_order
            corporations.sort
          else
            @normal_operating_order = true
            corporations.sort_by do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          end
        end
      end
    end
  end
end
