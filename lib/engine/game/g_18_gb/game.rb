# frozen_string_literal: true

require_relative '../base'
require_relative '../cities_plus_towns_route_distance_str'
require_relative '../trainless_shares_half_value'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'scenarios'
require_relative 'round/operating'
require_relative 'round/stock'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/buy_train'
require_relative 'step/dividend'
require_relative 'step/emr_share_buying'
require_relative 'step/route'
require_relative 'step/special_choose'
require_relative 'step/special_token'
require_relative 'step/track_and_token'
require_relative 'step/waterfall_auction'

module Engine
  module Game
    module G18GB
      class Game < Game::Base
        include_meta(G18GB::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include Entities
        include Map
        include Scenarios
        include TrainlessSharesHalfValue

        attr_reader :scenario
        attr_accessor :train_bought

        GAME_END_CHECK = { final_train: :current_or, stock_market: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false

        BANK_CASH = 99_999

        CURRENCY_FORMAT_STR = '£%s'

        CERT_LIMIT_TYPES = [].freeze
        CERT_LIMIT_INCLUDES_PRIVATES = false

        PRESIDENT_SALES_TO_MARKET = true

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true

        CAPITALIZATION = :full

        SELL_BUY_ORDER = :sell_buy

        SOLD_OUT_INCREASE = false

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        MUST_SELL_IN_BLOCKS = true

        SELL_AFTER = :any_time

        TRACK_RESTRICTION = :restrictive

        EBUY_OTHER_VALUE = false

        HOME_TOKEN_TIMING = :start

        DISCARDED_TRAINS = :remove

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: true }].freeze

        IMPASSABLE_HEX_COLORS = %i[gray red].freeze

        MARKET_SHARE_LIMIT = 100

        SHOW_SHARE_PERCENT_OWNERSHIP = true

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          unlimited: 'May buy shares from IPO in excess of 60%',
          multiple_buy: 'President may buy two shares per turn',
        )

        MARKET = [
          %w[50b 55b 60b 65b 70p 75p 80p 90p 100p 115 130 145 160 180 200 220 240 265 290 320 350e 380e],
        ].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          multiple_buy: :olive,
        )

        EVENTS_TEXT = {
          'float_60' =>
          ['Start with 60% sold', 'New corporations float once 60% of their shares have been sold'],
          'float_10_share' =>
          ['Start as 10-share', 'New corporations are 10-share corporations (that float at 60%)'],
          'remove_unstarted' =>
          ['Remove unstarted corps', 'Unstarted corporations are removed along with one 6X train each'],
        }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'only_pres_drop' => ['Only pres. sales drop', 'Only sales by corporation presidents drop the share price'],
        ).freeze

        PHASES = [
          {
            name: '2+1',
            train_limit: { '5-share': 3, '10-share': 4 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3+1',
            on: '3+1',
            train_limit: { '5-share': 3, '10-share': 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4+2',
            on: '4+2',
            train_limit: { '5-share': 2, '10-share': 3 },
            tiles: %i[yellow green blue],
            operating_rounds: 2,
          },
          {
            name: '5+2',
            on: '5+2',
            train_limit: { '5-share': 2, '10-share': 3 },
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '4X',
            on: '4X',
            train_limit: 2,
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '5X',
            on: '5X',
            train_limit: 2,
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '6X',
            on: '6X',
            train_limit: 2,
            tiles: %i[yellow green blue brown gray],
            status: ['only_pres_drop'],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+1',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 2,
                'visit' => 2,
              },
            ],
            price: 80,
            rusts_on: '4+2',
          },
          {
            name: '3+1',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 3,
                'visit' => 3,
              },
            ],
            price: 200,
            rusts_on: '4X',
            events: [
              {
                'type' => 'float_60',
              },
            ],
          },
          {
            name: '4+2',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 2,
                'visit' => 2,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 4,
                'visit' => 4,
              },
            ],
            price: 300,
            rusts_on: '6X',
          },
          {
            name: '5+2',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 2,
                'visit' => 2,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 5,
                'visit' => 5,
              },
            ],
            price: 500,
            events: [
              {
                'type' => 'float_10_share',
              },
            ],
          },
          {
            name: '4X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 4,
                'visit' => 4,
              },
              {
                'nodes' => ['town'],
                'pay' => 0,
                'visit' => 99,
              },
            ],
            price: 550,
          },
          {
            name: '5X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 5,
                'visit' => 5,
              },
              {
                'nodes' => ['town'],
                'pay' => 0,
                'visit' => 99,
              },
            ],
            price: 650,
            available_on: '4X',
          },
          {
            name: '6X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 6,
                'visit' => 6,
              },
              {
                'nodes' => ['town'],
                'pay' => 0,
                'visit' => 99,
              },
            ],
            price: 700,
            events: [
              {
                'type' => 'remove_unstarted',
              },
            ],
            available_on: '5X',
          },
        ].freeze

        def init_scenario(optional_rules)
          num_players = @players.size
          two_east_west = optional_rules.include?(:two_player_ew)
          four_alternate = optional_rules.include?(:four_player_alt)

          case num_players
          when 2
            SCENARIOS[two_east_west ? '2EW' : '2NS']
          when 3
            SCENARIOS['3']
          when 4
            SCENARIOS[four_alternate ? '4Alt' : '4Std']
          when 5
            SCENARIOS['5']
          else
            SCENARIOS['6']
          end
        end

        def init_optional_rules(optional_rules)
          optional_rules = super(optional_rules)
          optional_rules.delete(:two_player_ew) if @players.size != 2
          optional_rules.delete(:four_player_alt) if @players.size != 4
          @scenario = init_scenario(optional_rules)
          optional_rules
        end

        def trigger_end_game_restrictions
          return if @end_game_near

          @log << '-- Event: End game restrictions are now in place: no more tokens may be placed --'
          @end_game_near = true
        end

        def end_game_restrictions_active?
          @end_game_near
        end

        def optional_hexes
          case @scenario['map']
          when '2NS'
            self.class::HEXES_2P_NS
          when '2EW'
            self.class::HEXES_2P_EW
          else
            self.class::HEXES
          end
        end

        def num_trains(train)
          @scenario['train_counts'][train[:name]]
        end

        def game_cert_limit
          @scenario['cert-limit']
        end

        VALID_ABILITIES_OPEN = %i[blocks_hexes choose_ability reservation].freeze
        VALID_ABILITIES_CLOSED = %i[hex_bonus reservation tile_lay token].freeze

        def abilities(entity, type = nil, time: nil, on_phase: nil, passive_ok: nil, strict_time: nil)
          return if entity&.player?

          ability = super

          return ability unless entity&.company?
          return unless ability

          valid = entity.value.positive? ? VALID_ABILITIES_OPEN : VALID_ABILITIES_CLOSED
          valid.include?(ability.type) ? ability : nil
        end

        def remove_blockers!(company)
          ability = abilities(company, :blocks_hexes)
          return unless ability

          ability.hexes.each do |hex|
            hex_by_id(hex).tile.blockers.reject! { |c| c == company }
          end
          company.remove_ability(ability)
        end

        def close_company(company)
          @bank.spend(company.revenue, company.owner)
          @log << "#{company.name} closes, paying #{format_currency(company.revenue)} to  #{company.owner.name}"
          remove_blockers!(company)
          company.revenue = 0
          company.value = 0
        end

        def close_company_in_hex(hex)
          @companies.each do |company|
            block = abilities(company, :blocks_hexes)
            close_company(company) if block&.hexes&.include?(hex.coordinates)
          end
        end

        def game_companies
          scenario_comps = @scenario['companies']
          self.class::COMPANIES.select { |comp| scenario_comps.include?(comp[:sym]) }
        end

        def game_corporations
          scenario_corps = @scenario['corporations'] + @scenario['corporation-extra'].sort_by { rand }.take(1)
          self.class::CORPORATIONS.select { |corp| scenario_corps.include?(corp[:sym]) }
        end

        def game_tiles
          if @scenario['gray-tiles']
            self.class::TILES.merge(self.class::GRAY_TILES)
          else
            self.class::TILES
          end
        end

        def init_starting_cash(players, bank)
          cash = @scenario['starting-cash']
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def setup
          tiers = {}
          delayed = 0
          @corporations.sort_by { rand }.each do |corp|
            if (corp.id != 'LNWR') && (delayed < @scenario['tier2-corps'])
              tiers[corp.id] = 2
              delayed += 1
            else
              tiers[corp.id] = 1
            end
          end

          tier1, tier2 = tiers.partition { |_co, tier| tier == 1 }
          @log << "Corporations available SR1: #{tier1.map(&:first).sort.join(', ')}"
          @log << "Corporations available SR2: #{tier2.map(&:first).sort.join(', ')}"
          @tiers = tiers
          @insolvent_corps = []
          @train_bought = false
          @end_game_near = false

          @corporations.each { |corp| place_home_token(corp) }
        end

        def timeline
          @timeline = [
            '- Tier 2 corporations can only be started from SR2 onwards.',
            '- At the end of each OR, a train is exported if no new train was purchased from the bank during the OR.',
            '- After an OR ends with 2 or fewer trains remaining, no more tokens may be placed.',
          ].freeze
        end

        def event_float_60!
          @log << '-- Event: New corporations float once 60% of their shares have been sold --'
          @corporations.reject(&:floated?).each { |c| c.float_percent = 60 }
        end

        def event_float_10_share!
          @log << '-- Event: Unstarted corporations are converted to 10-share corporations --'
          @corporations.reject(&:floated?).each { |c| convert_to_ten_share(c) }
        end

        def remove_corporation(corporation)
          token = corporation.tokens.first(&:used).dup
          close_corporation(corporation, quiet: true)
          token.city.place_token(corporation, token, check_tokenable: false)
        end

        def event_remove_unstarted!
          @log << '-- Event: Unstarted corporations are removed --'
          remove_trains = @depot.trains.select { |t| t.name == '6X' }
          @corporations.reject(&:floated?).each do |corporation|
            remove_corporation(corporation)
            if (train = remove_trains.pop)
              @depot.remove_train(train)
              @log << "#{corporation.id} closes, removing a 6X train"
            else
              @log << "#{corporation.id} closes"
            end
          end
        end

        def sorted_corporations
          case @round
          when Engine::Round::Stock
            ipoed, others = @corporations.reject { |corp| @tiers[corp.id] > @round_counter }.partition(&:ipoed)
            ipoed.sort + others
          when Engine::Round::Operating
            [@round.current_operator]
          else
            []
          end
        end

        def bank_sort(corporations)
          return super unless @round_counter <= 1

          corporations.sort_by { |c| [@tiers[c.id], c.name] }
        end

        def required_bids_to_pass
          @scenario['required_bids']
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18GB::Step::WaterfallAuction,
          ])
        end

        def init_round_finished
          @players.sort_by! { |p| [p.cash, -@companies.count { |c| c.owner == p }] }
        end

        def check_new_layer; end

        def par_prices(_corp)
          stock_market.par_prices
        end

        def lnwr_ipoed?
          @corporations.find { |corp| corp.id == 'LNWR' }&.ipoed
        end

        def married_to_lnwr(player)
          return false if lnwr_ipoed?

          @companies.any? { |co| co.owner == player && co.sym == 'LB' }
        end

        def can_par?(corporation, player)
          return true if lnwr_ipoed?

          if married_to_lnwr(player)
            # player owns the LB so can only start the LNWR
            corporation.id == 'LNWR'
          else
            # player doesn't own the LB so can start any except the LNWR
            corporation.id != 'LNWR'
          end
        end

        def non_president_sales_drop_price?
          !@phase.status.include?('only_pres_drop')
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          corporation = bundle.corporation
          old_price = corporation.share_price
          was_president = corporation.president?(bundle.owner)
          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          bundle.num_shares.times { @stock_market.move_down(corporation) } if non_president_sales_drop_price? || was_president
          log_share_price(corporation, old_price)
        end

        def insolvent?(corp)
          @insolvent_corps.include?(corp)
        end

        def make_insolvent(corp)
          return if insolvent?(corp)

          @insolvent_corps << corp
          @log << "#{corp.name} is now Insolvent"
        end

        def clear_insolvent(corp)
          return unless insolvent?(corp)

          @insolvent_corps.delete(corp)
          @log << "#{corp.name} is no longer Insolvent"
        end

        def status_array(corp)
          status = []
          status << ["Tier #{@tiers[corp.id]}", 'bold'] if @round_counter <= 1
          status << %w[10-share bold] if corp.type == :'10-share'
          status << %w[5-share bold] if corp.type == :'5-share'
          status << %w[Insolvent bold] if insolvent?(corp)
          status << %w[Receivership bold] if corp.receivership?
          status
        end

        def float_corporation(corporation)
          super
          return unless corporation.type == :'10-share'

          bundle = ShareBundle.new(corporation.shares_of(corporation))
          @share_pool.transfer_shares(bundle, @share_pool)
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used

          hex = hex_by_id(corporation.coordinates)
          tile = hex&.tile
          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
          token = corporation.find_token_by_type
          return unless city.tokenable?(corporation, tokens: token)

          city.place_token(corporation, token)
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def convert_capital(corporation, emergency)
          steps = emergency ? 3 : 2
          5 * stock_market.find_share_price(corporation, [:left] * steps).price
        end

        def convert_to_ten_share(corporation, price_drops = 0, blame_president = false)
          # update corporation type and report conversion
          corporation.type = :'10-share'
          @log << (if blame_president
                     "#{corporation.owner.name} converts #{corporation.id} into a 10-share corporation"
                   else
                     "#{corporation.id} converts into a 10-share corporation"
                   end)

          # update existing shares to 10% shares
          original_shares = shares_for_corporation(corporation)
          corporation.share_holders.clear
          original_shares.each { |s| s.percent = 10 }
          original_shares.first.percent = 20
          original_shares.each { |s| corporation.share_holders[s.owner] += s.percent }

          # create new shares
          owner = corporation.floated? ? @share_pool : corporation
          shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4, owner: owner) }
          shares.each do |share|
            add_new_share(share)
          end

          # create new tokens and remove reminder from charter
          corporation.abilities.dup.each do |ability|
            if ability&.description&.start_with?('Conversion tokens:')
              ability.count.times { corporation.tokens << Engine::Token.new(corporation, price: 50) }
              corporation.remove_ability(ability)
            end
          end

          # update share price
          unless price_drops.zero?
            old_price = corporation.share_price
            price_drops.times { @stock_market.move_down(corporation) }
            log_share_price(corporation, old_price)
          end

          # add new capital
          return unless corporation.floated?

          capital = corporation.share_price.price * 5
          @bank.spend(capital, corporation)
          @log << "#{corporation.id} receives #{format_currency(capital)}"
        end

        def stock_round
          @log << '-- Event: Tier 2 corporations are now available --' if @round_counter == 4
          G18GB::Round::Stock.new(self, [
            Engine::Step::HomeToken,
            G18GB::Step::BuySellParShares,
          ])
        end

        def hex_blocked_by_ability?(_entity, ability, hex, _tile = nil)
          phase.tiles.include?(:blue) ? false : super
        end

        def special_green_hexes(corporation)
          return {} unless corporation&.corporation?

          corporation.abilities.flat_map { |a| a.type == :tile_lay ? a.hexes.map { |h| [h, a.tiles] } : [] }.to_h
        end

        def add_new_special_green_hex(corporation, hex_coords)
          ability = {
            type: 'tile_lay',
            hexes: [hex_coords],
            tiles: %w[G36 G37 G38],
            cost: 0,
            reachable: true,
            consume_tile_lay: true,
            description: "May place a green tile in #{hex_coords}",
            desc_detail: "May place a green tile in #{hex_coords}, instead of the usual yellow tile, even before green tiles " \
                         'are normally available',
          }
          corporation.add_ability(Engine::Ability::TileLay.new(**ability))
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          corporation = @round.current_entity
          sgh = special_green_hexes(corporation)

          if to.color == :green &&
             sgh.include?(from.hex.coordinates) &&
             sgh[from.hex.coordinates].include?(to.name) &&
             Engine::Tile::COLORS.index(to.color) > Engine::Tile::COLORS.index(from.color)
            return true
          end

          super
        end

        def upgrades_to_correct_color?(from, to, selected_company: nil)
          (from.color == to.color && from.color == :blue) || super
        end

        def legal_tile_rotation?(_entity, _hex, tile)
          return super unless tile.color == :blue

          tile.rotation.zero?
        end

        def route_trains(entity)
          return super unless insolvent?(entity)

          [@depot.min_depot_train]
        end

        def express_train?(train)
          train.name.end_with?('X')
        end

        def train_owner(train)
          train.owner == @depot ? lessee : train.owner
        end

        def lessee
          current_entity
        end

        def train_help(entity, trains, _routes)
          leased_train = false
          plus_trains = false
          express_trains = false

          trains.each do |t|
            leased_train = true if t.owner == @depot
            plus_trains = true if t.name.include?('+')
            express_trains = true if t.name.include?('X')
          end

          help = []
          help << "#{entity.id} is leasing a #{@depot.min_depot_train.name} train from the bank" if leased_train
          help << 'N+M trains run N cities and offboards and M towns' if plus_trains
          if express_trains
            help << "X trains ignore all towns and count only cities and offboards. They add a bonus of #{format_currency(10)} "\
                    'per hex as the crow flies between the start and the end of the route'
          end

          help
        end

        def revenue_bonuses(route, stops)
          stop_hexes = stops.map { |stop| stop.hex.name }
          @companies.select { |co| co.owner == route&.corporation&.owner }.flat_map do |co|
            if co.value.positive?
              []
            else
              co.abilities.select { |ab| ab.type == :hex_bonus }.flat_map do |ab|
                ab.hexes.select { |h| stop_hexes.include?(h) }.map { |_| { revenue: ab.amount, description: co.sym } }
              end
            end
          end
        end

        def revenue_info(route, stops)
          standard = revenue_bonuses(route, stops) + estuary_bonuses(route) + compass_bonuses(route)
          return standard unless express_train?(route.train)

          standard + distance_bonus(route, stops)
        end

        def revenue_for(route, stops)
          # count only unique hexes in determining revenue
          stop_revenues = stops.uniq { |s| s.hex.name }.map { |s| s.route_revenue(route.phase, route.train) }
          stop_revenues.sum + revenue_info(route, stops).sum { |bonus| bonus[:revenue] }
        end

        def revenue_str(route)
          route.stops.map { |s| s.hex.name }.join('-') + revenue_info(route, route.stops).map do |bonus|
            if bonus[:description] == 'X'
              "+#{format_currency(bonus[:revenue])}"
            else
              "+(#{bonus[:description]})"
            end
          end.join
        end

        def compass_points_in_network(network_hexes)
          @scenario['compass-hexes'].reject { |_compass, compass_hexes| (network_hexes & compass_hexes).empty? }.map(&:first)
        end

        def ns_bonus_offboard
          @hexes.find { |hex| hex.coordinates == 'C8' }.tile.offboards.first
        end

        def ew_bonus_offboard
          @hexes.find { |hex| hex.coordinates == 'C10' }.tile.offboards.first
        end

        def routes_intersect(first, second)
          !(first.visited_stops & second.visited_stops).reject(&:offboard?).empty?
        end

        def route_sets_intersect(first, second)
          first.any? { |a| second.any? { |b| routes_intersect(a, b) } }
        end

        def combine_route_sets(sets)
          # simplify overlapping route sets by combining them where possible
          overlapped = []

          sets.combination(2).select { |first, second| route_sets_intersect(first, second) }.each do |first, second|
            overlapped << second
            second.each { |route| first << route }
          end

          sets.reject { |set| overlapped.include?(set) }
        end

        def route_sets(routes)
          sets = routes.map { |route| [route] }
          return [] if sets.empty?

          prev_length = 0
          while sets.size != prev_length
            prev_length = sets.size
            sets = combine_route_sets(sets)
          end
          sets
        end

        def compass_bonuses(route)
          bonuses = []
          return bonuses if route.chains.empty?

          route_set = route_sets(route.routes).find { |set| set.include?(route) } || []
          return bonuses unless route == route_set.first # apply bonus to the first route in the set

          hexes = route_set.flat_map { |r| r.ordered_paths.map { |path| path.hex.coordinates } }
          points = compass_points_in_network(hexes)
          if points.include?('N') && points.include?('S')
            bonuses << {
              revenue: ns_bonus_offboard.route_revenue(route.phase, route.train),
              description: 'NS',
            }
          end
          if points.include?('E') && points.include?('W')
            bonuses << {
              revenue: ew_bonus_offboard.route_revenue(route.phase, route.train),
              description: 'EW',
            }
          end

          bonuses
        end

        def estuary_bonuses(route)
          route.ordered_paths.map do |path|
            if path.hex.coordinates == 'I4' && path.track == :dual
              { revenue: 40, description: 'FT' }
            elsif path.hex.coordinates == 'C22' && path.track == :dual
              { revenue: 30, description: 'S' }
            end
          end.compact
        end

        def distance_bonus(route, _stops)
          return [] if route.chains.empty?

          visited = route.visited_stops.reject { |stop| stop.hex.tile.cities.empty? && stop.hex.tile.offboards.empty? }
          start = visited.first.hex
          finish = visited.last.hex

          [{ revenue: hex_crow_distance(start, finish) * 10, description: 'X' }]
        end

        def hex_crow_distance(start, finish)
          dx = (start.x - finish.x).abs
          dy = (start.y - finish.y).abs
          dx + [0, (dy - dx) / 2].max
        end

        def buy_train(operator, train, price = nil)
          @train_bought = true if train.owner == @depot
          super
        end

        def new_operating_round(round_num = 1)
          @train_bought = false
          super
        end

        def operating_round(round_num)
          G18GB::Round::Operating.new(self, [
            G18GB::Step::SpecialChoose,
            Engine::Step::SpecialTrack,
            G18GB::Step::SpecialToken,
            Engine::Step::HomeToken,
            G18GB::Step::TrackAndToken,
            G18GB::Step::Route,
            G18GB::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18GB::Step::BuyTrain,
            G18GB::Step::EMRShareBuying,
          ], round_num: round_num)
        end

        def or_round_finished
          depot.export! unless @train_bought
          trigger_end_game_restrictions if @depot.upcoming.size <= 2
        end

        def end_now?(after)
          if @round.is_a?(round_end) && @depot.upcoming.size == 1 && !@train_bought
            @depot.export!
            return true
          end

          super
        end
      end
    end
  end
end
