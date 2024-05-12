# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'companies'
require_relative 'corporations'
require_relative 'map'
require_relative 'trains'
require_relative 'phases'

module Engine
  module Game
    module G18Norway
      class Game < Game::Base
        include_meta(G18Norway::Meta)
        include Companies
        include Corporations
        include Map
        include Trains
        include Phases

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '%skr'
        EBUY_SELL_MORE_THAN_NEEDED = true
        CAPITALIZATION = :incremental
        MUST_BUY_TRAIN = :always
        POOL_SHARE_DROP = :left_block
        SELL_AFTER = :p_any_operate
        SELL_MOVEMENT = :left_block
        CERT_LIMIT_COUNTS_BANKRUPTED = true
        HOME_TOKEN_TIMING = :float

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true

        BANKRUPTCY_ENDS_GAME_AFTER = :one

        BANK_CASH = 999_000

        GAME_END_CHECK = { bankrupt: :immediate, custom: :one_more_full_or_set }.freeze

        CERT_LIMIT = {
          3 => { 0 => 12, 1 => 12, 2 => 12, 3 => 15, 4 => 15, 5 => 17, 6 => 17, 7 => 19, 8 => 19 },
          4 => { 0 => 9, 1 => 9, 2 => 9, 3 => 11, 4 => 11, 5 => 13, 6 => 13, 7 => 15, 8 => 15 },
          5 => { 0 => 7, 1 => 7, 2 => 7, 3 => 9, 4 => 9, 5 => 10, 6 => 10, 7 => 12, 8 => 12 },
        }.freeze

        STARTING_CASH = { 3 => 400, 4 => 300, 5 => 240 }.freeze

        MARKET = [
          %w[0c 10f 20f 30f 40f
             50p 60p 70p 80p 90p 100p 112p 124p 137p 150p
             165Y 180Y 195Y 220Y 245Y 270Y 300Y 330Y 365Y 400Y 440Y 480Y],
           ].freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          pays_bonus_3: :white,
          only_president: :gray
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(
          pays_bonus_3: 'Triple jump if dividend ≥ 3X',
          only_president: 'Move left only when president sells'
        )

        ASSIGNMENT_TOKENS = {
          'MOUNTAIN_SMALL' => '/icons/hill.svg',
          'MOUNTAIN_BIG' => '/icons/mountain.svg',
        }.freeze

        def hovedbanen
          @hovedbanen ||= corporation_by_id('H')
        end

        def hovedbanen?(corporation)
          hovedbanen == corporation
        end

        def nsb
          @nsb ||= corporation_by_id('NSB')
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend < 1/2 stock price', '1 ←'],
            ['Dividend ≥ 1/2 stock price but < stock price', 'none'],
            ['Dividend ≥ stock price', '1 →'],
            ['Dividend ≥ 2X stock price', '2 →'],
            ['Dividend ≥ 3X stock price and stock price ≥ 165', '3 →'],
            ['Any number of shares sold', '1 ←'],
            ['Corporation has any shares in the Market at end of an SR', '1 ←'],
            ['Corporation is sold out at end of an SR', '1 →'],
          ]
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        MOUNTAIN_BIG_HEXES = %w[E21 G21 H22 F26 E27 E29 D30].freeze
        MOUNTAIN_SMALL_HEXES = %w[G19 E23 D26 D28 F28 G27 H28].freeze

        def setup
          MOUNTAIN_BIG_HEXES.each { |hex| hex_by_id(hex).assign!('MOUNTAIN_BIG') }
          MOUNTAIN_SMALL_HEXES.each { |hex| hex_by_id(hex).assign!('MOUNTAIN_SMALL') }
          corporation_by_id('R').add_ability(Engine::Ability::Base.new(
            type: 'free_tunnel',
            description: 'Free tunnel'
          ))
        end

        def p4
          @p4 ||= company_by_id('P4')
        end

        def thunes_mekaniske
          @thunes_mekaniske ||= company_by_id('P2')
        end

        def owns_thunes_mekaniske?(owner)
          thunes_mekaniske.owner == owner
        end

        def big_mountain?(hex)
          hex.assignments.include?('MOUNTAIN_BIG')
        end

        def small_mountain?(hex)
          hex.assignments.include?('MOUNTAIN_SMALL')
        end

        def mountain?(hex)
          big_mountain?(hex) || small_mountain?(hex)
        end

        def route_cost(route)
          # P2 Thunes mekaniske verksted do not need to pay maintainance
          return 0 if owns_thunes_mekaniske?(route.train.owner)

          route.all_hexes.count { |hex| mountain?(hex) } * 10
        end

        def check_other(route)
          track_types = route.chains.flat_map { |connections| connections[:paths] }.flat_map(&:track).uniq

          raise GameError, 'Ships cannot run on land' if ship?(route.train) && track_types != [route.train.track_type]
          raise GameError, 'Trains cannot run on water' if !ship?(route.train) && track_types.include?(:narrow)

          cost = route_cost(route)
          raise GameError, 'Cannot afford the fees for this route' if route.train.owner.cash < cost
        end

        def revenue_str(route)
          str = super
          cost = route_cost(route)
          str += " -Fee(#{cost})" if cost.positive?
          str
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            G18Norway::Step::Track,
            G18Norway::Step::BuildTunnel,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Norway::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18Norway::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def ship?(train)
          train.track_type == :narrow
        end

        def cheapest_train_price
          depot_trains = depot.depot_trains.reject { |train| ship?(train) }
          train = depot_trains.min_by(&:price)
          train.price
        end

        def can_go_bankrupt?(player, corporation)
          total_emr_buying_power(player, corporation) < cheapest_train_price
        end

        def new_nationalization_round(round_num)
          G18Norway::Round::Nationalization.new(self, [
              G18Norway::Step::NationalizeCorporation,
              ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when G18Norway::Round::Nationalization
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
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
                new_nationalization_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def nationalized?(entity)
          entity.type == :nationalized
        end

        def convert(corporation, number_of_shares)
          shares = @_shares.values.select { |share| share.corporation == corporation }

          shares.each { |share| share.percent /= 2 }
          new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          new_shares.each do |share|
            add_new_share(share)
          end
          corporation.type = :nationalized

          return 0 if number_of_shares.zero?

          bundle = ShareBundle.new(new_shares.take(number_of_shares))
          @bank.spend(bundle.price, corporation)
          share_pool.buy_shares(nsb, bundle, exchange: :free)

          bundle.price
        end

        def can_par?(corporation, _parrer)
          nsb != corporation
        end
      end
    end
  end
end
