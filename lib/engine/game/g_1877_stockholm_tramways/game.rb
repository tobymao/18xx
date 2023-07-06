# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'round/train'
require_relative 'step/acquire_end'
require_relative 'step/acquire_start'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/buy_train'
require_relative 'step/dividend'
require_relative 'step/token'
require_relative 'step/track'
require_relative 'step/trainless_buy_train'

module Engine
  module Game
    module G1877StockholmTramways
      class Game < Game::Base
        include_meta(G1877StockholmTramways::Meta)
        include Entities
        include Map

        attr_accessor :sl

        register_colors(black: '#000000')

        CURRENCY_FORMAT_STR = '%skr'

        BANK_CASH = 99_999

        CERT_LIMIT = {
          3 => 16,
          4 => 12,
          5 => 10,
          6 => 9,
        }.freeze

        STARTING_CASH = {
          3 => 600,
          4 => 450,
          5 => 360,
          6 => 300,
        }.freeze

        MARKET = [
          %w[35 40 45
             50p 60p 70p 80p 90p 100p
             120 140 160 180 200
             240 280 320 360 400e],
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
            on: '3H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6H',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8H',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10H',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2H',
            distance: 2,
            price: 80,
            rusts_on: '4H',
            num: 6,
          },
          {
            name: '3H',
            distance: 3,
            price: 180,
            rusts_on: '8H',
            num: 5,
          },
          {
            name: '4H',
            distance: 4,
            price: 280,
            rusts_on: '10H',
            num: 4,
          },
          {
            name: '6H',
            distance: 6,
            price: 500,
            num: 2,
          },
          {
            name: '8H',
            distance: 8,
            price: 600,
            num: 2,
          },
          {
            name: '10H',
            distance: 10,
            price: 700,
            num: 32,
            events: [{ 'type' => 'sl_trigger' }],
          },
        ].freeze

        CAPITALIZATION = :full
        HOME_TOKEN_TIMING = :float
        SELL_AFTER = :round
        SELL_BUY_ORDER = :sell_buy
        MUST_SELL_IN_BLOCKS = true
        MARKET_SHARE_LIMIT = 100
        MUST_BID_INCREMENT_MULTIPLE = true
        MUST_BUY_TRAIN = :always
        TRAIN_PRICE_MULTIPLE = 5

        GAME_END_CHECK = { stock_market: :current_round, custom: :full_or }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'SL forms'
        )

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
           'sl_trigger' => ['SL Trigger', 'SL will form at end of OR, game ends at end of following OR set'],
         ).freeze

        def setup
          @sl = nil
          @sl_triggered = nil

          @offer_order = @corporations.sort_by { rand }
          @corporations.each do |corporation|
            shares = ShareBundle.new(corporation.shares)
            share_pool.transfer_shares(shares, share_pool, price: 0, allow_president_change: true)
          end

          @starting_phase = {}
          @offer_order.take(5).each do |corporation|
            @starting_phase[corporation] = '2'
            corporation.reservation_color = '#ffff75'
          end
          @offer_order.slice(5, 4).each do |corporation|
            @starting_phase[corporation] = '3'
            corporation.reservation_color = '#a2f075'
          end
          @offer_order.slice(9, 3).each do |corporation|
            @starting_phase[corporation] = '6'
            corporation.reservation_color = '#fba775'
          end
        end

        def status_array(corporation)
          start_phase = @starting_phase[corporation]
          [["Phase available: #{start_phase}"]] unless @phase.available?(start_phase)
        end

        def sorted_corporations
          ipoed, others = corporations.partition(&:ipoed)
          ipoed.sort + others.sort.sort_by { |c| @offer_order.find_index(c) }
        end

        def bank_sort(corporations)
          corporations.sort.sort_by { |c| @offer_order.find_index(c) }
        end

        def corporation_available?(entity)
          entity.corporation? && ready_corporations.include?(entity)
        end

        def init_round
          stock_round
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when G1877StockholmTramways::Round::Train
              @turn += 1
              remove_trainless
              new_stock_round
            when Engine::Round::Operating
              if @sl_triggered
                form_sl
                or_round_finished
                or_set_finished
                new_train_round
              elsif @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            end
        end

        def form_sl
          @log << '-- SL Formed --'

          @sl_triggered = false
          @sl = true

          @corporations.reject(&:ipoed).dup.each { |c| remove_corporation!(c) }
        end

        def remove_trainless
          @log << '-- Trainless Corporations are Removed from the Game --'

          @corporations.select { |c| c.trains.empty? }.dup.each { |c| remove_corporation!(c) }

          @sl = true
        end

        def stock_round
          Engine::Round::Stock.new(self, [G1877StockholmTramways::Step::BuySellParShares])
        end

        def can_par?(_corp, _entity)
          true
        end

        def ipoable_corporations
          ready_corporations.reject(&:ipoed)
        end

        def ready_corporations
          @offer_order.select { |corporation| available_to_start?(corporation) || corporation.ipoed }
        end

        def available_to_start?(corporation)
          @phase.available?(@starting_phase[corporation]) && !@sl
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          corporation = bundle.corporation
          old_price = corporation.share_price

          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          (bundle.num_shares + 1).div(2).times { @stock_market.move_left(corporation) } unless @sl
          log_share_price(corporation, old_price)
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1877StockholmTramways::Step::AcquireStart,
            G1877StockholmTramways::Step::Track,
            G1877StockholmTramways::Step::Token,
            Engine::Step::Route,
            G1877StockholmTramways::Step::Dividend,
            G1877StockholmTramways::Step::BuyTrain,
            G1877StockholmTramways::Step::AcquireEnd,
          ], round_num: round_num)
        end

        def new_train_round
          @log << '-- Trainless Corporations may Buy Trains --'
          G1877StockholmTramways::Round::Train.new(self, [
            G1877StockholmTramways::Step::TrainlessBuyTrain,
          ])
        end

        def event_sl_trigger!
          @sl_triggered = true
          @log << '-- Event: SL will form at end of current OR --'
        end

        def custom_end_game_reached?
          @sl
        end

        def game_route_revenue(stop, phase, train)
          return 0 unless stop

          stop.route_revenue(phase, train)
        end

        def check_overlap(routes) end

        def check_overlap_single(route)
          tracks = []

          route.paths.each do |path|
            a = path.a
            b = path.b

            tracks << [path.hex, a.num, path.lanes[0][1]] if a.edge?
            tracks << [path.hex, b.num, path.lanes[1][1]] if b.edge?

            # check track between edges and towns not in center
            # (essentially, that town needs to act like an edge for this purpose)
            if b.edge? && a.town? && (nedge = a.tile.preferred_city_town_edges[a]) && nedge != b.num
              tracks << [path.hex, a, path.lanes[0][1]]
            end
            if a.edge? && b.town? && (nedge = b.tile.preferred_city_town_edges[b]) && nedge != a.num
              tracks << [path.hex, b, path.lanes[1][1]]
            end
          end

          tracks.group_by(&:itself).each do |k, v|
            raise GameError, "Route cannot reuse track on #{k[0].id}" if v.size > 1
          end
        end

        def hex_edge_cost(conn)
          conn[:paths].each_cons(2).sum do |a, b|
            a.hex == b.hex ? 0 : 1
          end
        end

        def route_distance(route)
          route.chains.sum { |conn| hex_edge_cost(conn) }
        end

        def route_distance_str(route)
          "#{route_distance(route)}H"
        end

        def check_distance(route, _visits)
          limit = route.train.distance
          distance = route_distance(route)
          raise GameError, "#{distance} is too many hex edges for #{route.train.name} train" if distance > limit
        end

        def check_other(route)
          check_overlap_single(route)
        end

        def stop_on_other_route?(this_route, stop)
          this_route.routes.each do |r|
            return false if r == this_route

            other_stops = r.stops
            return true if other_stops.include?(stop)
            return true unless (other_stops.flat_map(&:groups) & stop.groups).empty?
          end
          false
        end

        def revenue_for(route, stops)
          stops.sum do |stop|
            stop_on_other_route?(route, stop) ? 0 : game_route_revenue(stop, route.phase, route.train)
          end
        end

        def compute_other_paths(_, _)
          []
        end

        def merge(corp, other)
          old_price = corp.share_price
          new_price = compute_merger_share_price(corp, other)
          @log << "New share price: #{format_currency(new_price.price)}"

          old_price.corporations.delete(corp)
          new_price.corporations << corp
          corp.share_price = new_price

          holders = share_holder_list(corp, other)

          holders.each do |player, _|
            player.shares_of(corp).dup.each { |share| transfer_share(share, @share_pool) }
            player.shares_of(other).dup.each { |share| transfer_share(share, @share_pool) }
          end

          holders.each do |player, share_percent|
            transfer_share(corp.presidents_share, player) if player == corp.owner && share_percent >= 20

            while player.shares_of(corp).sum(&:percent) <= share_percent - 10
              transfer_share(@share_pool.shares_of(corp).first, player)
            end
          end

          may_buy_half_price = true

          holders.each do |player, share_percent|
            if share_percent % 10 != 0
              if player.cash >= new_price.price / 2 && !@share_pool.shares_of(corp).empty?
                player.spend(new_price.price / 2, @bank)
                transfer_share(@share_pool.shares_of(corp).first, player)
                @log << "#{player.name} buys an odd share for #{format_currency(new_price.price / 2)}"
              else
                @bank.spend(new_price.price / 2, player)
                @log << "#{player.name} sells an odd share for #{format_currency(new_price.price / 2)}"
                may_buy_half_price = false if player == corp.owner
              end
            end
          end

          other.spend(other.cash, corp) if other.cash.positive?
          other.trains.each do |train|
            train.owner = corp
            train.operated = false
          end
          corp.trains.concat(other.trains)
          @log << "Transferred trains and treasury from #{other.name} to #{corp.name}"

          replace_tokens(corp, other)

          remove_corporation!(other)

          return may_buy_half_price unless corp.owner.shares_of(corp).sum(&:percent) < 20

          @log << "No player owns the president's certificate of #{corp.name}"
          remove_corporation!(corp)
          false
        end

        def share_holder_list(corp, other)
          plist = @players.rotate(@players.index(corp.owner)).map do |player|
            [player, (player.shares_of(corp).sum(&:percent) + player.shares_of(other).sum(&:percent)) / 2]
          end
          plist.select { |_, share_percent| share_percent.positive? }
        end

        def find_valid_share_price(price)
          @stock_market.market.first.max_by { |p| p.price <= price ? p.price : 0 }
        end

        def compute_merger_share_price(corp_a, corp_b)
          prices = [corp_a.share_price.price, corp_b.share_price.price].sort
          find_valid_share_price(prices.first + (prices.last / 2))
        end

        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        def replace_tokens(corp, other)
          @hexes.each do |hex|
            hex.tile.cities.each do |city|
              next unless city.tokened_by?(other)

              token = city.tokens.find { |t| t&.corporation == other }
              if hex.tile.cities.any? { |c| c.tokened_by?(corp) }
                token.destroy!
                @log << "Removed co-located #{other.name} token in #{hex.id} (#{hex.location_name})"
              else
                swap_token(corp, other, token)
              end
            end
          end
        end

        def swap_token(corp, other, old_token)
          new_token = corp.next_token
          city = old_token.city
          new_token.place(city)
          city.tokens[city.tokens.find_index(old_token)] = new_token
          other.tokens.delete(old_token)
          @log << "Replaced #{other.name} token in #{city.hex.id} with #{corp.name} token"
        end

        def remove_corporation!(corporation)
          @log << "#{corporation.name} is removed from the game" if corporation.ipoed

          corporation.share_holders.keys.each do |share_holder|
            share_holder.shares_by_corporation.delete(corporation)
          end

          @hexes.each do |hex|
            hex.tile.cities.each do |city|
              city.tokens.select { |t| t&.corporation == corporation }.each(&:remove!)

              city.reservations.delete(corporation) if corporation.ipoed && city.reserved_by?(corporation)
            end
          end

          @corporations.delete(corporation)
          @starting_phase.delete(corporation)
          corporation.close!
        end
      end
    end
  end
end
