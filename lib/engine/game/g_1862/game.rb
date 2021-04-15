# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'step/charter_auction'
require_relative 'step/buy_tokens'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/home_upgrade'
require_relative 'step/track'
require_relative 'step/token'

module Engine
  module Game
    module G1862
      class Game < Game::Base
        include_meta(G1862::Meta)
        include Entities
        include Map

        attr_accessor :chartered, :base_tiles

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
             400j
             430j
             495j
             530j
             570j
             610j
             655j
             700j
             750j
             800j
             850j
             900j
             950j
             1000e],
           ].freeze

        PHASES = [
          {
            name: 'A',
            train_limit: 9, # 3 per type
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: 'B',
            on: '2F',
            train_limit: 9, # 3 per type
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: 'C',
            on: '3F',
            train_limit: 9, # 3 per type
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: 'D',
            on: '5F',
            train_limit: 9, # 3 per type
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'E',
            on: '6F',
            train_limit: 6, # 2 per type
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'F',
            on: '7F',
            train_limit: 6, # 2 per type
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'G',
            on: '8F',
            train_limit: 3, # FIXME: 3 across all types
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'H',
            on: '9F',
            train_limit: 3, # FIXME: 3 across all types
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '1F',
            distance: 1,
            price: 100,
            rusts_on: '3F',
            num: 7,
            variants: [
              {
                name: '2L',
                distance: [{ 'nodes' => %w[city], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 100,
              },
              {
                name: '2E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 100,
              },
            ],
          },
          {
            name: '2F',
            distance: 2,
            price: 200,
            rusts_on: '6F',
            num: 6,
            variants: [
              {
                name: '2/3L',
                distance: [{ 'nodes' => %w[city], 'pay' => 2, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 200,
              },
              {
                name: '2/3E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 200,
              },
            ],
          },
          {
            name: '3F',
            distance: 3,
            price: 280,
            rusts_on: '7F',
            num: 4,
            variants: [
              {
                name: '3L',
                distance: [{ 'nodes' => %w[city], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 280,
              },
              {
                name: '3E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 280,
              },
            ],
          },
          {
            name: '5F',
            distance: 5,
            price: 360,
            rusts_on: '8F',
            num: 3,
            variants: [
              {
                name: '4L',
                distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 360,
              },
              {
                name: '4E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 360,
              },
            ],
          },
          {
            name: '6F',
            distance: 6,
            price: 500,
            num: 3,
            variants: [
              {
                name: '4/5L',
                distance: [{ 'nodes' => %w[city], 'pay' => 4, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 500,
              },
              {
                name: '4/5E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 500,
              },
            ],
          },
          {
            name: '7F',
            distance: 7,
            price: 600,
            num: 2,
            variants: [
              {
                name: '5L',
                distance: [{ 'nodes' => %w[city], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 600,
              },
              {
                name: '5E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 600,
              },
            ],
          },
          {
            name: '8F',
            distance: 8,
            price: 700,
            num: 1,
            variants: [
              {
                name: '5/6L',
                distance: [{ 'nodes' => %w[city], 'pay' => 5, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 700,
              },
              {
                name: '5/6E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 700,
              },
            ],
          },
          {
            name: '9F',
            distance: 9,
            price: 800,
            num: 99,
            variants: [
              {
                name: '6L',
                distance: [{ 'nodes' => %w[city], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                price: 800,
              },
              {
                name: '6E',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 800,
              },
            ],
          },
        ].freeze

        EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
        EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
        HOME_TOKEN_TIMING = :operate
        SELL_AFTER = :any_time
        SELL_BUY_ORDER = :sell_buy
        MARKET_SHARE_LIMIT = 100
        TRAIN_PRICE_MIN = 10
        TRAIN_PRICE_MULTIPLE = 10

        TRACK_RESTRICTION = :permissive

        SOLD_OUT_INCREASE = false

        STOCKMARKET_COLORS = {
          par: :yellow,
          endgame: :orange,
          close: :gray,
          repar: :peach,
          ignore_one_sale: :olive,
          ignore_two_sales: :green,
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
          ignore_two_sales: 'Ignore first 2 shares sold when moving price (except president)',
        }.freeze

        # NOTE: that the definition of an "upgrade" is extended to include "N" tiles
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        GAME_END_CHECK = { stock_market: :current_or, bank: :current_or, custom: :immediate }.freeze

        CHARTERED_TOKEN_COST = 60
        UNCHARTERED_TOKEN_COST = 40

        LONDON_HEXES = %w[
            B15
            D15
        ].freeze

        def init_share_pool
          SharePool.new(self, allow_president_sale: true)
        end

        def init_companies(players)
          clist = super

          # create charter companies on the fly based on corporations
          game_corporations.map do |corp|
            description = "Parliamentary Obligation for #{corp[:name]}"
            name = "#{corp[:sym]} Obligation"

            clist << Company.new(sym: corp[:sym], name: name, value: 0, revenue: 0, desc: description)
          end

          clist
        end

        def setup; end

        def setup_preround
          @base_tiles = []

          # remove reservations (nice to have in starting map)
          @corporations.each { |corp| remove_reservation(corp) }

          @double_parliament = true

          # randomize order of corporations, then remove some based on player count
          @offer_order = @corporations.sort_by { rand }
          num_removed = case @players.size
                        when 8
                          2
                        when 7
                          3
                        else
                          4
                        end
          removed = @offer_order.take(num_removed)
          removed.each do |corp|
            @offer_order.delete(corp)
            @corporations.delete(corp)
            @companies.delete(@companies.find { |c| c.id == corp.id })

            @log << "Removing #{corp.name} from game"
          end

          # add markers for remaining companies
          @corporations.each { |corp| add_marker(corp) }

          @chartered = {}

          # randomize and distribute train permits
          permit_list = 6.times.flat_map { %i[freight express local] }
          permit_list.pop(2) if @players.size < 7
          permit_list.sort_by! { rand }
          @permits = Hash.new { |h, k| h[k] = [] }
          @corporations.each_with_index { |corp, idx| @permits[corp] << permit_list[idx] }

          # record what phases corp become available
          @starting_phase = {}
          @offer_order.each { |c| @starting_phase[c] = 'A' }
          @offer_order.reverse.take(8).each { |c| @starting_phase[c] = 'B' }
          @offer_order.reverse.take(4).each { |c| @starting_phase[c] = 'C' }
        end

        def remove_reservation(corporation)
          hex = @hexes.find { |h| h.id == corporation.coordinates } # hex_by_id doesn't work here
          hex.tile.cities.each do |city|
            city.reservations.delete(corporation) if city.reserved_by?(corporation)
          end
        end

        def add_marker(corporation)
          hex = @hexes.find { |h| h.id == corporation.coordinates } # hex_by_id doesn't work here
          image = "1862/#{corporation.id}".upcase.delete('&')
          marker = Part::Icon.new(image, nil, true, nil, hex.tile.preprinted, large: true, owner: nil)
          hex.tile.icons << marker
        end

        def remove_marker(corporation)
          hex = hex_by_id(corporation.coordinates)
          marker = hex.tile.icons.find(&:large)
          hex.tile.icons.delete(marker)
        end

        def share_prices
          repar_prices
        end

        def repar_prices
          @repar_prices ||= stock_market.market.first.select { |p| p.type == :repar || p.type == :par }
        end

        def ipoable_corporations
          ready_corporations.reject(&:ipoed)
        end

        def ready_corporations
          @offer_order.select { |corp| available_to_start?(corp) }
        end

        # FIXME
        def available_to_start?(corporation)
          @phase.available?(@starting_phase[corporation]) && legal_to_start?(corporation)
        end

        def add_obligation(entity, corporation)
          charter = company_by_id(corporation.id)
          charter.owner = entity
          entity.companies << charter
          @log << "#{entity.name} is under obligation for #{corporation.name}"
          @chartered[corporation] = true
        end

        def float_corporation(corporation)
          super
          charter = company_by_id(corporation.id)

          unless (entity = charter.owner)
            # unchartered company
            raise GameError, 'Player missing charter' if @chartered[corporation]

            @round.buy_tokens = corporation
            @log << "#{corporation.name} (#{corporation.owner.name}) must buy tokens"
            @round.clear_cache!
            return
          end

          raise GameError, 'Player has charter in error' unless @chartered[corporation]

          # chartered company
          entity.companies.delete(charter)
          charter.owner = nil
          @log << "#{entity.name} has completed obligation for #{corporation.name}"
          entity.companies.delete(charter)

          # assumption: corp defaults to three tokens
          raise GameError, 'Wrong number of tokens for Chartered Company' if corporation.tokens.size != 3

          @log << "#{corporation.name} buys 3 tokens for #{format_currency(CHARTERED_TOKEN_COST * 3)}"
          corporation.spend(CHARTERED_TOKEN_COST * 3, @bank)
        end

        def convert_to_full!(corporation)
          corporation.capitalization = :full
          corporation.ipo_owner = @bank
          corporation.share_holders.keys.each do |sh|
            next if sh == @bank

            corporation.share_holders[sh] = 0
            sh.shares_by_corporation[corporation].dup.each do |share|
              share.owner = @bank
              sh.shares_by_corporation[corporation].delete(share)
              @bank.shares_by_corporation[corporation] << share
              corporation.share_holders[@bank] += share.percent
            end
          end
        end

        def convert_to_incremental!(corporation)
          corporation.capitalization = :incremental
          corporation.ipo_owner = corporation
          corporation.share_holders.keys.each do |sh|
            next if sh == corporation

            corporation.share_holders[sh] = 0
            sh.shares_by_corporation[corporation].dup.each do |share|
              share.owner = corporation
              sh.shares_by_corporation[corporation].delete(share)
              corporation.shares_by_corporation[corporation] << share
              corporation.share_holders[corporation] += share.percent
            end
          end
        end

        def london_link?(entity)
          LONDON_HEXES.any? { |hexid| hex_by_id(hexid).tile.cities.any? { |c| c.tokened_by?(entity) } }
        end

        def purchase_tokens!(corporation, count)
          (count - 2).times { corporation.tokens << Token.new(corporation, price: 0) }
          corporation.spend((cost = UNCHARTERED_TOKEN_COST * count), @bank)
          @log << "#{corporation.name} buys #{count} tokens for #{format_currency(cost)}"
        end

        def place_home_token(corporation)
          # If a corp has laid it's first token assume it's their home token
          return if corporation.tokens.first&.used

          hex = hex_by_id(corporation.coordinates)

          tile = hex.tile
          city = tile.cities.first # no OO tiles in 1862
          if city.tokenable?(corporation, free: true)
            # still a slot, use it
            token = corporation.find_token_by_type
            city.place_token(corporation, token)
            remove_marker(corporation)
            graph.clear
            @log << "#{corporation.name} places home token on #{hex.name}"
          elsif upgrade_tokenable?(hex)
            # wait for upgrade
            @log << "#{corporation.name} must upgrade #{hex.name} in order to place home token"
            @round.upgrade_before_token << corporation
            @round.clear_cache!
          else
            # displace existing token
            old_token = city.tokens.last
            old_token.remove!
            new_token = corporation.find_token_by_type
            city.exchange_token(new_token)
            remove_marker(corporation)
            graph.clear
            @log << "#{corporation.name} replaces #{old_token.corporation.name} token on #{hex.name} "\
              'with home token'
          end
        end

        # determine if a legal upgrade for this hex has an additional
        # slot
        # FIXME: this should check to see if an upgrade tile is available and has a legal rotation
        def upgrade_tokenable?(hex)
          current_tile = hex.tile
          (current_tile.color == :yellow && @phase.tiles.include?(:green)) ||
            (current_tile.color == :green && current_tile.label.to_s == 'N' && @phase.tiles.include?(:brown))
        end

        # OK to start a corp if
        # - there still is a slot available, OR
        # - a legal upgrade has an additional slot
        def legal_to_start?(corporation)
          return true if corporation.tokens.first&.used

          hex = hex_by_id(corporation.coordinates)
          city = hex.tile.cities.first
          city.tokenable?(corporation, free: true) || upgrade_tokenable?(hex)
        end

        def base_tile_name(tile)
          return tile.name unless tile.name.include?('_')

          tile.name.slice(0..(tile.name.index('_') - 1))
        end

        def adding_town?(from, to)
          return false if from.towns.empty? || to.towns.empty?
          return false unless base_tile_name(from) == base_tile_name(to)

          to.towns.size == from.towns.size + 1
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if adding_town?(from, to)

          super
        end

        def upgrades_to_correct_label?(from, to)
          (from.label == to.label) ||
            (from.label.to_s == 'N' && to.label.to_s == 'I') ||
            (from.label.to_s == 'Y' && to.label.to_s == 'H')
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1862::Step::BuyTokens,
            G1862::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1862::Step::HomeUpgrade,
            # G1862::Step::Merge,
            G1862::Step::Track,
            G1862::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            # G1862::Step::Refinance,
            Engine::Step::BuyTrain,
            # G1862::Step::RedeemStock,
            # G1862::Step::Acquire,
          ], round_num: round_num)
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: true)
        end

        def init_round
          @log << '-- Initial Parliament Round -- '
          new_parliament_round
        end

        def new_parliament_round
          @log << "-- Parliament Round #{@turn} -- " unless @double_parliament
          G1862::Round::Parliament.new(self, [
            G1862::Step::CharterAuction,
          ])
        end

        def next_round!
          @round =
            case @round
            when G1862::Round::Parliament
              if @double_parliament
                @double_parliament = false
                new_parliament_round
              else
                new_stock_round
              end
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
                new_parliament_round
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

        def status_array(corp)
          start_phase = @starting_phase[corp]
          status = []
          status << %w[Receivership bold] if corp.receivership?
          status << %w[Chartered bold] if @chartered[corp]
          status << ["Phase available: #{start_phase}"] unless @phase.available?(start_phase)
          status << ['Cannot start'] if @phase.available?(start_phase) && !legal_to_start?(corp)
          status << ["Permits: #{@permits[corp].map(&:to_s).join(',')}"]
          status
        end

        def sorted_corporations
          ipoed, others = corporations.partition(&:ipoed)
          ipoed.sort + others.sort.sort_by { |c| @starting_phase[c] }
        end

        def ipo_name(entity = nil)
          if entity&.capitalization == :incremental
            'Treasury'
          else
            'IPO'
          end
        end

        # FIXME: need to check for no trains?
        def check_bankruptcy!(entity)
          return unless entity.corporation?

          make_bankrupt!(entity) if entity.share_price&.type == :close
        end

        def corporation_available?(entity)
          entity.corporation? && ready_corporations.include?(entity)
        end

        def bundles_for_corporation(share_holder, corporation, shares: nil)
          return [] unless corporation.ipoed

          shares = (shares || share_holder.shares_of(corporation)).sort_by(&:price)

          shares.flat_map.with_index do |share, index|
            bundle_shares = shares.take(index + 1)
            percent = bundle_shares.sum(&:percent)
            bundles = [Engine::ShareBundle.new(bundle_shares, percent)]
            if share.president
              normal_percent = corporation.share_percent
              difference = corporation.presidents_percent - normal_percent
              num_partial_bundles = difference / normal_percent
              (1..num_partial_bundles).each do |n|
                bundles.insert(0, Engine::ShareBundle.new(bundle_shares, percent - (normal_percent * n)))
              end
            end
            bundles.each { |b| b.share_price = (b.price_per_share / 2).to_i if corporation.trains.empty? }
            bundles
          end
        end

        def selling_movement?(corporation)
          corporation.floated? && !@phase.available?('H')
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          corporation = bundle.corporation
          price = corporation.share_price.price

          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          num_shares = bundle.num_shares
          unless corporation.owner == bundle.owner
            num_shares -= 1 if corporation.share_price.type == :ignore_one_sale
            num_shares -= 2 if corporation.share_price.type == :ignore_two_sales
          end
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
