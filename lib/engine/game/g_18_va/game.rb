# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18VA
      class Game < Game::Base
        include_meta(G18VA::Meta)
        include Entities
        include Map

        register_colors(black: '#37383a',
                        orange: '#f48221',
                        brightGreen: '#76a042',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 8000

        CERT_LIMIT = { 2 => 27, 3 => 18, 4 => 15, 5 => 10 }.freeze

        STARTING_CASH = { 2 => 600, 3 => 400, 4 => 300, 5 => 240 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = true

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
            train_limit: { five_share: 2, ten_share: 4 },
            tiles: [:yellow],
            corporation_sizes: [5],
            operating_rounds: 1,
            status: %w[offboard_token_bonus cmd_token_bonus limited_train_buy],
          },
          {
            name: '3',
            on: %w[3 2G],
            train_limit: { five_share: 2, ten_share: 4 },
            tiles: %i[yellow green],
            corporation_sizes: [5],
            operating_rounds: 2,
            status: %w[offboard_token_bonus cmd_token_bonus can_buy_companies may_convert limited_train_buy],
          },
          {
            name: '4',
            on: %w[4 3G],
            train_limit: { five_share: 1, ten_share: 3 },
            tiles: %i[yellow green],
            corporation_sizes: [5],
            operating_rounds: 2,
            status: %w[offboard_token_bonus cmd_token_bonus can_buy_companies may_convert limited_train_buy],
          },
          {
            name: '5',
            on: %w[5 4G],
            train_limit: { ten_share: 2 },
            tiles: %i[yellow green brown],
            corporation_sizes: [10],
            operating_rounds: 3,
            status: %w[offboard_token_bonus cmd_token_bonus can_buy_companies limited_train_buy],
          },
          {
            name: '6',
            on: %w[6 5G],
            train_limit: { ten_share: 2 },
            tiles: %i[yellow green brown],
            corporation_sizes: [10],
            operating_rounds: 3,
            status: %w[offboard_token_bonus cmd_token_bonus can_buy_companies],
          },
          {
            name: '4D',
            on: %w[4D],
            train_limit: { ten_share: 2 },
            tiles: %i[yellow green brown gray],
            corporation_sizes: [10],
            operating_rounds: 3,
            status: %w[offboard_token_bonus can_buy_companies],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99, 'multiplier' => 0 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[city], 'pay' => 2, 'visit' => 2 }],
            price: 100,
            rusts_on: '4',
            num: 6,
            variants: [
              {
                name: '1G',
                rusts_on: '4',
                distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                           { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city], 'pay' => 2, 'visit' => 2 }],
                price: 100,
              },
            ],
          },
          {
            name: '3',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99, 'multiplier' => 0 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[city], 'pay' => 3, 'visit' => 3 }],
            price: 200,
            rusts_on: '5',
            num: 5,
            variants: [
              {
                name: '2G',
                rusts_on: '5',
                distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                           { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city], 'pay' => 3, 'visit' => 3 }],
                price: 200,
              },
            ],
          },
          {
            name: '4',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99, 'multiplier' => 0 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[city], 'pay' => 4, 'visit' => 4 }],
            price: 300,
            rusts_on: '4D',
            num: 4,
            variants: [
              {
                name: '3G',
                rusts_on: '4D',
                distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                           { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city], 'pay' => 4, 'visit' => 4 }],
                price: 300,
              },
            ],
          },
          {
            name: '5',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99, 'multiplier' => 0 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[city], 'pay' => 5, 'visit' => 5 }],
            price: 500,
            num: 3,
            variants: [
              {
                name: '4G',
                distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                           { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city], 'pay' => 5, 'visit' => 5 }],
                price: 500,
              },
            ],
            events: [{ 'type' => 'forced_conversions' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99, 'multiplier' => 0 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[city], 'pay' => 6, 'visit' => 6 }],
            price: 600,
            num: 2,
            variants: [
              {
                name: '5G',
                distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 },
                           { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city], 'pay' => 6, 'visit' => 6 }],
                price: 600,
              },
            ],
          },
          {
            name: '4D',
            available_on: '6',
            # Multiplier will be done in revenue_for as it only applies to cities
            distance: [{ 'nodes' => ['town'], 'pay' => 99, 'visit' => 99, 'multiplier' => 0 },
                       { 'nodes' => %w[offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => %w[city], 'pay' => 4, 'visit' => 4 }],
            price: 800,
            num: 10,
          },
        ].freeze

        PORT_HEXES = %w[F13 F11 H3 F5 G4].freeze
        PORT_TO_CITY = {
          'I4' => 'H3',
          'I6' => 'H5',
          'I14' => 'H13',
          'I16' => 'H15',
        }.freeze
        P_HEXES = %w[F13 H3 F5].freeze
        RIC_HEX = 'F11'
        WAS_HEX = 'G4'
        HOME_TOKEN_TIMING = :par
        MUST_BUY_TRAIN = :always
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        EBUY_OTHER_VALUE = true
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = true
        CLOSED_CORP_TRAINS_REMOVED = false
        ONLY_HIGHEST_BID_COMMITTED = true
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        CERT_LIMIT_COUNTS_BANKRUPTED = true
        MUST_BID_INCREMENT_MULTIPLE = true
        CMD_HEXES = %w[A6 A12].freeze
        MINE_HEXES = %w[B5 B7 B9 B11 B13].freeze
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'forced_conversions' => ['Forced Conversions',
                                   'All remaining 5 share corporations immediately convert to 10 share corporations']
        ).freeze
        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'cmd_token_bonus' => ['CMD Bonus Income', 'nG trains running to CMD zones with a corporation\'s token get '\
                                                    'a $20 x n bonus to their treasury'],
          'offboard_token_bonus' => ['Offboard Bonus', 'n trains running to red offboards with a corporation\'s '\
                                                       'token in it double the value of the offboard'],
          'may_convert' => ['Corporations May Convert',
                            'At the start of a corporations Operating turn it
                           may choose to convert to a 10 share corporation'],
          'limited_train_buy' => ['Limited Train Buy', 'Corporations may only buy one train of each type from the bank per OR'],
        ).freeze

        include CompanyPrice50To150Percent
        MIN_BID_INCREMENT = 5
        ASSIGNMENT_TOKENS = {
          'P1' => '/icons/18_va/port.svg',
        }.freeze

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18VA::Step::WaterfallAuction,
          ])
        end

        def stock_round
          G18VA::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18VA::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G18VA::Step::Bankrupt,
            G18VA::Step::Assign,
            Engine::Step::Exchange,
            G18VA::Step::Convert,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            G18VA::Step::SpecialToken,
            G18VA::Step::Token,
            Engine::Step::Route,
            G18VA::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18VA::Step::SpecialBuyTrain,
            G18VA::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def reorder_players(_order = nil)
          # Only reorder players at the end of the initial auction round
          return super if @round.operating? || @round.stock?

          @log << 'Players are reordered based on remaining cash'
          # players are reordered from most remaining cash to least with prior order as tie breaker
          current_order = @players.dup.reverse
          @players.sort_by! { |p| [p.cash, current_order.index(p)] }.reverse!
        end

        def buy_train(operator, train, price = nil)
          return super(operator, train, :free) if price.zero?

          super
        end

        def setup
          setup_company_price_50_to_150_percent
        end

        def steamboat
          @steamboat ||= company_by_id('P1')
        end

        def token_company
          @token_company ||= company_by_id('P3')
        end

        def subsidy_for(route, stops)
          train = route.train
          cmd_stop = stops.find { |stop| stop.groups.include?('CMD') }
          if cmd_stop && @phase.status.include?('cmd_token_bonus') && cmd_stop.tokened_by?(train.owner)
            return 0 unless train.name[-1] == 'G'

            return 20 * train.name[0].to_i
          end
          0
        end

        def routes_subsidy(routes)
          routes.sum(&:subsidy)
        end

        def route_distance_str(route)
          train = route.train
          towns = route.visited_stops.count(&:town?)
          ports = route.visited_stops.count(&:offboard?)
          cmds = route.visited_stops.any? { |s| s.groups.include?('CMD') }
          cities = route_distance(route) - towns
          cities -= 1 if cmds
          str = cities.to_s
          str += "+#{towns}m" if towns.positive? && train.name[-1] == 'G'
          str += "+#{ports}p" unless ports.zero?
          str += '+CMD' if cmds
          str
        end

        def train_type(train)
          return :freight if train.name[-1] == 'G'
          return :doubler if train.name[-1] == 'D'

          :passenger
        end

        def port_link?(entity, port)
          hex_by_id(PORT_TO_CITY[port.hex.id]).tile.nodes.find(&:city?).tokened_by?(entity)
        end

        def check_port(visits)
          port_stop = visits.find { |stop| stop&.groups&.include?('PORT') }
          return if !port_stop || port_link?(current_entity, port_stop)

          raise GameError, 'Train cannot visit port without token in connecting city'
        end

        def check_cmd(visits, train)
          cmd_stop = visits.find { |stop| stop&.groups&.include?('CMD') }
          return unless cmd_stop

          raise GameError, "#{train.name} cannot visit CMD" unless train_type(train) == :freight
        end

        def check_distance(route, visits)
          super

          train = route.train
          train_size = train.name[0].to_i

          stops = visits.count { |s| !s.groups.include?('PORT') && (!s.town? || train_type(train) == :freight) }
          raise GameError, 'Train must visit at least 2 paying non-port stops' if stops < 2

          cities = visits.count { |s| (s.city? && !s.groups.include?('CMD')) }
          raise GameError, "#{cities} is too many stops for a #{train.name} train" if cities > train_size

          check_port(visits)
          check_cmd(visits, train)
        end

        def revenue_for(route, stops)
          revenue = super
          train = route.train
          train_size = train.name[0].to_i
          train_type = train_type(train)

          offboard_stop = stops.find { |s| s.groups.include?('OFFBOARD') }
          port_stop = stops.find { |s| s.groups.include?('PORT') }
          cmd_stop = stops.find { |s| s.groups.include?('CMD') }
          plain_cities = stops.select { |s| s.city? && s.groups.empty? }

          steam = steamboat.id
          if route.corporation.assigned?(steam) && stops.any? { |stop| stop.hex.assigned?(steam) }
            revenue += train_type == :doubler ? 20 : 10
          end

          # 4Ds double plain cities
          plain_cities.each { |city| revenue += city.route_revenue(@phase, train) } if train_type == :doubler

          # Offboard cities are doubled if tokened, unless using a 4D in which case they are quadrupled
          if train_type == :doubler && offboard_stop
            revenue += (offboard_stop&.tokened_by?(train.owner) ? 3 : 1) * offboard_stop.route_revenue(@phase, train)
          elsif offboard_stop&.tokened_by?(train.owner)
            revenue += offboard_stop.route_revenue(@phase, train)
          end
          # Freight and doubler trains double ports
          revenue += freight_port_bonus(port_stop, train) if port_stop && %i[freight doubler].include?(train_type)

          revenue += 20 * (train_size - 1) if cmd_stop

          revenue
        end

        def freight_port_bonus(port_stop, train)
          doubled_stops = [port_stop]
          doubled_stops << hex_by_id(PORT_TO_CITY[port_stop.hex.id]).tile.city_towns.first if train_type(train) == :freight
          doubled_stops.sum { |stop| stop.route_revenue(@phase, train) }
        end

        def status_array(corp)
          return ['5-Share'] if corp.type == :five_share
          return ['10-Share'] if corp.type == :ten_share
        end

        def corporation_opts
          two_player? && @optional_rules&.include?(:two_player_share_limit) ? { max_ownership_percent: 70 } : {}
        end

        def train_limit(entity)
          super + Array(abilities(entity, :train_limit)).sum(&:increase)
        end

        # 5 => 10 share conversion logic
        def event_forced_conversions!
          @log << '-- Event: All 5 share corporations must convert to 10 share corporations immediately --'
          @corporations.select { |c| c.type == :five_share }.each { |c| convert(c) }
        end

        def process_convert(action)
          @game.convert(action.entity)
        end

        def close_corporation(corporation, quiet: false)
          super

          # remove port assignment
          removals = Hash.new { |h, k| h[k] = {} }
          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              removals[company][:hex] = hex.name
              hex.remove_assignment!(company)
            end
          end
          removals.each do |company, removal|
            hex = removal[:hex]
            @log << "#{company_by_id(company).name} token removed from #{hex}"
          end

          corporation = reset_corporation(corporation)
          hex_by_id(corporation.coordinates).tile.add_reservation!(corporation, 0)
          @corporations << corporation
        end

        def reset_corporation(corporation)
          new_corp = super
          # Need to reconvert 5-share corporations if the forced conversions event happened. Brown tiles are a good signal.
          convert(new_corp) if new_corp.type == :five_share && @phase.tiles.include?(:brown)
          new_corp
        end

        def convert(corporation)
          before = corporation.total_shares
          shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear

          case corporation.type
          when :five_share
            shares.each { |share| share.percent = 10 }
            shares[0].percent = 20
            new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
            corporation.type = :ten_share
            corporation.float_percent = 20
            2.times { corporation.tokens << Engine::Token.new(corporation, price: 100) }
          else
            raise GameError, 'Cannot convert 10 share corporation'
          end

          shares.each { |share| corporation.share_holders[share.owner] += share.percent }

          new_shares.each do |share|
            add_new_share(share)
          end

          after = corporation.total_shares
          @log << "#{corporation.name} converts from #{before} to #{after} shares"

          new_shares
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        # Upon the purchase of the sixth share, the remaining 4 shares are dumped into the market and the corporation
        # is immediately paid for the 4 shares; kinda like 18Chesapeake
        def sixth_share_capitalization(corporation)
          funding = 4 * corporation.share_price.price
          @log << "#{corporation.name}'s remaining shares are transferred "\
                  "to the Market and receives #{format_currency(funding)}"
          @bank.spend(funding, corporation)
          bundle = ShareBundle.new(corporation.shares_of(corporation))
          @share_pool.transfer_shares(bundle, @share_pool)
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end
      end
    end
  end
end
