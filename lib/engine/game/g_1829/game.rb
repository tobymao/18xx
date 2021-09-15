# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../../option_error'
require_relative '../../distance_graph'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1829
      class Game < Game::Base
        include_meta(G1829::Meta)
        include G1829::Entities
        include G1829::Map

        attr_reader :units, :node_distance_graph, :city_distance_graph

        register_colors(black: '#37383a',
                        seRed: '#f72d2d',
                        bePurple: '#2d0047',
                        peBlack: '#000',
                        beBlue: '#c3deeb',
                        heGreen: '#78c292',
                        oegray: '#6e6966',
                        weYellow: '#ebff45',
                        beBrown: '#54230e',
                        gray: '#6e6966',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '£%d'
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :none
        SELL_BUY_ORDER = :sell_buy_sell
        SOLD_OUT_INCREASE = false
        PRESIDENT_SALES_TO_MARKET = true
        MARKET_SHARE_LIMIT = 100
        HOME_TOKEN_TIMING = :operating_round
        BANK_CASH = 50_000
        COMPANY_SALE_FEE = 30
        TRACK_RESTRICTION = :station_restrictive
        TILE_LAYS = [{ lay: true, upgrade: true }].freeze
        GAME_END_CHECK = { bank: :current_or, stock_market: :immediate }.freeze
        TRAIN_PRICE_MIN = 10
        STARTING_CASH = { 2 => 1260, 3 => 840, 4 => 630, 5 => 504, 6 => 420, 7 => 360, 8 => 315, 9 => 280 }.freeze

        CERT_LIMIT = { 2 => 18, 3 => 18, 4 => 18, 5 => 17, 6 => 14, 7 => 12, 8 => 10, 9 => 9 }.freeze

        MARKET = [
          %w[0c
             10y
             20y
             29y
             38
             47
             53
             56p
             58p
             61p
             64p
             67p
             71p
             76p
             82p
             90p
             100p
             112
             126
             142
             160
             180
             200
             225
             250
             275
             300
             320
             335
             345
             350],
        ].freeze

        COMMON_PHASES = [
          {
            name: '1',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        PHASES_NO_K3 = [
         {
           name: '4b',
           on: '7',
           train_limit: 2,
           tiles: %i[yellow green brown gray browngray],
           operating_rounds: 4,
         },
       ].freeze

        PHASES_K3 = [
          {
            name: '4a',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray browngray],
            operating_rounds: 4,
          },
          {
            name: '4b',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray browngray],
            operating_rounds: 4,
          },
        ].freeze

        def game_phases
          gphases = COMMON_PHASES.dup
          gphases.concat(PHASES_NO_K3) unless @kits[3]
          gphases.concat(PHASES_K3) if @kits[3]
          gphases
        end

        ALL_TRAINS_NO_K3 = {
          '2' => { distance: 2, price: 180, rusts_on: '5' },
          '3' => { distance: 3, price: 300, rusts_on: '7' },
          '4' => { distance: 4, price: 430 },
          '5' => { distance: 5, price: 550 },
          '7' => { distance: 7, price: 720 },
        }.freeze

        ALL_TRAINS_K3 = {
          '2' => { distance: 2, price: 180, rusts_on: '5' },
          '3' => { distance: 3, price: 300, rusts_on: '6' },
          '4' => { distance: 4, price: 430 },
          '5' => { distance: 5, price: 550 },
          '3T' => { distance: 3, price: 370, available_on: '5' },
          '6' => { distance: 7, price: 650 },
          '2+2' => { distance: 2, price: 600, available_on: '6' },
          '7' => { distance: 7, price: 720 },
          '4+4E' => {
            distance: [{ 'nodes' => ['city'], 'pay' => 4, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 830,
            available_on: '7',
          },
        }.freeze

        def build_train_list(thash)
          thash.keys.map do |t|
            new_hash = {}
            new_hash[:name] = t
            new_hash[:num] = thash[t]
            new_hash.merge!(ALL_TRAINS_NO_K3[t]) unless @kits[3]
            new_hash.merge!(ALL_TRAINS_K3[t]) if @kits[3]
            new_hash
          end
        end

        def add_train_list(tlist, thash)
          thash.keys.each do |t|
            if (item = tlist.find { |h| h[:name] == t })
              item[:num] += thash[t]
            else
              new_hash = {}
              new_hash[:name] = t
              new_hash[:num] = thash[t]
              new_hash.merge!(ALL_TRAINS_NO_K3[t]) unless @kits[3]
              new_hash.merge!(ALL_TRAINS_K3[t]) if @kits[3]

              tlist << new_hash
            end
          end
        end

        # throw out available_on specifiers if that train isn't in the list for this game
        # this should only apply to minor trains
        def fix_train_availables(tlist)
          all_trains = tlist.map { |h| h[:name] }
          tlist.each do |h|
            h.delete(:available_on) if h[:available_on] && !all_trains.include?(h[:available_on])
          end
        end

        def game_trains
          if @kits[3]
            trains = build_train_list(
                           { '2' => 7, '3' => 5, '4' => 4, '5' => 4, '3T' => 3, '6' => 2, '2+2' => 2, '7' => 4, '4+4E' => 2 }
                         )
          else
            trains = build_train_list({ '2' => 7, '3' => 6, '4' => 5, '5' => 5, '7' => 4 })
          end
          add_train_list(trains, { '3' => -4, '4' => -3, '5' => -3 }) if @players.size == 2
          add_train_list(trains, { '4' => -2, '5' => -2 }) if @players.size == 3
          add_train_list(trains, { '4' => -1, '5' => -1 }) if @players.size == 4

          fix_train_availables(trains)

          trains
        end

        def init_optional_rules(optional_rules)
          optional_rules = (optional_rules || []).map(&:to_sym)

          # sanity check player count and illegal combination of options
          @units = {}
          @kits = {}

          @units[1] = true

          @kits[1] = true if optional_rules.include?(:k1)
          @kits[2] = false
          @kits[3] = true if optional_rules.include?(:k3)
          @kits[4] = false
          @kits[5] = true if optional_rules.include?(:k5)
          @kits[6] = true if optional_rules.include?(:k6)

          p_range = case @units.keys.sort.map(&:to_s).join
                    when '1'
                      [2, 9]
                    end
          if p_range.first > @players.size || p_range.last < @players.size
            raise OptionError, 'Invalid option(s) for number of players'
          end

          optional_rules
        end

        def calculate_bank_cash
          20_000
        end

        def bank_by_options
          @bank_by_options ||= calculate_bank_cash
        end

        def cash_by_options
          { 2 => 1260, 3 => 840, 4 => 630, 5 => 504, 6 => 420, 7 => 360, 8 => 315, 9 => 280 }
        end

        def certs_by_options
          { 2 => 18, 3 => 18, 4 => 18, 5 => 17, 6 => 14, 7 => 12, 8 => 10, 9 => 9 }
        end

        def init_bank
          # amount doesn't matter here
          Bank.new(BANK_CASH, log: @log, check: false)
        end

        def bank_cash
          bank_by_options - @players.sum(&:cash)
        end

        def check_bank_broken!
          @bank.break! if bank_cash.negative?
        end

        def init_starting_cash(players, bank)
          cash = cash_by_options[players.size]
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def init_cert_limit
          certs_by_options[players.size]
        end

        def init_share_pool
          SharePool.new(self, allow_president_sale: true)
        end

        def setup
          @log << "Bank starts with #{format_currency(bank_by_options)}"

          @node_distance_graph = DistanceGraph.new(self, separate_node_types: false)
          @city_distance_graph = DistanceGraph.new(self, separate_node_types: true)
          @formed = []
          @layer_by_corp = {}

          pars = @corporations.map { |c| PAR_BY_CORPORATION[c.name] }.compact.uniq.sort.reverse
          @corporations.each do |corp|
            next unless PAR_BY_CORPORATION[corp.name]

            @layer_by_corp[corp] = pars.index(PAR_BY_CORPORATION[corp.name]) + 1
          end

          @max_layers = @layer_by_corp.values.max

          @highest_layer = 1
        end

        # cache all stock prices
        def share_prices
          stock_market.market.first
        end

        def active_players
          players_ = @round.active_entities.map(&:player).compact

          players_.empty? ? acting_when_empty : players_
        end

        def acting_when_empty
          if (active_entity = @round && @round.active_entities[0])
            [acting_for_entity(active_entity)]
          else
            @players
          end
        end

        # for receivership:
        # find first player from PD not a director
        # o.w. PD
        def acting_for_entity(entity)
          return entity if entity.player?
          return entity.owner if entity.owner.player?

          acting = @players.find { |p| !director?(p) }
          acting || @players.first
        end

        def director?(player)
          @corporations.any? { |c| c.owner == player }
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          # handle special-case upgrades
          return true if force_dit_upgrade?(from, to)

          # deal with striped tiles
          # 166 upgrades from green, but doesn't upgrade to gray
          return false if (from.name == '166') && (to.color == :gray)

          super
        end

        def force_dit_upgrade?(from, to)
          return false unless (list = DIT_UPGRADES[from.name])

          list.include?(to.name)
        end

        def can_ipo?(corp)
          @layer_by_corp[corp] <= current_layer
        end

        def major?(corp)
          corp&.corporation? && corp.presidents_share.percent == 20
        end

        def minor?(corp)
          corp&.corporation? && corp.presidents_share.percent != 20
        end

        def minor_required_train(corp)
          return unless minor?(corp)

          rtrain = REQUIRED_TRAIN[corp.name]
          @depot.trains.find { |t| t.name == rtrain }
        end

        # minor share price is for a 10% share
        def minor_par_prices(corp)
          price = minor_required_train(corp).price
          stock_market.market.first.select { |p| (p.price * 10) > price }.reject { |p| p.type == :endgame }
        end

        def par_prices(corp)
          if major?(corp)
            price = PAR_BY_CORPORATION[corp.name]
            stock_market.par_prices.select { |p| p.price == price }
          else
            minor_par_prices(corp)
          end
        end

        def check_new_layer
          layer = current_layer
          @log << "-- Band #{layer} corporations now available --" if layer > @highest_layer
          @highest_layer = layer
        end

        def current_layer
          # undistributed privates must be sold before any corps
          return 0 if @companies.any? { |c| !c.owner && c.abilities.empty? && c.revenue <= 20 }

          layers = @layer_by_corp.select do |corp, _layer|
            corp.num_ipo_shares.zero?
          end.values
          layers.empty? ? 1 : [layers.max + 1, @max_layers].min
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1829::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          G1829::Round::Operating.new(self, [
            Engine::Step::HomeToken,
            G1829::Step::TrackAndToken,
            G1829::Step::Route,
            G1829::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1829::Step::BuyTrain,
          ], round_num: round_num)
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used
          return super unless corporation.coordinates.is_a?(Array)

          corporation.coordinates.each do |coord|
            hex = hex_by_id(coord)
            tile = hex&.tile
            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
            token = corporation.find_token_by_type

            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token)
          end
          @graph.clear
        end

        # Formation isn't flotation for minors
        def formed?(corp)
          @formed.include?(corp)
        end

        # For minors: not flotation, but when minor can purchase its required train
        def check_formation(corp)
          return if formed?(corp)

          return unless major?(corp) && corp.floated?

          @formed << corp
          @log << "#{corp.name} forms"
        end

        # -1 if a has a higher par price than b
        # 1 if a has a lower par price than b
        # if they are the same, then use the order of formation (generally flotation)
        def par_compare(a, b)
          if a.par_price.price > b.par_price.price
            -1
          elsif a.par_price.price < b.par_price.price
            1
          else
            @formed.find_index(a) < @formed.find_index(b) ? -1 : 1
          end
        end

        def operating_order
          @corporations.select { |c| formed?(c) }.sort { |a, b| par_compare(a, b) }.partition { |c| major?(c) }.flatten
        end

        def unbought_companies
          @companies.select { |c| !c.closed? && !c.owner && c.revenue <= 20 }
        end

        def buyable_bank_owned_companies
          if (unbought = unbought_companies).empty?
            @companies.select { |c| !c.closed? && (!c.owner || c.owner == @bank) }
          else
            [unbought.min_by(&:value)]
          end
        end

        def sorted_corporations
          @corporations.sort_by { |c| @layer_by_corp[c] }
        end

        def corporation_available?(entity)
          entity.corporation? && can_ipo?(entity)
        end

        def silent_receivership?(entity)
          entity.corporation? && entity.receivership? && minor?(entity)
        end

        def can_run_route?(entity)
          super && !silent_receivership?(entity)
        end

        def status_array(corp)
          if major?(corp)
            layer_str = "Band #{@layer_by_corp[corp]}"
            layer_str += ' (N/A)' unless can_ipo?(corp)

            prices = par_prices(corp).map(&:price).sort
            par_str = ("Par #{prices[0]}" unless corp.ipoed)
          end

          status = []
          status << [layer_str]
          status << [par_str] if par_str
          status << %w[Receivership bold] if corp.receivership?

          status
        end

        def node_distance(train)
          return 0 if train.name == 'U3'

          train.distance.is_a?(Numeric) ? train.distance : 99
        end

        def biggest_train_distance(entity)
          biggest_node_distance(entity)
        end

        def biggest_node_distance(entity)
          return 0 if entity.trains.empty?

          biggest = entity.trains.map { |t| node_distance(t) }.max
          return 3 if biggest == 2 & entity.trains.count { |t| t.distance == 2 } > 1

          biggest
        end

        def city_distance(train)
          return 0 unless train.name == 'U3'

          3
        end

        def biggest_city_distance(entity)
          return 0 if entity.trains.empty?

          entity.trains.map { |t| city_distance(t) }.max
        end

        def route_trains(entity)
          (super + [@round.leased_train]).compact
        end

        def double_header_pair?(a, b)
          corporation = train_owner(a.train)
          return false if (common = (a.visited_stops & b.visited_stops)).empty?

          common = common.first
          return false if common.city? && common.blocks?(corporation)

          a_other = a.visited_stops.reject(common).first
          b_other = b.visited_stops.reject(common).first
          return false if a_other.town? || b_other.town? # still can't end in a town

          a_tokened = a.visited_stops.any? { |n| city_tokened_by?(n, corporation) }
          b_tokened = b.visited_stops.any? { |n| city_tokened_by?(n, corporation) }
          return false if !a_tokened && !b_tokened
          return true if common.town?

          !(a_tokened && b_tokened)
        end

        # look for pairs of 2-trains that:
        # - have exactly two visited nodes each
        # - share exactly one non-tokened out endpoint
        # - and one or both of the following is true
        #   1. one has a token and the other does not
        #   2. the shared endpoint is a town
        #
        # if multiple possibilities exist, pick first pair found
        def find_double_headers(routes)
          dhs = []
          routes.each do |route_a|
            next if route_a.train.distance != 2
            next if route_a.visited_stops.size != 2
            next if dhs.flatten.include?(route_a)

            partner = routes.find do |route_b|
              next false if route_b.train.distance != 2
              next false if route_b.visited_stops.size != 2
              next false if route_b == route_a
              next false if dhs.flatten.include?(route_b)

              double_header_pair?(route_a, route_b)
            end
            next unless partner

            dhs << [route_a, partner]
          end
          dhs
        end

        def double_header?(route)
          find_double_headers(route.routes).flatten.include?(route)
        end

        def find_double_header_buddies(route)
          double_headers = find_double_headers(route.routes)
          double_headers.each do |buddies|
            return buddies if buddies.include?(route)
          end
          []
        end

        def check_distance(route, visits)
          super
          return if %w[3T 4T].include?(route.train.name)

          raise GameError, 'Route cannot begin/end in a town' if visits.first.town? && visits.last.town?

          end_town = visits.first.town? || visits.last.town?
          end_town = false if end_town && route.train.distance == 2 && double_header?(route)
          raise GameError, 'Route cannot begin/end in a town' if end_town

          node_hexes = {}
          visits.each do |node|
            raise GameError, 'Cannot visit multiple towns/cities in same hex' if node_hexes[node.hex]

            node_hexes[node.hex] = true
          end
        end

        def check_route_token(route, token)
          raise GameError, 'Route must contain token' if !token && !double_header?(route)
        end

        def check_connected(route, token)
          # no need if distance is 2, avoids dealing with double-header route missing a token
          return if route.train.distance == 2

          paths_ = route.paths.uniq

          return if token.select(paths_, corporation: route.corporation).size == paths_.size

          raise GameError, 'Route is not connected'
        end

        # only T trains get halt revenue
        def stop_revenue(stop, phase, train)
          return 0 if stop.tile.label.to_s == 'HALT' && train.name != '3T' && train.name != '4T'

          stop.route_revenue(phase, train)
        end

        def revenue_for(route, stops)
          buddies = find_double_header_buddies(route)
          if buddies.empty?
            stops.sum { |stop| stop_revenue(stop, route.phase, route.train) }
          else
            stops.sum do |stop|
              if buddies[-1] == route && buddies[0].stops.include?(stop)
                0
              else
                stop_revenue(stop, route.phase, route.train)
              end
            end
          end
        end

        def revenue_str(route)
          postfix = if double_header?(route)
                      ' [3 train]'
                    else
                      ''
                    end
          "#{route.hexes.map(&:name).join('-')}#{postfix}"
        end

        def must_buy_train?(_entity)
          false
        end
      end
    end
  end
end
