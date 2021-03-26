# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'step/charter_auction'

module Engine
  module Game
    module G1862
      class Game < Game::Base
        include_meta(G1862::Meta)
        include Entities
        include Map

        register_colors(black: '#000000',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#ff0000',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 15_000

        CERT_LIMIT = {
          2 => 25,
          3 => 18,
          4 => 13,
          5 => 11,
          6 => 10,
          7 => 9,
          8 => 8,
        }.freeze

        STARTING_CASH = {
          2 => 1200,
          3 => 800,
          4 => 600,
          5 => 480,
          6 => 400,
          7 => 345,
          8 => 300,
        }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[0c
             7i
             14i
             20i
             26i
             31i
             36i
             40
             44
             47
             50
             52
             54p
             56r
             58p
             60r
             62p
             65r
             68p
             71r
             74p
             78r
             82p
             86r
             90p
             95r
             100p
             105r
             110r
             116r
             122r
             128r
             134r
             142r
             150r
             158r
             166r
             174r
             182r
             191r
             200r
             210i
             220i
             232i
             245i
             260i
             275i
             292i
             310i
             330i
             350i
             375i
             400i
             430i
             495i
             530i
             570i
             610i
             655i
             700i
             750i
             800i
             850i
             900i
             950i
             1000e],
           ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3+2',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '4',
                    on: '4+2',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '5+3',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '6',
                    on: '6+3',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '7',
                    on: '7+4',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '8',
                    on: '8+4',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '9',
                    on: '9+5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
          {
            name: '2+1',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[town halt], 'pay' => 1, 'visit' => 99 }],
            price: 250,
            rusts_on: '4+2',
            num: 5,
          },
          {
            name: '3+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => %w[town halt], 'pay' => 2, 'visit' => 99 }],
            price: 300,
            rusts_on: '6+3',
            num: 4,
          },
          {
            name: '4+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => %w[town halt], 'pay' => 2, 'visit' => 99 }],
            price: 350,
            rusts_on: '7+4',
            num: 3,
          },
          {
            name: '5+3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[town halt], 'pay' => 3, 'visit' => 99 }],
            price: 400,
            rusts_on: '8+4',
            num: 2,
          },
          {
            name: '6+3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => %w[town halt], 'pay' => 3, 'visit' => 99 }],
            price: 500,
            num: 2,
            events: [{ 'type' => 'fishbourne_to_bank' }],
          },
          {
            name: '7+4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => %w[town halt], 'pay' => 4, 'visit' => 99 }],
            price: 600,
            num: 1,
          },
          {
            name: '8+4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => %w[town halt], 'pay' => 4, 'visit' => 99 }],
            price: 700,
            num: 1,
            events: [{ 'type' => 'relax_cert_limit' }],
          },
          {
            name: '9+5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 9, 'visit' => 9 },
                       { 'nodes' => %w[town halt], 'pay' => 5, 'visit' => 99 }],
            price: 800,
            num: 16,
            events: [{ 'type' => 'southern_forms' }],
          },
        ].freeze

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :float
        SELL_AFTER = :any_time
        SELL_BUY_ORDER = :sell_buy
        MARKET_SHARE_LIMIT = 100
        TRAIN_PRICE_MIN = 10
        TRAIN_PRICE_MULTIPLE = 10

        SOLD_OUT_INCREASE = false

        STOCKMARKET_COLORS = {
          par: :yellow,
          endgame: :orange,
          close: :purple,
          repar: :gray,
          ignore_one_sale: :olive,
          multiple_buy: :brown,
          unlimited: :orange,
          no_cert_limit: :yellow,
          liquidation: :red,
          acquisition: :yellow,
          safe_par: :white,
        }.freeze

        MARKET_TEXT = {
          par: 'Par values for chartered corporations',
          no_cert_limit: 'UNUSED',
          unlimited: 'UNUSED',
          multiple_buy: 'UNUSED',
          close: 'Corporation bankrupts',
          endgame: 'End game trigger',
          liquidation: 'UNUSED',
          repar: 'Par values for unchartered corporations',
          ignore_one_sale: 'Ignore first share sold when moving price (except president)',
        }.freeze

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded_or_city, upgrade: false }].freeze

        GAME_END_CHECK = { stock_market: :current_or, bank: :current_or, custom: :immediate }.freeze

        def init_share_pool
          SharePool.new(self, allow_president_sale: true)
        end

        def init_companies(players)
          clist = super

          # create charter companies on the fly based on corporations
          game_corporations.map do |corp|
            description = "Parliamentary Charter for #{corp[:name]}"
            name = "#{corp[:sym]} Charter"

            clist << Company.new(sym: corp[:sym], name: name, value: 0, revenue: 0, desc: description)
          end

          clist
        end

        def setup; end

        # FIXME
        def available_charters
          @companies.reject { |c| c.name.include?('Dummy') }
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: true)
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1862::Step::CharterAuction,
          ])
        end

        def next_round!
          @round =
            case @round
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
                new_stock_round
              end
            when init_round.class
              init_round_finished
              new_stock_round
            end
        end

        def make_bankrupt!(corp)
          return if bankrupt?(corp)

          @bankrupt_corps << corp
          @log << "#{corp.name} enters Bankruptcy"

          # un-IPO the corporation
          corp.share_price.corporations.delete(corp)
          corp.share_price = nil
          corp.par_price = nil
          corp.ipoed = false
          corp.unfloat!

          # return shares to IPO
          # FIXME: compensate former owners of shares if share price is not zero
          corp.share_holders.keys.each do |share_holder|
            next if share_holder == corp

            shares = share_holder.shares_by_corporation[corp].compact
            corp.share_holders.delete(share_holder)
            shares.each do |share|
              share_holder.shares_by_corporation[corp].delete(share)
              share.owner = corp
              corp.shares_by_corporation[corp] << share
            end
          end
          corp.shares_by_corporation[corp].sort_by!(&:index)
          corp.share_holders[corp] = 100
          corp.owner = nil

          # FIXME: is there a better way to do this?
          @round.force_next_entity! if @round.operating?
        end

        # FIXME
        def status_array(corp)
          status = []
          status << %w[Receivership bold] if corp.receivership?

          status
        end

        # FIXME: need to check for no trains?
        def check_bankruptcy!(entity)
          return unless entity.corporation?

          make_bankrupt!(entity) if entity.share_price&.type == :close
        end

        def corporation_available?(entity)
          entity.corporation? && can_ipo?(entity)
        end

        # FIXME: changes from 1860?
        def bundles_for_corporation(share_holder, corporation, shares: nil)
          return [] unless corporation.ipoed

          shares = (shares || share_holder.shares_of(corporation)).sort_by(&:price)

          shares.flat_map.with_index do |share, index|
            bundle = shares.take(index + 1)
            percent = bundle.sum(&:percent)
            bundles = [Engine::ShareBundle.new(bundle, percent)]
            if share.president
              normal_percent = corporation.share_percent
              difference = corporation.presidents_percent - normal_percent
              num_partial_bundles = difference / normal_percent
              (1..num_partial_bundles).each do |n|
                bundles.insert(0, Engine::ShareBundle.new(bundle, percent - (normal_percent * n)))
              end
            end
            bundles.each { |b| b.share_price = (b.price_per_share / 2).to_i if corporation.trains.empty? }
            bundles
          end
        end

        def selling_movement?(corporation)
          corporation.operated? && !@no_price_drop_on_sale
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          corporation = bundle.corporation
          price = corporation.share_price.price

          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          num_shares = bundle.num_shares
          num_shares -= 1 if corporation.share_price.type == :ignore_one_sale
          num_shares.times { @stock_market.move_left(corporation) } if selling_movement?(corporation)
          log_share_price(corporation, price)
          check_bankruptcy!(corporation)
        end

        def legal_route?(entity)
          @graph.route_info(entity)&.dig(:route_train_purchase)
        end

        # at least one route must include home token
        def check_home_token(corporation, routes)
          tokens = get_token_cities(corporation)
          home_city = tokens.find { |c| c.hex == hex_by_id(corporation.coordinates) }
          found = false
          routes.each { |r| found ||= r.visited_stops.include?(home_city) } if home_city
          raise GameError, 'At least one route must include home token' unless found
        end

        def visit_route(ridx, intersects, visited)
          return if visited[ridx]

          visited[ridx] = true
          intersects[ridx].each { |i| visit_route(i, intersects, visited) }
        end

        # all routes must intersect each other
        def check_intersection(routes)
          actual_routes = routes.reject { |r| r.chains.empty? }

          # build a map of which routes intersect with each route
          intersects = Hash.new { |h, k| h[k] = [] }
          actual_routes.each_with_index do |r, ir|
            actual_routes.each_with_index do |s, is|
              next if ir == is

              intersects[ir] << is if (r.visited_stops & s.visited_stops).any?
            end
            intersects[ir].uniq!
          end

          # starting with the first route, make sure every route can be visited
          visited = {}
          visit_route(0, intersects, visited)

          raise GameError, 'Routes must intersect with each other' if visited.size != actual_routes.size
        end
      end
    end
  end
end
