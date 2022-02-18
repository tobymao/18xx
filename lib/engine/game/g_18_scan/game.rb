# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Scan
      class Game < Game::Base
        include_meta(G18Scan::Meta)
        include Map
        include Entities

        GAME_END_CHECK = { bank: :full_or }.freeze

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        BANK_CASH = 6_000

        CURRENCY_FORMAT_STR = 'K%d'

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = true

        SELL_AFTER = :operate

        SELL_BUY_ORDER = :sell_buy

        HOME_TOKEN_TIMING = :float

        MUST_BUY_TRAIN = :always

        CERT_LIMIT = { 2 => 18, 3 => 12, 4 => 9 }.freeze

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        # Custom constants
        SJ_NAME = 'SJ'

        SJ_START_PRICE = 100

        MINOR_SUBSIDY = 10

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'float_3' => [
            '30% to float',
            'An unstarted corporation needs 30% sold to start for the first time',
          ],
          'float_4' => [
            '40% to float',
            'An unstarted corporation needs 40% sold to start for the first time',
          ],
          'float_5' => [
            '50% to float',
            'An unstarted corporation needs 50% sold to start for the first time',
          ],
          'close_minors' => [
            'SJ merger',
            'Minors are closed, transferring all assets to SJ. Minor owners get a 10% SJ share',
          ],
          'full_cap' => [
            'Full Capitalization',
            'All unfloated corporations will receive full funding on float',
          ],
        ).freeze

        STATUS_TEXT = {
          'sj_can_float' => [
            'SJ can float',
            'SJ can float if 50% of its shares are sold, receiving K700 from the bank',
          ],
        }.freeze

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %w[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 2, major: 3 },
            tiles: %w[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { national: 3, major: 2 },
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            status: %w[sj_can_float],
          },
          {
            name: '5E',
            on: '5E',
            train_limit: { national: 3, major: 2 },
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            status: %w[sj_can_float],
          },
          {
            name: '4D',
            on: '4D',
            train_limit: { national: 3, major: 2 },
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            status: %w[sj_can_float],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 6,
            variants: [
              {
                name: '1+1',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1 },
                  { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                ],
                price: 80,
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '5',
            num: 4,
            variants: [
              {
                name: '2+2',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 2, 'visit' => 2 },
                  { 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                ],
                price: 180,
              },
            ],
            events: [
              { 'type' => 'float_3' },
            ],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '4D',
            num: 3,
            variants: [
              {
                name: '3+3',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
                  { 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                ],
                price: 280,
              },
            ],
            events: [
              { 'type' => 'float_4' },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            variants: [
              {
                name: '4+4',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 4, 'visit' => 4 },
                  { 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 },
                ],
                price: 480,
              },
            ],
            events: [
              { 'type' => 'float_5' },
              { 'type' => 'close_companies' },
              { 'type' => 'full_cap' },
              { 'type' => 'close_minors' },
            ],
          },
          {
            name: '5E',
            distance: [
              { 'nodes' => ['city'], 'pay' => 5, 'visit' => 5 },
              { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
            ],
            available_on: '5',
            price: 600,
            num: 2,
          },
          {
            name: '4D',
            distance: [
              { 'nodes' => ['city'], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 },
              { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
            ],
            available_on: '5E',
            price: 800,
            num: 2,
          },
        ].freeze

        def setup
          # Minors come with a trade-in share of SJ
          minors.each do |minor|
            share = sj_share_by_minor(minor.name)
            share.buyable = false
            share.counts_for_limit = false

            # Reserve token locations for minors
            cities = hex_by_id(minor.coordinates).tile.cities

            if minor.city
              cities[minor.city].add_reservation!(minor)
            else
              cities.first.add_reservation!(minor)
            end
          end
        end

        def corporation_opts
          two_player? && @optional_rules&.include?(:two_player_share_limit) ? { max_ownership_percent: 70 } : {}
        end

        def all_corporations
          minors + corporations
        end

        def new_auction_round
          Round::Auction.new(self, [
            G18Scan::Step::CompanyPendingPar,
            G18Scan::Step::WaterfallAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18Scan::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18Scan::Step::Track,
            # G18Scan::Step::DestinationToken
            # G18Scan::Step::DestinationRun
            Engine::Step::Token,
            # G18Scan::Step::BonusToken
            Engine::Step::Route,
            G18Scan::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Scan::Step::BuyTrain,
          ], round_num: round_num)
        end

        def ipo_name
          'Treasury'
        end

        def sj
          @sj ||= corporation_by_id('SJ')
        end

        def mine
          @mine ||= company_by_id('Mine')
        end

        def mine_included(route)
          route.corporation.assigned?(mine.id) && route.hexes.any? { |h| h.id == 'A20' }
        end

        def ferry
          @ferry ||= company_by_id('Ferry')
        end

        def ferry_included(route)
          route.corporation.assigned?(ferry.id) && route.hexes.any? { |h| h.id == 'L7' }
        end

        def float_str(entity)
          return 'Floats in phase 5' if entity == sj && !entity.floatable

          super
        end

        def float_corporation(corporation)
          return super unless corporation == sj

          @log << "#{corporation.name} floats"

          initial_cash = corporation.par_price.price * 7
          @bank.spend(initial_cash, corporation)

          @log << "#{corporation.name} receives #{format_currency(initial_cash)}"
        end

        def revenue_for(route, stops)
          revenue = super

          revenue += 20 if ferry_included(route)
          revenue += 50 if mine_included(route)

          revenue
        end

        def revenue_str(route)
          str = super

          str += ' + Stockholm-Åbo Ferry' if ferry_included(route)
          str += ' + Lapland Ore Mine' if mine_included(route)

          str
        end

        def check_connected(route, corporation)
          super(route, corporation)

          route.visited_stops.each do |node|
            # Cannot rely on offboard? because all of them are cities
            if node.tile.color == :red && node.city? && !node.tokened_by?(corporation)
              raise GameError, 'Can only run to tokened offboards'
            end
          end
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # Y cities are same as plain in yellow
          return to.name == '5' if from.color == :white && from.label.to_s == 'Y'

          # Copenhagen
          return to.name == '121' if from.name == '403'
          return to.name == '584' if from.name == '121'

          # Oslo
          return to.name == '623' if from.name == '622' && from.hex.name == 'D7'

          # Helsinki, Stockholm
          return to.name == '582' if from.name == '622' && %w[G14 F11].include?(from.hex.name)

          super
        end

        def copenhagen_dit_upgrade(from, to)
          from.name == '403' && to.name == '121'
        end

        def update_float_percent(percent)
          @corporations.each do |corporation|
            next if corporation.floated? || corporation == sj

            corporation.float_percent = percent
          end

          @log << "-- Event: New corporations need #{percent}% shares sold to float --"
        end

        def event_float_3!
          update_float_percent(30)
        end

        def event_float_4!
          update_float_percent(40)
        end

        def event_float_5!
          update_float_percent(50)
        end

        def event_full_cap!
          @corporations.each do |corp|
            next if corp.floated?

            corp.capitalization = :full
            corp.spend(corp.cash, bank) if corp.cash.positive?
          end

          @log << '-- Event: New corporations will be started as full capitalization --'
        end

        def event_close_minors!
          sj.floatable = true
          sj.spend(sj.cash, bank) if sj.cash.positive?

          @minors.each { |minor| merge_and_close_minor(minor) }

          @log << "-- Event: #{sj.name} is formed --"
        end

        def sj_share_by_minor(name)
          @reserved_shares ||= {}
          @reserved_shares[name] ||=
            case name
            when '1'
              sj.shares[6]
            when '2'
              sj.shares[7]
            when '3'
              sj.shares[8]
            end
        end

        def merge_and_close_minor(minor)
          company = company_by_id(minor.name)
          share = sj_share_by_minor(minor.name)

          msg = "#{minor.name} merges into #{sj.name}"
          msg += ' receiving' if minor.cash.positive? || minor.trains.any?
          msg += " #{minor.trains.map(&:name).join(', ')}" if minor.trains.any?
          msg += ' and' if minor.cash.positive? && minor.trains.any?
          msg += " #{format_currency(minor.cash)}" if minor.cash.positive?
          @log << msg

          # Award reserved share
          share.buyable = true
          @share_pool.buy_shares(minor.player, share, exchange: :free, exchange_price: 0)

          # Transfer tokens
          minor.tokens.dup.each do |token|
            if !token.hex || token.hex.tile.cities.any? { |c| c.tokened_by?(sj) }
              token.remove!
            else
              token.swap!(sj.next_token)
            end
          end

          minor.spend(minor.cash, sj) if minor.cash.positive?

          # Transfer trains
          minor.trains.dup.each do |train|
            buy_train(sj, train, :free)
          end

          minor.close!
          company.close!
        end
      end
    end
  end
end
